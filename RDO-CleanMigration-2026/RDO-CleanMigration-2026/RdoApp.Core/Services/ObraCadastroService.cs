using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

public class ObraCadastroService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public ObraCadastroService(RdoDbContext context) => _context = context;

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

        var desc = (request.Descricao ?? "").Trim();
        if (desc.Length < 3) return Fail("Informe o nome da obra (min. 3 caracteres).");
        if (!TryParseDate(request.DataInicio, out var ini)) return Fail("A Data Inicial deve ser preenchida.");

        DateTime? fim = null;
        if (!string.IsNullOrWhiteSpace(request.DataPrevisaoFim))
        {
            if (!TryParseDate(request.DataPrevisaoFim, out var parsedFim)) return Fail("A Data de Previsao de Fim e invalida.");
            fim = parsedFim.Date;
            if (fim < ini.Date) return Fail("A Data de Previsao de Fim nao pode ser menor que a Data Inicial.");
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
        return new ObraCadastroSaveResultDto { Ok = true, ObraNome = entity.ObrDsObra };
    }

    private static ObraCadastroSaveResultDto Fail(string msg) => new() { Ok = false, ErrorMessage = msg };
    private static string FormatDate(DateTime? value) => value.HasValue ? value.Value.ToString("dd/MM/yyyy", PtBr) : "";
    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        return !string.IsNullOrWhiteSpace(value) && DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date);
    }
}
