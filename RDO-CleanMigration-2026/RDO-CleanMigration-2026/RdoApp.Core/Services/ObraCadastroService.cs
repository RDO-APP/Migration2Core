using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

public class ObraCadastroService
{
    private const int MaxLogoBytes = 2 * 1024 * 1024;
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public ObraCadastroService(RdoDbContext context, IConfiguration configuration, IWebHostEnvironment env)
    {
        _context = context;
        _configuration = configuration;
        _env = env;
    }

    /// <summary>
    /// Local do template (P3 = obra sessão; P2 = qualquer vínculo) — pré-preenche UF/Município/empresas.
    /// </summary>
    public async Task<(string? CidadeEstado, int IdUf, int IdMunicipio, int IdContratante, int IdContratada)> ResolveTemplateLocalAsync(
        int colaboradorId,
        int? templateObraId,
        CancellationToken cancellationToken)
    {
        int? obraId = templateObraId is > 0 ? templateObraId : null;
        if (obraId is null or <= 0)
        {
            obraId = await _context.ObraColaboradores.AsNoTracking()
                .Where(oc => oc.OcoIdColaborador == colaboradorId)
                .OrderByDescending(oc => oc.OcoIdObra)
                .Select(oc => (int?)oc.OcoIdObra)
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (obraId is null or <= 0) return (null, 0, 0, 0, 0);

        var row = await (
            from o in _context.Obras.AsNoTracking()
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into ms
            from m in ms.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on (m != null ? m.MunIdUf : 0) equals uf.UfeIdUf into ufs
            from uf in ufs.DefaultIfEmpty()
            where o.ObrIdObra == obraId.Value
            select new
            {
                IdMunicipio = o.ObrIdMunicipio,
                Mun = m != null ? m.MunDsMunicipio : null,
                IdUf = uf != null ? uf.UfeIdUf : 0,
                Uf = uf != null ? uf.UfeDsSigla : null,
                IdContratante = o.ObrIdEmpresaContratante ?? 0,
                IdContratada = o.ObrIdEmpresaContratada ?? 0,
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null) return (null, 0, 0, 0, 0);
        string? cidade = null;
        if (!string.IsNullOrWhiteSpace(row.Mun))
            cidade = string.IsNullOrWhiteSpace(row.Uf) ? row.Mun! : row.Mun + "/" + row.Uf;
        return (cidade, row.IdUf, row.IdMunicipio, row.IdContratante, row.IdContratada);
    }

    public async Task<string?> ResolveCidadeEstadoTemplateAsync(
        int colaboradorId,
        int? templateObraId,
        CancellationToken cancellationToken)
    {
        var (cidade, _, _, _, _) = await ResolveTemplateLocalAsync(colaboradorId, templateObraId, cancellationToken);
        return cidade;
    }

    public async Task<ObraCadastroDto> BuildNovaAsync(
        int colaboradorId,
        int? templateObraId,
        CancellationToken cancellationToken)
    {
        // Nova obra: NÃO herda UF/Município nem empresa do template.
        // Opção A: ambos dropdowns começam em Selecione... (0); lista = empresas do usuário.
        var (empresas, idsMinhas) = await LoadEmpresasCadastroAsync(
            colaboradorId,
            0,
            0,
            cancellationToken);

        return new ObraCadastroDto
        {
            Id = 0,
            Nova = true,
            CidadeEstado = "",
            IdUf = 0,
            IdMunicipio = 0,
            IdContratante = 0,
            IdContratada = 0,
            Empresas = empresas,
            IdsEmpresasDoUsuario = idsMinhas,
        };
    }

    /// <summary>
    /// Copiar obra (Dia 1): cabeçalho da origem com Id=0 / Nova=true.
    /// Não clona colaboradores/equipamentos (listas só pós-Salvar no Core).
    /// </summary>
    public async Task<ObraCadastroDto?> BuildCopiaAsync(
        int colaboradorId,
        int idObraOrigem,
        CancellationToken cancellationToken)
    {
        var vinculado = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObraOrigem, cancellationToken);
        if (!vinculado)
        {
            return null;
        }

        var src = await GetAsync(idObraOrigem, colaboradorId, cancellationToken);
        if (src == null)
        {
            return null;
        }

        return new ObraCadastroDto
        {
            Id = 0,
            Nova = true,
            Descricao = src.Descricao,
            DataInicio = src.DataInicio,
            DataPrevisaoFim = src.DataPrevisaoFim,
            Logradouro = src.Logradouro,
            Numero = src.Numero,
            Complemento = src.Complemento,
            Bairro = src.Bairro,
            Cep = src.Cep,
            IdUf = src.IdUf,
            IdMunicipio = src.IdMunicipio,
            IdContratante = src.IdContratante,
            IdContratada = src.IdContratada,
            AreaTotal = src.AreaTotal,
            AreaConstruida = src.AreaConstruida,
            CidadeEstado = src.CidadeEstado,
            Finalizada = false,
            // Foto nova no Salvar — não reaproveitar path da origem.
            DescricaoFoto = "",
            Empresas = src.Empresas,
            IdsEmpresasDoUsuario = src.IdsEmpresasDoUsuario,
        };
    }

    public async Task<ObraCadastroDto?> GetAsync(
        int obraId,
        int colaboradorId,
        CancellationToken cancellationToken)
    {
        var row = await (
            from o in _context.Obras.AsNoTracking()
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into ms
            from m in ms.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on (m != null ? m.MunIdUf : 0) equals uf.UfeIdUf into ufs
            from uf in ufs.DefaultIfEmpty()
            where o.ObrIdObra == obraId
            select new
            {
                o.ObrIdObra,
                o.ObrDsObra,
                o.ObrDtInicio,
                o.ObrDtPrevisaoFim,
                o.ObrDtFim,
                o.ObrDsLogradouro,
                o.ObrDsNumero,
                o.ObrDsComplemento,
                o.ObrDsBairro,
                o.ObrDsCep,
                o.ObrIdMunicipio,
                o.ObrNrAreaTotal,
                o.ObrNrAreaTotalConstruida,
                o.ObrDsFoto,
                IdContratante = o.ObrIdEmpresaContratante ?? 0,
                IdContratada = o.ObrIdEmpresaContratada ?? 0,
                Mun = m != null ? m.MunDsMunicipio : null,
                IdUf = uf != null ? uf.UfeIdUf : 0,
                Uf = uf != null ? uf.UfeDsSigla : null
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null) return null;
        var cidade = string.IsNullOrWhiteSpace(row.Mun)
            ? ""
            : string.IsNullOrWhiteSpace(row.Uf) ? row.Mun! : row.Mun + "/" + row.Uf;

        var (empresas, idsMinhas) = await LoadEmpresasCadastroAsync(
            colaboradorId,
            row.IdContratante,
            row.IdContratada,
            cancellationToken);

        return new ObraCadastroDto
        {
            Id = row.ObrIdObra,
            Nova = false,
            Descricao = row.ObrDsObra ?? "",
            DataInicio = FormatDate(row.ObrDtInicio),
            DataPrevisaoFim = FormatDate(row.ObrDtPrevisaoFim),
            Logradouro = row.ObrDsLogradouro ?? "",
            Numero = row.ObrDsNumero ?? "",
            Complemento = row.ObrDsComplemento ?? "",
            Bairro = row.ObrDsBairro ?? "",
            Cep = row.ObrDsCep ?? "",
            IdUf = row.IdUf,
            IdMunicipio = row.ObrIdMunicipio,
            IdContratante = row.IdContratante,
            IdContratada = row.IdContratada,
            AreaTotal = row.ObrNrAreaTotal,
            AreaConstruida = row.ObrNrAreaTotalConstruida,
            CidadeEstado = cidade,
            Finalizada = row.ObrDtFim != null,
            DescricaoFoto = NormalizeFotoUrl(row.ObrDsFoto),
            Empresas = empresas,
            IdsEmpresasDoUsuario = idsMinhas,
        };
    }

    public async Task<ObraCadastroSaveResultDto> SaveAsync(
        int obraId,
        int colaboradorId,
        ObraCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        // Não materializar Obra inteira: NULL em varchar + Pomelo = DBNull→String (O1 / L10 / f389736).
        var meta = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new
            {
                o.ObrIdObra,
                o.ObrDtFim,
                o.ObrIdMunicipio,
                Foto = (string?)o.ObrDsFoto,
            })
            .FirstOrDefaultAsync(cancellationToken);
        if (meta == null) return Fail("Obra nao encontrada.");
        if (meta.ObrDtFim != null) return Fail("Obra finalizada — edicao bloqueada.");

        if (!TryValidate(request, out var desc, out var ini, out var fim, out var fail))
        {
            return fail!;
        }

        if (!TryResolveEmpresas(request, out var idContratante, out var idContratada, out var donoId, out var empFail))
        {
            return empFail!;
        }

        var minhas = await IdsEmpresasDoUsuarioAsync(colaboradorId, cancellationToken);
        if (!TryDerivePapel(idContratante, idContratada, minhas, out _, out var papelFail))
        {
            return papelFail!;
        }

        var logradouro = (request.Logradouro ?? "").Trim();
        var numeroEdit = (request.Numero ?? "").Trim();
        var numero = string.IsNullOrEmpty(numeroEdit) ? "0" : numeroEdit;
        var complemento = (request.Complemento ?? "").Trim();
        var bairro = (request.Bairro ?? "").Trim();
        var cepEdit = new string((request.Cep ?? "").Where(char.IsDigit).ToArray());
        if (cepEdit.Length > 10) cepEdit = cepEdit[..10];
        var municipioId = request.IdMunicipio > 0 ? request.IdMunicipio : meta.ObrIdMunicipio;
        int? empContratante = idContratante > 0 ? idContratante : null;
        int? empContratada = idContratada > 0 ? idContratada : null;

        var logoStub = new Obra { ObrIdObra = obraId, ObrDsFoto = meta.Foto ?? "" };
        if (!TryApplyLogo(logoStub, request, out var logoFail))
        {
            return logoFail!;
        }

        var foto = logoStub.ObrDsFoto ?? "";

        try
        {
            var updated = await _context.Obras
                .Where(o => o.ObrIdObra == obraId)
                .ExecuteUpdateAsync(
                    s => s
                        .SetProperty(o => o.ObrDsObra, desc)
                        .SetProperty(o => o.ObrDtInicio, ini.Date)
                        .SetProperty(o => o.ObrDtPrevisaoFim, fim)
                        .SetProperty(o => o.ObrDsLogradouro, logradouro)
                        .SetProperty(o => o.ObrDsNumero, numero)
                        .SetProperty(o => o.ObrDsComplemento, complemento)
                        .SetProperty(o => o.ObrDsBairro, bairro)
                        .SetProperty(o => o.ObrDsCep, cepEdit)
                        .SetProperty(o => o.ObrIdMunicipio, municipioId)
                        .SetProperty(o => o.ObrIdEmpresaContratante, empContratante)
                        .SetProperty(o => o.ObrIdEmpresaContratada, empContratada)
                        .SetProperty(o => o.ObrIdDono, donoId)
                        .SetProperty(o => o.ObrNrAreaTotal, request.AreaTotal)
                        .SetProperty(o => o.ObrNrAreaTotalConstruida, request.AreaConstruida)
                        .SetProperty(o => o.ObrDsFoto, foto),
                    cancellationToken);
            if (updated == 0) return Fail("Obra nao encontrada.");
        }
        catch (DbUpdateException ex)
        {
            var detail = ex.InnerException?.Message ?? ex.Message;
            return Fail("Falha ao gravar obra no banco: " + detail);
        }
        catch (Exception ex)
        {
            return Fail("Erro ao salvar obra: " + (ex.InnerException?.Message ?? ex.Message));
        }

        return new ObraCadastroSaveResultDto { Ok = true, ObraNome = desc, ObraId = obraId };
    }

    /// <summary>
    /// Nova obra — Opção A: dois dropdowns (sem radio); papel t/d derivado das empresas do usuário.
    /// </summary>
    public async Task<ObraCadastroSaveResultDto> CreateAsync(
        int colaboradorId,
        int? templateObraId,
        ObraCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!TryValidate(request, out var desc, out var ini, out var fim, out var fail))
        {
            return fail!;
        }

        if (!TryResolveEmpresas(request, out var idContratante, out var idContratada, out var donoId, out var empFail))
        {
            return empFail!;
        }

        var minhas = await IdsEmpresasDoUsuarioAsync(colaboradorId, cancellationToken);
        if (!TryDerivePapel(idContratante, idContratada, minhas, out var stCc, out var papelFail))
        {
            return papelFail!;
        }

        if (!await LicencaPermiteNovaObraAsync(donoId, cancellationToken))
        {
            return Fail("A licença desta empresa não permite que novas obras sejam adicionadas.");
        }

        // Só ints do modelo — evita InvalidCast DBNull→String em colunas NULL da obra template.
        int templateMun;
        int? hSemana;
        int? hSab;
        int? hDom;
        int ocoCargo;
        int ocoGrupo;

        if (templateObraId is > 0)
        {
            var tpl = await _context.Obras.AsNoTracking()
                .Where(o => o.ObrIdObra == templateObraId.Value)
                .Select(o => new
                {
                    o.ObrIdMunicipio,
                    o.ObrNrHorasSemana,
                    o.ObrNrHorasSabado,
                    o.ObrNrHorasDomingo,
                })
                .FirstOrDefaultAsync(cancellationToken);
            if (tpl == null)
            {
                return Fail("Obra modelo da sessão não encontrada.");
            }

            var vin = await _context.ObraColaboradores.AsNoTracking()
                .Where(o => o.OcoIdObra == templateObraId.Value && o.OcoIdColaborador == colaboradorId)
                .Select(o => new { o.OcoIdCargo, o.OcoIdGrupo })
                .FirstOrDefaultAsync(cancellationToken);
            if (vin == null)
            {
                return Fail("Você não está vinculado à obra da sessão — não é possível criar nova obra.");
            }

            templateMun = tpl.ObrIdMunicipio;
            hSemana = tpl.ObrNrHorasSemana;
            hSab = tpl.ObrNrHorasSabado;
            hDom = tpl.ObrNrHorasDomingo;
            ocoCargo = vin.OcoIdCargo;
            ocoGrupo = vin.OcoIdGrupo;
        }
        else
        {
            var row = await (
                from oc in _context.ObraColaboradores.AsNoTracking()
                join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
                where oc.OcoIdColaborador == colaboradorId
                orderby o.ObrIdObra descending
                select new
                {
                    o.ObrIdMunicipio,
                    o.ObrNrHorasSemana,
                    o.ObrNrHorasSabado,
                    o.ObrNrHorasDomingo,
                    oc.OcoIdCargo,
                    oc.OcoIdGrupo,
                }).FirstOrDefaultAsync(cancellationToken);
            if (row == null)
            {
                return Fail("Não há obra modelo: vincule-se a uma obra existente ou cadastre empresa antes de criar a primeira.");
            }

            templateMun = row.ObrIdMunicipio;
            hSemana = row.ObrNrHorasSemana;
            hSab = row.ObrNrHorasSabado;
            hDom = row.ObrNrHorasDomingo;
            ocoCargo = row.OcoIdCargo;
            ocoGrupo = row.OcoIdGrupo;
        }

        var municipioId = request.IdMunicipio > 0 ? request.IdMunicipio : templateMun;
        if (municipioId <= 0)
        {
            municipioId = await _context.Colaboradores.AsNoTracking()
                .Where(c => c.ColIdColaborador == colaboradorId)
                .Select(c => c.ColIdMunicipio ?? 0)
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (municipioId <= 0)
        {
            return Fail("Informe UF e Município (obrigatórios).");
        }

        var cep = new string((request.Cep ?? "").Where(char.IsDigit).ToArray());
        if (cep.Length > 10) cep = cep[..10];
        var numero = (request.Numero ?? "").Trim();
        if (string.IsNullOrEmpty(numero)) numero = "0";

        var entity = new Obra
        {
            ObrDsObra = desc,
            ObrDtInicio = ini.Date,
            ObrDtPrevisaoFim = fim,
            ObrDsLogradouro = (request.Logradouro ?? "").Trim(),
            ObrDsNumero = numero,
            ObrDsComplemento = (request.Complemento ?? "").Trim(),
            ObrDsBairro = (request.Bairro ?? "").Trim(),
            ObrDsCep = cep,
            ObrNrAreaTotal = request.AreaTotal,
            ObrNrAreaTotalConstruida = request.AreaConstruida,
            ObrIdMunicipio = municipioId,
            ObrIdEmpresaContratante = idContratante > 0 ? idContratante : null,
            ObrIdEmpresaContratada = idContratada > 0 ? idContratada : null,
            ObrIdDono = donoId,
            ObrIdColaborador = colaboradorId,
            ObrNrHorasSemana = hSemana ?? 8,
            ObrNrHorasSabado = hSab ?? 4,
            ObrNrHorasDomingo = hDom ?? 0,
            ObrDsFoto = "",
            ObrDsArt = "",
            ObrCdConvite = Guid.NewGuid().ToString(),
        };

        try
        {
            _context.Obras.Add(entity);
            await _context.SaveChangesAsync(cancellationToken);

            _context.ObraColaboradores.Add(new ObraColaborador
            {
                OcoIdObra = entity.ObrIdObra,
                OcoIdColaborador = colaboradorId,
                OcoIdCargo = ocoCargo,
                OcoIdGrupo = ocoGrupo,
                OcoStContratanteContratada = stCc,
                OcoDtContratacao = DateTime.Now.Date,
            });
            await _context.SaveChangesAsync(cancellationToken);

            // Logo depois do insert (paridade prod — precisa do obr_id).
            if (!TryApplyLogo(entity, request, out var logoFail))
            {
                return logoFail!;
            }

            if (!string.IsNullOrEmpty(entity.ObrDsFoto))
            {
                await _context.SaveChangesAsync(cancellationToken);
            }
        }
        catch (DbUpdateException ex)
        {
            var detail = ex.InnerException?.Message ?? ex.Message;
            return Fail("Falha ao gravar obra no banco: " + detail);
        }

        return new ObraCadastroSaveResultDto
        {
            Ok = true,
            ObraNome = entity.ObrDsObra,
            ObraId = entity.ObrIdObra,
        };
    }

    /// <summary>
    /// Persiste logo em Uploads/{obraId}/logocontratada/ (paridade UtilsModel.UploadImage).
    /// </summary>
    private bool TryApplyLogo(Obra entity, ObraCadastroSaveRequestDto request, out ObraCadastroSaveResultDto? fail)
    {
        fail = null;
        if (request.RemoverFoto)
        {
            entity.ObrDsFoto = "";
            return true;
        }

        var foto = (request.Foto ?? "").Trim();
        if (string.IsNullOrEmpty(foto))
        {
            return true; // mantém existente
        }

        if (foto.StartsWith("/Uploads/", StringComparison.OrdinalIgnoreCase)
            || foto.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase))
        {
            entity.ObrDsFoto = NormalizeFotoUrl(foto);
            return true;
        }

        if (!foto.StartsWith("data:image", StringComparison.OrdinalIgnoreCase))
        {
            fail = Fail("Formato de imagem inválido. Use jpeg, jpg, bmp ou png (máx. 2MB).");
            return false;
        }

        try
        {
            entity.ObrDsFoto = SaveLogoContratada(entity.ObrIdObra, foto);
            return true;
        }
        catch (Exception ex)
        {
            fail = Fail("Falha ao salvar logo: " + ex.Message);
            return false;
        }
    }

