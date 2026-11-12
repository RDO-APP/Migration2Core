using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Cadastro Colaborador — paridade Colaborador/cadastro.html · ColaboradorModel.ObterRegistro/Salvar.</summary>
public class ColaboradorCadastroService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public ColaboradorCadastroService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<(ColaboradorCadastroFormDto? Form, string? Error)> GetFormAsync(
        HttpContext httpContext,
        int colaboradorId,
        int obraId,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return (null, "Nenhuma obra selecionada.");
        }

        var lookups = await LoadLookupsAsync(cancellationToken);
        var isNew = colaboradorId <= 0;
        var canNovo = ColaboradorIndexService.CanColaboradorIndex(httpContext, "editar");
        var canEditar = canNovo;

        if (isNew)
        {
            if (!canNovo)
            {
                return (null, "Sem permissão para criar colaborador.");
            }

            return (new ColaboradorCadastroFormDto
            {
                Sexo = "S",
                PodeSalvar = true,
                ExigeSenha = true,
                ObraNomeSessao = obraNomeSessao ?? "",
                Ufs = lookups.Ufs,
                Cargos = lookups.Cargos,
                Grupos = lookups.Grupos,
            }, null);
        }

        var row = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join c in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals c.ColIdColaborador
            join m in _context.Municipios.AsNoTracking() on c.ColIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            where oc.OcoIdObra == obraId && c.ColIdColaborador == colaboradorId
            select new
            {
                c.ColIdColaborador,
                Nome = c.ColNmColaborador ?? "",
                Cpf = c.ColNrCpf ?? "",
                Sexo = c.ColDsSexo ?? "S",
                c.ColDtNascimento,
                TelefonePrincipal = c.ColDsTelefonePrincipal ?? "",
                TelefoneSecundario = c.ColDsTelefoneSecundario ?? "",
                Email = c.ColDsEmail ?? "",
                Crea = c.ColDsCrea ?? "",
                Logradouro = c.ColDsLogradouro ?? "",
                Numero = c.ColDsNumero ?? "",
                Complemento = c.ColDsComplemento ?? "",
                Bairro = c.ColDsBairro ?? "",
                Cep = c.ColDsCep ?? "",
                c.ColIdMunicipio,
                MunIdUf = m != null ? m.MunIdUf : 0,
                oc.OcoIdCargo,
                oc.OcoIdGrupo,
                oc.OcoDtContratacao,
                Lado = oc.OcoStContratanteContratada ?? "",
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return (null, "Colaborador não encontrado nesta obra.");
        }

        var meuLado = LoginSessionHelper.GetContratanteContratadaUsuario(httpContext) ?? "";
        var mesmoLado = string.IsNullOrEmpty(row.Lado) || row.Lado == meuLado;
        var idUf = row.MunIdUf;
        var municipios = idUf > 0
            ? await _context.Municipios.AsNoTracking()
                .Where(m => m.MunIdUf == idUf)
                .OrderBy(m => m.MunDsMunicipio)
                .Select(m => new ColaboradorIndexLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
                .ToListAsync(cancellationToken)
            : [];

        return (new ColaboradorCadastroFormDto
        {
            IdColaborador = row.ColIdColaborador,
            Cpf = FormatCpf(row.Cpf),
            IdGrupo = row.OcoIdGrupo,
            Nome = row.Nome,
            IdCargo = row.OcoIdCargo,
            Sexo = string.IsNullOrWhiteSpace(row.Sexo) ? "S" : row.Sexo,
            DataNascimento = FormatDate(row.ColDtNascimento),
            TelefonePrincipal = FormatPhone(row.TelefonePrincipal),
            TelefoneSecundario = FormatPhone(row.TelefoneSecundario),
            Email = row.Email,
            Crea = row.Crea,
            DataContratacao = FormatDate(row.OcoDtContratacao),
            Logradouro = row.Logradouro,
            NumeroEndereco = row.Numero,
            Complemento = row.Complemento,
            Bairro = row.Bairro,
            IdUf = idUf,
            IdMunicipio = row.ColIdMunicipio ?? 0,
            Cep = FormatCep(row.Cep),
            PodeSalvar = canEditar && mesmoLado,
            ExigeSenha = false,
            ObraNomeSessao = obraNomeSessao ?? "",
            Ufs = lookups.Ufs,
            Cargos = lookups.Cargos,
            Grupos = lookups.Grupos,
            Municipios = municipios,
        }, null);
    }

    public async Task<ColaboradorCadastroSaveResultDto> SaveAsync(
        HttpContext httpContext,
        int obraId,
        ColaboradorCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return Fail("Nenhuma obra selecionada.");
        }

        if (!ColaboradorIndexService.CanColaboradorIndex(httpContext, "editar"))
        {
            return Fail("Sem permissão para salvar colaborador.");
        }

        var nome = (request.Nome ?? "").Trim();
        if (nome.Length < 3)
        {
            return Fail("O nome do colaborador deve ser preenchido");
        }

        if (request.IdCargo <= 0)
        {
            return Fail("O cargo do colaborador deve ser preenchido");
        }

        if (request.IdGrupo <= 0)
        {
            return Fail("O perfil do colaborador deve ser preenchido");
        }

        var isNew = request.IdColaborador <= 0;
        var senha = request.Senha ?? "";
        var conf = request.ConfirmacaoSenha ?? "";
        if (isNew || !string.IsNullOrWhiteSpace(senha) || !string.IsNullOrWhiteSpace(conf))
        {
            if (string.IsNullOrWhiteSpace(senha))
            {
                return Fail("A Senha deve ser preenchida");
            }

            if (senha != conf)
            {
                return Fail("A confirmação de senha não confere");
            }
        }

        var cpf = DigitsOnly(request.Cpf);
        Colaborador colaborador;
        if (isNew)
        {
            if (!string.IsNullOrEmpty(cpf))
            {
                var existing = await _context.Colaboradores
                    .FirstOrDefaultAsync(c => c.ColNrCpf == cpf, cancellationToken);
                if (existing != null)
                {
                    colaborador = existing;
                    ApplyPersonFields(colaborador, request, cpf, updatePassword: false);
                }
                else
                {
                    colaborador = new Colaborador
                    {
                        ColNrCpf = cpf,
                        ColNmColaborador = nome,
                        ColDsSenha = Seguranca.EncryptTripleDES(senha),
                    };
                    ApplyPersonFields(colaborador, request, cpf, updatePassword: false);
                    _context.Colaboradores.Add(colaborador);
                }
            }
            else
            {
                colaborador = new Colaborador
                {
                    ColNrCpf = "",
                    ColNmColaborador = nome,
                    ColDsSenha = Seguranca.EncryptTripleDES(senha),
                };
                ApplyPersonFields(colaborador, request, "", updatePassword: false);
                _context.Colaboradores.Add(colaborador);
            }

            await _context.SaveChangesAsync(cancellationToken);
        }
        else
        {
            colaborador = await _context.Colaboradores
                .FirstOrDefaultAsync(c => c.ColIdColaborador == request.IdColaborador, cancellationToken)
                ?? null!;
            if (colaborador == null)
            {
                return Fail("Colaborador não encontrado.");
            }

            var link = await _context.ObraColaboradores.AsNoTracking()
                .FirstOrDefaultAsync(
                    oc => oc.OcoIdObra == obraId && oc.OcoIdColaborador == request.IdColaborador,
                    cancellationToken);
            if (link == null)
            {
                return Fail("Colaborador não está nesta obra.");
            }

            var meuLado = LoginSessionHelper.GetContratanteContratadaUsuario(httpContext) ?? "";
            if (!string.IsNullOrEmpty(link.OcoStContratanteContratada)
                && !string.IsNullOrEmpty(meuLado)
                && link.OcoStContratanteContratada != meuLado)
            {
                return Fail("Sem permissão para editar este colaborador.");
            }

            ApplyPersonFields(colaborador, request, cpf, updatePassword: !string.IsNullOrWhiteSpace(senha));
            if (!string.IsNullOrWhiteSpace(senha))
            {
                colaborador.ColDsSenha = Seguranca.EncryptTripleDES(senha);
            }
        }

        var grupo = await _context.Grupos.AsNoTracking()
            .FirstOrDefaultAsync(g => g.GruIdGrupo == request.IdGrupo, cancellationToken);
        if (grupo == null)
        {
            return Fail("Perfil (grupo) inválido.");
        }

        var lado = grupo.GruStContratante == 1 ? "t" : grupo.GruStContratante == 2 ? "d" : "";
        var obraColab = await _context.ObraColaboradores
            .FirstOrDefaultAsync(
                oc => oc.OcoIdObra == obraId && oc.OcoIdColaborador == colaborador.ColIdColaborador,
                cancellationToken);

        DateTime? dataContrato = null;
        var rawContrato = (request.DataContratacao ?? "").Trim();
        if (rawContrato.Length > 0 && rawContrato != "__/__/____")
        {
            if (!DateTime.TryParseExact(rawContrato, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out var parsed))
            {
                return Fail("Data da Contratação inválida.");
            }

            dataContrato = parsed.Date;
        }

        if (obraColab == null)
        {
            obraColab = new ObraColaborador
            {
                OcoIdObra = obraId,
                OcoIdColaborador = colaborador.ColIdColaborador,
                OcoStContratanteContratada = lado,
            };
            _context.ObraColaboradores.Add(obraColab);
        }

        obraColab.OcoIdCargo = request.IdCargo;
        obraColab.OcoIdGrupo = request.IdGrupo;
        obraColab.OcoDtContratacao = dataContrato;
        if (!string.IsNullOrEmpty(lado))
        {
            obraColab.OcoStContratanteContratada = lado;
        }
        else if (string.IsNullOrEmpty(obraColab.OcoStContratanteContratada))
        {
            obraColab.OcoStContratanteContratada =
                LoginSessionHelper.GetContratanteContratadaUsuario(httpContext) ?? "d";
        }

        await _context.SaveChangesAsync(cancellationToken);
        return new ColaboradorCadastroSaveResultDto { Ok = true, IdColaborador = colaborador.ColIdColaborador };
    }

    private void ApplyPersonFields(
        Colaborador c,
        ColaboradorCadastroSaveRequestDto request,
        string cpf,
        bool updatePassword)
    {
        c.ColNmColaborador = (request.Nome ?? "").Trim();
        if (!string.IsNullOrEmpty(cpf))
        {
            c.ColNrCpf = cpf;
        }

        var sexo = (request.Sexo ?? "S").Trim();
        c.ColDsSexo = sexo is "M" or "F" ? sexo : c.ColDsSexo;

        var rawNasc = (request.DataNascimento ?? "").Trim();
        if (rawNasc.Length > 0 && rawNasc != "__/__/____"
            && DateTime.TryParseExact(rawNasc, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out var nasc))
        {
            c.ColDtNascimento = nasc.Date;
        }

        c.ColDsTelefonePrincipal = DigitsOnly(request.TelefonePrincipal);
        c.ColDsTelefoneSecundario = DigitsOnly(request.TelefoneSecundario);
        c.ColDsEmail = (request.Email ?? "").Trim();
        c.ColDsCrea = (request.Crea ?? "").Trim();
        c.ColDsLogradouro = (request.Logradouro ?? "").Trim();
        c.ColDsNumero = (request.NumeroEndereco ?? "").Trim();
        c.ColDsComplemento = (request.Complemento ?? "").Trim();
        c.ColDsBairro = (request.Bairro ?? "").Trim();
        c.ColDsCep = DigitsOnly(request.Cep);
        if (request.IdMunicipio > 0)
        {
            c.ColIdMunicipio = request.IdMunicipio;
        }

        _ = updatePassword;
    }

    private async Task<(
        List<ColaboradorIndexLookupDto> Ufs,
        List<ColaboradorIndexLookupDto> Cargos,
        List<ColaboradorIndexLookupDto> Grupos)> LoadLookupsAsync(CancellationToken cancellationToken)
    {
        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new ColaboradorIndexLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);
        var cargos = await _context.Cargos.AsNoTracking()
            .OrderBy(c => c.CarDsCargo)
            .Select(c => new ColaboradorIndexLookupDto { Id = c.CarIdCargo, Nome = c.CarDsCargo ?? "" })
            .ToListAsync(cancellationToken);
        var grupos = await _context.Grupos.AsNoTracking()
            .OrderBy(g => g.GruNmNome)
            .Select(g => new ColaboradorIndexLookupDto { Id = g.GruIdGrupo, Nome = g.GruNmNome ?? "" })
            .ToListAsync(cancellationToken);
        return (ufs, cargos, grupos);
    }

    private static ColaboradorCadastroSaveResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };

    private static string DigitsOnly(string? value) =>
        string.IsNullOrWhiteSpace(value) ? "" : new string(value.Where(char.IsDigit).ToArray());

    private static string FormatDate(DateTime? value) =>
        value.HasValue ? value.Value.ToString("dd/MM/yyyy", PtBr) : "";

    private static string FormatCpf(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length != 11) return raw?.Trim() ?? "";
        return $"{d[..3]}.{d[3..6]}.{d[6..9]}-{d[9..]}";
    }

    private static string FormatCep(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length != 8) return raw?.Trim() ?? "";
        return $"{d[..5]}-{d[5..]}";
    }

    private static string FormatPhone(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length == 11) return $"({d[..2]}) {d[2..7]}-{d[7..]}";
        if (d.Length == 10) return $"({d[..2]}) {d[2..6]}-{d[6..]}";
        return raw?.Trim() ?? "";
    }
}
