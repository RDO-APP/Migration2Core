using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>Cadastro Empresa — paridade Empresa/cadastro.html · EmpresaModel.ObterRegistro/Salvar (editar obra).</summary>
public class EmpresaCadastroService
{
    private readonly RdoDbContext _context;

    public EmpresaCadastroService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<(EmpresaCadastroFormDto? Form, string? Error)> GetFormAsync(
        int empresaId,
        int colaboradorId,
        int obraId,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (empresaId <= 0)
        {
            return (null, "Selecione uma empresa na listagem. Cadastro novo de empresa não está nesta tela (prod: NOVO comentado).");
        }

        if (obraId <= 0)
        {
            return (null, "Nenhuma obra selecionada.");
        }

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrIdEmpresaContratante, o.ObrIdEmpresaContratada })
            .FirstOrDefaultAsync(cancellationToken);
        if (obra == null)
        {
            return (null, "Obra não encontrada.");
        }

        var idsObra = new List<int>();
        if (obra.ObrIdEmpresaContratante is > 0) idsObra.Add(obra.ObrIdEmpresaContratante.Value);
        if (obra.ObrIdEmpresaContratada is > 0 && !idsObra.Contains(obra.ObrIdEmpresaContratada.Value))
        {
            idsObra.Add(obra.ObrIdEmpresaContratada.Value);
        }

        if (!idsObra.Contains(empresaId))
        {
            return (null, "Empresa não pertence à obra selecionada.");
        }

        var row = await (
            from e in _context.Empresas.AsNoTracking()
            join m in _context.Municipios.AsNoTracking() on e.EmpIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            where e.EmpIdEmpresa == empresaId
            select new
            {
                e.EmpIdEmpresa,
                RazaoSocial = e.EmpDsRazaoSocial ?? "",
                NomeFantasia = e.EmpNmFantasia ?? "",
                Cnpj = e.EmpNrCnpj ?? "",
                e.EmpIdRamo,
                e.EmpIdSetor,
                Logradouro = e.EmpDsLogradouro ?? "",
                Numero = e.EmpDsNumero ?? "",
                Complemento = e.EmpDsComplemento ?? "",
                Bairro = e.EmpDsBairro ?? "",
                Cep = e.EmpDsCep ?? "",
                Telefone = e.EmpDsTelefone ?? "",
                e.EmpIdMunicipio,
                e.EmpIdColaborador,
                MunIdUf = m != null ? m.MunIdUf : 0,
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return (null, "Empresa não encontrada.");
        }

        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new EmpresaIndexLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);
        var ramos = await _context.Ramos.AsNoTracking()
            .OrderBy(r => r.RamDsRamo)
            .Select(r => new EmpresaIndexLookupDto { Id = r.RamIdRamo, Nome = r.RamDsRamo ?? "" })
            .ToListAsync(cancellationToken);
        var setores = await _context.Setores.AsNoTracking()
            .OrderBy(s => s.SetDsSetor)
            .Select(s => new EmpresaIndexLookupDto { Id = s.SetIdSetor, Nome = s.SetDsSetor ?? "" })
            .ToListAsync(cancellationToken);

        var idUf = row.MunIdUf;
        var municipios = idUf > 0
            ? await _context.Municipios.AsNoTracking()
                .Where(m => m.MunIdUf == idUf)
                .OrderBy(m => m.MunDsMunicipio)
                .Select(m => new EmpresaIndexLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
                .ToListAsync(cancellationToken)
            : [];

        return (new EmpresaCadastroFormDto
        {
            IdEmpresa = row.EmpIdEmpresa,
            RazaoSocial = row.RazaoSocial,
            NomeFantasia = row.NomeFantasia,
            Cnpj = FormatCnpj(row.Cnpj),
            IdRamo = row.EmpIdRamo ?? 0,
            IdSetor = row.EmpIdSetor ?? 0,
            Logradouro = row.Logradouro,
            NumeroEndereco = row.Numero,
            Complemento = row.Complemento,
            Bairro = row.Bairro,
            IdUf = idUf,
            IdMunicipio = row.EmpIdMunicipio ?? 0,
            Cep = FormatCep(row.Cep),
            Telefone = FormatPhone(row.Telefone),
            Editavel = row.EmpIdColaborador == colaboradorId,
            ObraNomeSessao = obraNomeSessao ?? "",
            Ufs = ufs,
            Ramos = ramos,
            Setores = setores,
            Municipios = municipios,
        }, null);
    }

    public async Task<EmpresaCadastroSaveResultDto> SaveAsync(
        int colaboradorId,
        int obraId,
        EmpresaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (request.IdEmpresa <= 0)
        {
            return Fail("Cadastro novo de empresa não suportado nesta tela.");
        }

        if (obraId <= 0)
        {
            return Fail("Nenhuma obra selecionada.");
        }

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrIdEmpresaContratante, o.ObrIdEmpresaContratada })
            .FirstOrDefaultAsync(cancellationToken);
        if (obra == null)
        {
            return Fail("Obra não encontrada.");
        }

        var idsObra = new List<int>();
        if (obra.ObrIdEmpresaContratante is > 0) idsObra.Add(obra.ObrIdEmpresaContratante.Value);
        if (obra.ObrIdEmpresaContratada is > 0 && !idsObra.Contains(obra.ObrIdEmpresaContratada.Value))
        {
            idsObra.Add(obra.ObrIdEmpresaContratada.Value);
        }

        if (!idsObra.Contains(request.IdEmpresa))
        {
            return Fail("Empresa não pertence à obra selecionada.");
        }

        var entity = await _context.Empresas
            .FirstOrDefaultAsync(e => e.EmpIdEmpresa == request.IdEmpresa, cancellationToken);
        if (entity == null)
        {
            return Fail("Empresa não encontrada.");
        }

        if (entity.EmpIdColaborador != colaboradorId)
        {
            return Fail("Sem permissão para editar esta empresa.");
        }

        var razao = (request.RazaoSocial ?? "").Trim();
        if (razao.Length < 3)
        {
            return Fail("A Razão Social deve ser preenchida (mín. 3 caracteres).");
        }

        var fantasia = (request.NomeFantasia ?? "").Trim();
        if (fantasia.Length < 3)
        {
            return Fail("O Nome Fantasia deve ser preenchido (mín. 3 caracteres).");
        }

        var cnpj = DigitsOnly(request.Cnpj);
        if (cnpj.Length != 14)
        {
            return Fail("CNPJ Inválido");
        }

        if (request.IdRamo <= 0)
        {
            return Fail("O Ramo Atividade deve ser preenchido");
        }

        if (request.IdSetor <= 0)
        {
            return Fail("O Setor deve ser preenchido");
        }

        var logradouro = (request.Logradouro ?? "").Trim();
        if (logradouro.Length < 3)
        {
            return Fail("O Logradouro deve ser preenchido (mín. 3 caracteres).");
        }

        if (request.IdMunicipio <= 0)
        {
            return Fail("O Município deve ser preenchido");
        }

        var telefone = DigitsOnly(request.Telefone);
        if (telefone.Length < 10)
        {
            return Fail("O Telefone deve ser preenchido");
        }

        var complemento = (request.Complemento ?? "").Trim();
        if (complemento.Length is > 0 and < 3)
        {
            return Fail("Por favor, introduza pelo menos três caracteres no Complemento");
        }

        var bairro = (request.Bairro ?? "").Trim();
        if (bairro.Length is > 0 and < 3)
        {
            return Fail("Por favor, introduza pelo menos três caracteres no Bairro");
        }

        entity.EmpDsRazaoSocial = razao;
        entity.EmpNmFantasia = fantasia;
        entity.EmpNrCnpj = cnpj;
        entity.EmpIdRamo = request.IdRamo;
        entity.EmpIdSetor = request.IdSetor;
        entity.EmpDsLogradouro = logradouro;
        entity.EmpDsNumero = (request.NumeroEndereco ?? "").Trim();
        entity.EmpDsComplemento = complemento;
        entity.EmpDsBairro = bairro;
        entity.EmpIdMunicipio = request.IdMunicipio;
        entity.EmpDsCep = DigitsOnly(request.Cep);
        entity.EmpDsTelefone = telefone;
        entity.EmpIdColaborador = colaboradorId;

        await _context.SaveChangesAsync(cancellationToken);
        return new EmpresaCadastroSaveResultDto { Ok = true, IdEmpresa = entity.EmpIdEmpresa };
    }

    private static EmpresaCadastroSaveResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };

    private static string DigitsOnly(string? value) =>
        string.IsNullOrWhiteSpace(value) ? "" : new string(value.Where(char.IsDigit).ToArray());

    private static string FormatCnpj(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length != 14) return raw?.Trim() ?? "";
        return $"{d[..2]}.{d[2..5]}.{d[5..8]}/{d[8..12]}-{d[12..]}";
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
        if (d.Length == 11) return $"({d[..2]}){d[2..7]}-{d[7..]}";
        if (d.Length == 10) return $"({d[..2]}){d[2..6]}-{d[6..]}";
        return raw?.Trim() ?? "";
    }
}