    private string SaveLogoContratada(int obraId, string dataUrl)
    {
        var comma = dataUrl.IndexOf(',');
        if (comma < 0) throw new InvalidOperationException("Base64 inválido.");
        var header = dataUrl[..comma].ToLowerInvariant();
        if (!header.Contains("jpeg") && !header.Contains("jpg") && !header.Contains("png") && !header.Contains("bmp"))
        {
            throw new InvalidOperationException("Formato inválido (jpeg/jpg/bmp/png).");
        }

        var raw = dataUrl[(comma + 1)..];
        var bytes = Convert.FromBase64String(raw);
        if (bytes.Length == 0) throw new InvalidOperationException("Imagem vazia.");
        if (bytes.Length > MaxLogoBytes) throw new InvalidOperationException("Tamanho máximo: 2MB.");

        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        if (string.IsNullOrWhiteSpace(uploadsRoot))
        {
            uploadsRoot = Path.Combine(_env.ContentRootPath, "Uploads");
        }

        var folderRel = Path.Combine(obraId.ToString(), "logocontratada");
        var folderAbs = Path.Combine(uploadsRoot, folderRel);
        Directory.CreateDirectory(folderAbs);

        // Paridade prod: recria pasta da obra/logo.
        foreach (var old in Directory.EnumerateFiles(folderAbs))
        {
            try { File.Delete(old); } catch { /* ignore */ }
        }

        var fileName = Guid.NewGuid().ToString("N").ToUpperInvariant() + ".jpeg";
        var abs = Path.Combine(folderAbs, fileName);
        File.WriteAllBytes(abs, bytes);
        return "/Uploads/" + obraId + "/logocontratada/" + fileName;
    }

