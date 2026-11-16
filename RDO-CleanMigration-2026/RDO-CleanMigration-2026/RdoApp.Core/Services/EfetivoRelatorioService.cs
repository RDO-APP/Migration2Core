using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>Paridade prod <c>api/efetivo/gerarrelatorio</c> + <c>RelatorioEfetivoModel</c> (QuestPDF / CSV-xls).</summary>
public sealed class EfetivoRelatorioService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private static readonly Color Navy = Color.FromHex("#28496f");

    static EfetivoRelatorioService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    private readonly RdoDbContext _context;

    public EfetivoRelatorioService(RdoDbContext context) => _context = context;

    public async Task<(byte[] Bytes, string ContentType, string FileName)> GenerateAsync(
        int obraId,
        string? obraNome,
        EfetivoRelatorioRequestDto request,
        CancellationToken ct)
    {
        if (!TryParseDate(request.DataInicial, out var ini))
            throw new InvalidOperationException("Por favor, escolha a Data Inicial.");
        if (!TryParseDate(request.DataFinal, out var fim))
            throw new InvalidOperationException("Por favor, escolha a Data Final.");
        if (ini.Date > fim.Date)
            throw new InvalidOperationException("A Data Final não pode ser menor que a Data Inicial.");

        var diaIni = ini.Date;
        var diaFimExcl = fim.Date.AddDays(1);

        var nomeObra = string.IsNullOrWhiteSpace(obraNome)
            ? await _context.Obras.AsNoTracking()
                .Where(o => o.ObrIdObra == obraId)
                .Select(o => o.ObrDsObra)
                .FirstOrDefaultAsync(ct) ?? ""
            : obraNome;

        var rows = await (
            from e in _context.Efetivos.AsNoTracking()
            join oc in _context.ObraColaboradores.AsNoTracking() on e.EfeIdObraColaborador equals oc.OcoIdObraColaborador
            join c in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals c.ColIdColaborador
            join car in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals car.CarIdCargo into cars
            from car in cars.DefaultIfEmpty()
            join st in _context.EfetivoStatuses.AsNoTracking() on e.EfeIdEfetivoStatus equals st.EstIdEfetivoStatus
            where e.EfeIdObra == obraId && e.EfeData >= diaIni && e.EfeData < diaFimExcl
            orderby e.EfeData, c.ColNmColaborador
            select new RelatorioLinha(
                e.EfeData,
                c.ColNmColaborador ?? "",
                car != null ? car.CarDsCargo ?? "" : "",
                st.EstDsEfetivoStatus ?? "")
        ).ToListAsync(ct);

        var counts = rows
            .GroupBy(r => r.Status, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.Count(), StringComparer.OrdinalIgnoreCase);

        int Q(string nome) => counts.TryGetValue(nome, out var n) ? n : 0;

        var periodo = $"De {diaIni:dd/MM/yyyy} Até {fim.Date:dd/MM/yyyy}";
        var tipo = (request.TipoRelatorio ?? "PDF").Trim();
        var labelIni = diaIni.ToString("dd_MM_yyyy", PtBr);
        var labelFim = fim.Date.ToString("dd_MM_yyyy", PtBr);

        if (tipo.Equals("Excel", StringComparison.OrdinalIgnoreCase)
            || tipo.Equals("xls", StringComparison.OrdinalIgnoreCase)
            || tipo.Equals("xlsx", StringComparison.OrdinalIgnoreCase))
        {
            var bytes = BuildExcelBytes(nomeObra, periodo, rows, Q("Presente"), Q("Ausente"), Q("Em falta"), Q("De folga"));
            return (bytes, "application/vnd.ms-excel", $"EfetivoDiario_{labelIni}_{labelFim}.xls");
        }

        var pdf = BuildPdf(nomeObra, periodo, rows, Q("Presente"), Q("Ausente"), Q("Em falta"), Q("De folga"));
        return (pdf, "application/pdf", $"EfetivoDiario_{labelIni}_{labelFim}.pdf");
    }

    private static byte[] BuildExcelBytes(
        string obra,
        string periodo,
        IReadOnlyList<RelatorioLinha> rows,
        int presente,
        int ausente,
        int emFalta,
        int deFolga)
    {
        var sb = new StringBuilder();
        sb.Append('\uFEFF');
        sb.AppendLine("Relatório de Efetivo Diário");
        sb.AppendLine($"Obra\t{obra}");
        sb.AppendLine($"Período\t{periodo}");
        sb.AppendLine($"Presente\t{presente}\tAusente\t{ausente}\tEm falta\t{emFalta}\tDe folga\t{deFolga}");
        sb.AppendLine();
        sb.AppendLine("Data\tNome\tCargo\tSituação");
        foreach (var r in rows)
        {
            sb.Append(r.Data.ToString("dd/MM/yyyy", PtBr)).Append('\t')
                .Append(Esc(r.Nome)).Append('\t')
                .Append(Esc(r.Cargo)).Append('\t')
                .Append(Esc(r.Status)).AppendLine();
        }

        return Encoding.UTF8.GetBytes(sb.ToString());
    }

    private static string Esc(string s) => s.Replace('\t', ' ').Replace('\r', ' ').Replace('\n', ' ');

    private static byte[] BuildPdf(
        string obra,
        string periodo,
        IReadOnlyList<RelatorioLinha> rows,
        int presente,
        int ausente,
        int emFalta,
        int deFolga)
    {
        return Document.Create(doc =>
        {
            doc.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(28);
                page.DefaultTextStyle(t => t.FontSize(9));

                page.Header().Column(col =>
                {
                    col.Item().Background(Navy).Padding(8).Text("RELATÓRIO DE EFETIVO DIÁRIO")
                        .FontColor(Colors.White).SemiBold().FontSize(14);
                    col.Item().PaddingTop(8).Text($"Obra: {obra}").SemiBold();
                    col.Item().Text($"Período: {periodo}");
                    col.Item().PaddingTop(4).Text(
                        $"Presente: {presente}  ·  Ausente: {ausente}  ·  Em falta: {emFalta}  ·  De folga: {deFolga}");
                });

                page.Content().PaddingTop(12).Table(table =>
                {
                    table.ColumnsDefinition(c =>
                    {
                        c.ConstantColumn(70);
                        c.RelativeColumn(2);
                        c.RelativeColumn(2);
                        c.RelativeColumn(1.2f);
                    });

                    table.Header(h =>
                    {
                        void Head(string t) => h.Cell().Background(Navy).Padding(4)
                            .Text(t).FontColor(Colors.White).SemiBold();
                        Head("Data");
                        Head("Nome");
                        Head("Cargo");
                        Head("Situação");
                    });

                    if (rows.Count == 0)
                    {
                        table.Cell().ColumnSpan(4).Padding(8).Text("Nenhum registro no período.");
                    }
                    else
                    {
                        foreach (var r in rows)
                        {
                            table.Cell().BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(3)
                                .Text(r.Data.ToString("dd/MM/yyyy", PtBr));
                            table.Cell().BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(3).Text(r.Nome);
                            table.Cell().BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(3).Text(r.Cargo);
                            table.Cell().BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(3).Text(r.Status);
                        }
                    }
                });

                page.Footer().AlignRight().Text(t =>
                {
                    t.Span("RDO App · ").FontSize(8).FontColor("#555");
                    t.CurrentPageNumber().FontSize(8);
                    t.Span(" / ").FontSize(8);
                    t.TotalPages().FontSize(8);
                });
            });
        }).GeneratePdf();
    }

    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(value)) return false;
        var v = value.Trim();
        return DateTime.TryParseExact(v, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date)
               || DateTime.TryParseExact(v, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date)
               || DateTime.TryParse(v, PtBr, DateTimeStyles.None, out date);
    }

    private readonly record struct RelatorioLinha(DateTime Data, string Nome, string Cargo, string Status);
}
