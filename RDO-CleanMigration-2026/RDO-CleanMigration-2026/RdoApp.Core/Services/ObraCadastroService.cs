using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

public class ObraCadastroService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public ObraCadastroService(RdoDbContext context) => _context = context;

    public ObraCadastroDto EmptyNova(string? cidadeEstado = null) => new()
    {
        Id = 0,
        Nova = true,
        CidadeEstado = cidadeEstado ?? "",
    };

    public async Task<ObraCadastroDto?> GetAsync(int obraId, CancellationToken cancellationToken)
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
                o.ObrDsBairro,
                o.ObrDsCep,
                o.ObrNrAreaTotal,
                o.ObrNrAreaTotalConstruida,
                Mun = m != null ? m.MunDsMunicipio : null,
                Uf = uf != null ? uf.UfeDsSigla : null
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null) return null;
        var cidade = string.IsNullOrWhiteSpace(row.Mun)
            ? ""
            : string.IsNullOrWhiteSpace(row.Uf) ? row.Mun! : row.Mun + "/" + row.Uf;

        return new ObraCadastroDto
        {
            Id = row.ObrIdObra,
            Nova = false,
            Descricao = row.ObrDsObra ?? "",
            DataInicio = FormatDate(row.ObrDtInicio),
            DataPrevisaoFim = FormatDate(row.ObrDtPrevisaoFim),
            Logradouro = row.ObrDsLogradouro ?? "",
            Numero = row.ObrDsNumero ?? "",
            Bairro = row.ObrDsBairro ?? "",
            Cep = row.ObrDsCep ?? "",
            AreaTotal = row.ObrNrAreaTotal,
            AreaConstruida = row.ObrNrAreaTotalConstruida,
            CidadeEstado = cidade,
            Finalizada = row.ObrDtFim != null
        };
    }

    public async Task<ObraCadastroSaveResultDto> SaveAsync(int obraId, ObraCadastroSaveRequestDto request, CancellationToken cancellationToken)
    {
        var entity = await _context.Obras.FirstOrDefaultAsync(o => o.ObrIdObra == obraId, cancellationToken);
        if (entity == null) return Fail("Obra nao encontrada.");
        if (entity.ObrDtFim != null) return Fail("Obra finalizada — edicao bloqueada.");

        if (!TryValidate(request, out var desc, out var ini, out var fim, out var fail))
        {
            return fail!;
        }

        entity.ObrDsObra = desc;
        entity.ObrDtInicio = ini.Date;
        entity.ObrDtPrevisaoFim = fim;
        entity.ObrDsLogradouro = (request.Logradouro ?? "").Trim();
        entity.ObrDsNumero = (request.Numero ?? "").Trim();
        entity.ObrDsBairro = (request.Bairro ?? "").Trim();
        entity.ObrDsCep = (request.Cep ?? "").Trim();
        entity.ObrNrAreaTotal = request.AreaTotal;
        entity.ObrNrAreaTotalConstruida = request.AreaConstruida;
        await _context.SaveChangesAsync(cancellationToken);
        return new ObraCadastroSaveResultDto { Ok = true, ObraNome = entity.ObrDsObra, ObraId = entity.ObrIdObra };
    }

    /// <summary>
    /// Nova obra: clona empresa/município/vínculo do colaborador a partir da obra da sessão (template).
    /// Paridade mínima com prod `novaObra` — sem tela completa de contratante/logo ainda.
    /// </summary>
    public async Task<ObraCadastroSaveResultDto> CreateAsync(
        int colaboradorId,
        int templateObraId,
        ObraCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!TryValidate(request, out var desc, out var ini, out var fim, out var fail))
        {
            return fail!;
        }

        var template = await _context.Obras.AsNoTracking()
            .FirstOrDefaultAsync(o => o.ObrIdObra == templateObraId, cancellationToken);
        if (template == null)
        {
            return Fail("Obra modelo da sessão não encontrada.");
        }

        if (template.ObrIdDono is null or <= 0
            && template.ObrIdEmpresaContratante is null or <= 0
            && template.ObrIdEmpresaContratada is null or <= 0)
        {
            return Fail("A obra modelo precisa ter empresa (dono/contratante/contratada) para criar nova.");
        }

        var vinculo = await _context.ObraColaboradores.AsNoTracking()
            .FirstOrDefaultAsync(
                o => o.OcoIdObra == templateObraId && o.OcoIdColaborador == colaboradorId,
                cancellationToken);
        if (vinculo == null)
        {
            return Fail("Você não está vinculado à obra da sessão — não é possível criar nova obra.");
        }

        var entity = new Obra
        {
            ObrDsObra = desc,
            ObrDtInicio = ini.Date,
            ObrDtPrevisaoFim = fim,
            ObrDsLogradouro = (request.Logradouro ?? "").Trim(),
            ObrDsNumero = (request.Numero ?? "").Trim(),
            ObrDsBairro = (request.Bairro ?? "").Trim(),
            ObrDsCep = (request.Cep ?? "").Trim(),
            ObrNrAreaTotal = request.AreaTotal,
            ObrNrAreaTotalConstruida = request.AreaConstruida,
            ObrIdMunicipio = template.ObrIdMunicipio,
            ObrIdEmpresaContratante = template.ObrIdEmpresaContratante,
            ObrIdEmpresaContratada = template.ObrIdEmpresaContratada,
            ObrIdDono = template.ObrIdDono
                ?? template.ObrIdEmpresaContratante
                ?? template.ObrIdEmpresaContratada,
            ObrIdColaborador = colaboradorId,
            ObrNrHorasSemana = template.ObrNrHorasSemana ?? 8,
            ObrNrHorasSabado = template.ObrNrHorasSabado ?? 4,
            ObrNrHorasDomingo = template.ObrNrHorasDomingo ?? 0,
            ObrDsFoto = "",
            ObrDsComplemento = "",
            ObrDsArt = "",
            ObrCdConvite = Guid.NewGuid().ToString("N")[..12],
        };

        _context.Obras.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        _context.ObraColaboradores.Add(new ObraColaborador
        {
            OcoIdObra = entity.ObrIdObra,
            OcoIdColaborador = colaboradorId,
            OcoIdCargo = vinculo.OcoIdCargo,
            OcoIdGrupo = vinculo.OcoIdGrupo,
            OcoStContratanteContratada = vinculo.OcoStContratanteContratada ?? "d",
            OcoDtContratacao = DateTime.Now.Date,
        });
        await _context.SaveChangesAsync(cancellationToken);

        return new ObraCadastroSaveResultDto
        {
            Ok = true,
            ObraNome = entity.ObrDsObra,
            ObraId = entity.ObrIdObra,
        };
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