    private static string NormalizeFotoUrl(string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return "";
        var p = path.Trim().Replace('\\', '/');
        if (p.StartsWith("http", StringComparison.OrdinalIgnoreCase))
        {
            var idx = p.IndexOf("/Uploads/", StringComparison.OrdinalIgnoreCase);
            return idx >= 0 ? p[idx..] : p;
        }

        if (!p.StartsWith('/')) p = "/" + p;
        return p;
    }

    /// <summary>Empresas do colaborador (dono) + FKs da obra para aparecerem nos selects.</summary>
    private async Task<(IReadOnlyList<ObraCadastroLookupDto> Empresas, IReadOnlyList<int> IdsMinhas)> LoadEmpresasCadastroAsync(
        int colaboradorId,
        int idContratante,
        int idContratada,
        CancellationToken cancellationToken)
    {
        var minhas = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdColaborador == colaboradorId)
            .OrderBy(e => e.EmpNmFantasia)
            .Select(e => new ObraCadastroLookupDto { Id = e.EmpIdEmpresa, Nome = (string?)e.EmpNmFantasia ?? "" })
            .ToListAsync(cancellationToken);

        var idsMinhas = minhas.Select(e => e.Id).ToList();
        var extraIds = new[] { idContratante, idContratada }
            .Where(id => id > 0 && !idsMinhas.Contains(id))
            .Distinct()
            .ToList();

        if (extraIds.Count > 0)
        {
            var extras = await _context.Empresas.AsNoTracking()
                .Where(e => extraIds.Contains(e.EmpIdEmpresa))
                .Select(e => new ObraCadastroLookupDto { Id = e.EmpIdEmpresa, Nome = (string?)e.EmpNmFantasia ?? "" })
                .ToListAsync(cancellationToken);
            minhas = minhas.Concat(extras).OrderBy(e => e.Nome).ToList();
        }

        return (minhas, idsMinhas);
    }

    private async Task<HashSet<int>> IdsEmpresasDoUsuarioAsync(int colaboradorId, CancellationToken cancellationToken)
    {
        var ids = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdColaborador == colaboradorId)
            .Select(e => e.EmpIdEmpresa)
            .ToListAsync(cancellationToken);
        return ids.ToHashSet();
    }

    /// <summary>Paridade prod VerificarPermissaoLicencaEmpresa — conta obras onde empresa é dono.</summary>
    private async Task<bool> LicencaPermiteNovaObraAsync(int idEmpresaDono, CancellationToken cancellationToken)
    {
        var emp = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdEmpresa == idEmpresaDono)
            .Select(e => new { e.EmpIdEmpresa, e.EmpIdLicenca })
            .FirstOrDefaultAsync(cancellationToken);
        if (emp == null) return false;

        var qtdObras = await _context.Obras.AsNoTracking()
            .CountAsync(o => o.ObrIdDono == idEmpresaDono, cancellationToken);

        int limite = 0;
        if (emp.EmpIdLicenca is > 0)
        {
            limite = await _context.Licencas.AsNoTracking()
                .Where(l => l.LicIdLicenca == emp.EmpIdLicenca.Value)
                .Select(l => l.LicNrQtdObras ?? 0)
                .FirstOrDefaultAsync(cancellationToken);
        }

        return qtdObras < limite;
    }

    private static bool TryResolveEmpresas(
        ObraCadastroSaveRequestDto request,
        out int idContratante,
        out int idContratada,
        out int donoId,
        out ObraCadastroSaveResultDto? fail)
    {
        idContratante = request.IdContratante;
        idContratada = request.IdContratada;
        donoId = 0;
        fail = null;

        if (idContratante <= 0 && idContratada <= 0)
        {
            fail = Fail("Informe Contratante e/ou Contratada (pelo menos um).");
            return false;
        }

        if (idContratante > 0 && idContratante == idContratada)
        {
            fail = Fail("Contratante e Contratada não podem ser a mesma empresa.");
            return false;
        }

        // Dono = contratante se houver; senão contratada (paridade prod).
        donoId = idContratante > 0 ? idContratante : idContratada;
        return true;
    }

    /// <summary>
    /// Opção A: deriva oco_st_contratante_contratada sem radio.
    /// Match empresa do usuário → t/d; se só um lado → esse lado; se ambos e nenhum match → erro.
    /// </summary>
    private static bool TryDerivePapel(
        int idContratante,
        int idContratada,
        HashSet<int> minhas,
        out string stCc,
        out ObraCadastroSaveResultDto? fail)
    {
        stCc = "d";
        fail = null;

        var matchT = idContratante > 0 && minhas.Contains(idContratante);
        var matchD = idContratada > 0 && minhas.Contains(idContratada);

        if (matchT)
        {
            stCc = "t";
            return true;
        }

        if (matchD)
        {
            stCc = "d";
            return true;
        }

        if (idContratante > 0 && idContratada <= 0)
        {
            stCc = "t";
            return true;
        }

        if (idContratada > 0 && idContratante <= 0)
        {
            stCc = "d";
            return true;
        }

        fail = Fail(
            "Selecione sua empresa em Contratante ou Contratada (pelo menos um dos dois deve ser uma empresa sua).");
        return false;
    }

    private static bool TryValidate(
        ObraCadastroSaveRequestDto request,
        out string desc,
        out DateTime ini,
        out DateTime? fim,
        out ObraCadastroSaveResultDto? fail)
    {
        desc = (request.Descricao ?? "").Trim();
        ini = default;
        fim = null;
        fail = null;
        if (desc.Length < 3)
        {
            fail = Fail("Informe o nome da obra (min. 3 caracteres).");
            return false;
        }

        if (!TryParseDate(request.DataInicio, out ini))
        {
            fail = Fail("A Data Inicial deve ser preenchida.");
            return false;
        }

        if (!string.IsNullOrWhiteSpace(request.DataPrevisaoFim))
        {
            if (!TryParseDate(request.DataPrevisaoFim, out var parsedFim))
            {
                fail = Fail("A Data de Previsao de Fim e invalida.");
                return false;
            }

            fim = parsedFim.Date;
            if (fim < ini.Date)
            {
                fail = Fail("A Data de Previsao de Fim nao pode ser menor que a Data Inicial.");
                return false;
            }
        }

        return true;
    }

    private static ObraCadastroSaveResultDto Fail(string msg) => new() { Ok = false, ErrorMessage = msg };
    private static string FormatDate(DateTime? value) => value.HasValue ? value.Value.ToString("dd/MM/yyyy", PtBr) : "";
    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        return !string.IsNullOrWhiteSpace(value) && DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date);
    }
}
