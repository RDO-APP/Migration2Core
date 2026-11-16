using System.Globalization;
using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RdoApp.Core.Data;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>
/// Paridade prod api/efetivo/gerarrelatorio + RelatorioEfetivoDiario.rdlc
/// (logo · EFETIVO DIÁRIO · PERÍODO/OBRA · totais coloridos · DATA/CARGO/NOME/STATUS).
/// PDF = QuestPDF. Excel = HTML SpreadsheetML-lite (Excel abre .xls) — sem ClosedXML.
/// </summary>
public sealed class EfetivoRelatorioService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private static readonly Color Navy = Color.FromHex("#28496f");
    private static readonly Color CorPresente = Color.FromHex("#1565C0");
    private static readonly Color CorEmFalta = Color.FromHex("#C62828");
    private static readonly Color CorAusente = Color.FromHex("#E64A19");
    private static readonly Color CorDeFolga = Color.FromHex("#2E7D32");

    static EfetivoRelatorioService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public EfetivoRelatorioService(
        RdoDbContext context,
        IConfiguration configuration,
        IWebHostEnvironment env)
    {
        _context = context;
        _configuration = configuration;
        _env = env;
    }

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
        var diaFim = fim.Date;
        var diaFimExcl = diaFim.AddDays(1);

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrDsObra, o.ObrDsFoto })
            .FirstOrDefaultAsync(ct);

        var nomeObra = !string.IsNullOrWhiteSpace(obraNome)
            ? obraNome!
            : (obra?.ObrDsObra ?? "");

        var rows = await (
            from e in _context.Efetivos.AsNoTracking()
            join oc in _context.ObraColaboradores.AsNoTracking() on e.EfeIdObraColaborador equals oc.OcoIdObraColaborador
            join c in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals c.ColIdColaborador
            join car in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals car.CarIdCargo into cars
            from car in cars.DefaultIfEmpty()
            join st in _context.EfetivoStatuses.AsNoTracking() on e.EfeIdEfetivoStatus equals st.EstIdEfetivoStatus
            where e.EfeIdObra == obraId && e.EfeData >= diaIni && e.EfeData < diaFimExcl
            orderby e.EfeData, car != null ? car.CarDsCargo : "", c.ColNmColaborador
            select new RelatorioLinha(
                e.EfeData,
                c.ColNmColaborador ?? "",
                car != null ? car.CarDsCargo ?? "" : "",
                st.EstDsEfetivoStatus ?? "",
                st.EstDsColor ?? "")
        ).ToListAsync(ct);

        var counts = rows
            .GroupBy(r => r.Status, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.Count(), StringComparer.OrdinalIgnoreCase);

        int Q(string nome) => counts.TryGetValue(nome, out var n) ? n : 0;
        var qPresente = Q("Presente");
        var qAusente = Q("Ausente");
        var qEmFalta = Q("Em falta");
        var qDeFolga = Q("De folga");

        var periodo = $"De {diaIni:dd/MM/yyyy} Até {diaFim:dd/MM/yyyy}";
        var logoBytes = TryLoadLogoBytes(obra?.ObrDsFoto);
        var tipo = (request.TipoRelatorio ?? "PDF").Trim();
        var labelIni = diaIni.ToString("dd_MM_yyyy", PtBr);
        var labelFim = diaFim.ToString("dd_MM_yyyy", PtBr);

        if (tipo.Equals("Excel", StringComparison.OrdinalIgnoreCase)
            || tipo.Equals("xls", StringComparison.OrdinalIgnoreCase)
            || tipo.Equals("xlsx", StringComparison.OrdinalIgnoreCase))
        {
            var bytes = BuildExcelHtml(nomeObra, periodo, rows, qPresente, qAusente, qEmFalta, qDeFolga, logoBytes);
            return (bytes, "application/vnd.ms-excel", $"EfetivoDiario_{labelIni}_{labelFim}.xls");
        }

        var pdf = BuildPdf(nomeObra, periodo, rows, qPresente, qAusente, qEmFalta, qDeFolga, logoBytes);
        return (pdf, "application/pdf", $"EfetivoDiario_{labelIni}_{labelFim}.pdf");
    }

    private byte[]? TryLoadLogoBytes(string? obraFoto)
    {
        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        if (string.IsNullOrWhiteSpace(uploadsRoot))
            uploadsRoot = Path.Combine(_env.ContentRootPath, "Uploads");

        var webRoot = _env.WebRootPath;
        var contentRoot = _env.ContentRootPath;
        var relatives = new List<string>();
        if (!string.IsNullOrWhiteSpace(obraFoto))
            relatives.Add(obraFoto.Trim());
        relatives.AddRange(new[]
        {
            "/images/logo.jpg",
            "/Assets/images/logo.jpg",
            "images/logo.jpg",
            "Assets/images/logo.jpg",
            "wwwroot/images/logo.jpg",
        });

        var roots = new[]
        {
            uploadsRoot,
            webRoot,
            contentRoot,
            string.IsNullOrWhiteSpace(contentRoot) ? null : Path.Combine(contentRoot, "wwwroot"),
        };

        foreach (var rel in relatives.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            var trimmed = rel.Replace('\\', '/').Trim();
            if (trimmed.StartsWith("/Uploads/", StringComparison.OrdinalIgnoreCase))
                trimmed = trimmed["/Uploads/".Length..];
            else if (trimmed.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase))
                trimmed = trimmed["Uploads/".Length..];
            trimmed = trimmed.TrimStart('/');
            var asFs = trimmed.Replace('/', Path.DirectorySeparatorChar);
            foreach (var root in roots)
            {
                if (string.IsNullOrWhiteSpace(root)) continue;
                var physical = Path.Combine(root.TrimEnd('\\', '/'), asFs);
                if (File.Exists(physical))
                    return File.ReadAllBytes(physical);
            }
        }

        return null;
    }

    private static string StatusHex(string status, string dbColor)
    {
        if (!string.IsNullOrWhiteSpace(dbColor) && dbColor.Trim().StartsWith('#'))
            return dbColor.Trim();
        return status.Trim().ToLowerInvariant() switch
        {
            "presente" => "#1565C0",
            "ausente" => "#E64A19",
            "em falta" => "#C62828",
            "de folga" => "#2E7D32",
            _ => "#333333",
        };
    }

    private static Color StatusQuestColor(string status, string dbColor)
    {
        try
        {
            return Color.FromHex(StatusHex(status, dbColor).TrimStart('#'));
        }
        catch
        {
            return Colors.Grey.Darken2;
        }
    }

    private static byte[] BuildExcelHtml(
        string obra,
        string periodo,
        IReadOnlyList<RelatorioLinha> rows,
        int presente,
        int ausente,
        int emFalta,
        int deFolga,
        byte[]? logoBytes)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
        sb.AppendLine("<head><meta charset=\"utf-8\"/>");
        sb.AppendLine("<style>");
        sb.AppendLine("table{border-collapse:collapse;font-family:Arial,sans-serif;font-size:11pt;}");
        sb.AppendLine("td,th{border:1px solid #000;padding:4px 6px;}");
        sb.AppendLine(".title{font-size:16pt;font-weight:bold;text-align:center;}");
        sb.AppendLine(".meta{font-weight:bold;}");
        sb.AppendLine(".c-presente{color:#1565C0;font-weight:bold;}");
        sb.AppendLine(".c-emfalta{color:#C62828;font-weight:bold;}");
        sb.AppendLine(".c-ausente{color:#E64A19;font-weight:bold;}");
        sb.AppendLine(".c-folga{color:#2E7D32;font-weight:bold;}");
        sb.AppendLine(".head{background:#D9D9D9;font-weight:bold;text-align:center;}");
        sb.AppendLine("</style></head><body>");
        sb.AppendLine("<table>");
        sb.AppendLine("<tr>");
        sb.Append("<td rowspan=\"2\" style=\"width:120px;text-align:center;vertical-align:middle;\">");
        sb.Append(ExcelHtmlLogoEmbed.LogoCellHtml(logoBytes, 100, 60));
        sb.AppendLine("</td>");
        sb.AppendLine("<td colspan=\"2\" class=\"title\">EFETIVO DIÁRIO</td>");
        sb.AppendLine($"<td class=\"meta\">PERÍODO: {WebUtility.HtmlEncode(periodo)}</td>");
        sb.AppendLine("</tr>");
        sb.AppendLine("<tr>");
        sb.AppendLine("<td colspan=\"2\">&nbsp;</td>");
        sb.AppendLine($"<td class=\"meta\">OBRA: {WebUtility.HtmlEncode(obra)}</td>");
        sb.AppendLine("</tr>");
        sb.AppendLine("<tr>");
        sb.AppendLine($"<td class=\"c-presente\">PRESENTE: {presente}</td>");
        sb.AppendLine($"<td class=\"c-emfalta\">EM FALTA: {emFalta}</td>");
        sb.AppendLine($"<td class=\"c-ausente\">AUSENTE: {ausente}</td>");
        sb.AppendLine($"<td class=\"c-folga\">DE FOLGA: {deFolga}</td>");
        sb.AppendLine("</tr>");
        sb.AppendLine("<tr><td colspan=\"4\">&nbsp;</td></tr>");
        sb.AppendLine("<tr class=\"head\"><th>DATA</th><th>CARGO</th><th>NOME DO COLABORADOR</th><th>STATUS</th></tr>");
        foreach (var r in rows)
        {
            var hex = StatusHex(r.Status, r.Cor);
            sb.Append("<tr>");
            sb.Append($"<td style=\"text-align:center;\">{r.Data.ToString("dd/MM/yyyy", PtBr)}</td>");
            sb.Append($"<td>{WebUtility.HtmlEncode(r.Cargo)}</td>");
            sb.Append($"<td>{WebUtility.HtmlEncode(r.Nome)}</td>");
            sb.Append($"<td style=\"text-align:center;color:{hex};font-weight:bold;\">{WebUtility.HtmlEncode(r.Status)}</td>");
            sb.AppendLine("</tr>");
        }
        sb.AppendLine("</table></body></html>");
        return ExcelHtmlLogoEmbed.Pack(sb.ToString(), logoBytes);
    }

    private static byte[] BuildPdf(
        string obra,
        string periodo,
        IReadOnlyList<RelatorioLinha> rows,
        int presente,
        int ausente,
        int emFalta,
        int deFolga,
        byte[]? logoBytes)
    {
        return Document.Create(doc =>
        {
            doc.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(24);
                page.DefaultTextStyle(t => t.FontSize(9).FontFamily("Arial"));

                page.Header().Border(1).BorderColor(Colors.Black).Padding(6).Row(row =>
                {
                    row.ConstantItem(90).Height(55).AlignMiddle().AlignCenter().Element(e =>
                    {
                        if (logoBytes is { Length: > 32 })
                            e.Image(logoBytes).FitArea();
                        else
                            e.AlignCenter().Text("LOGO").FontSize(8).FontColor(Colors.Grey.Medium);
                    });
                    row.RelativeItem().AlignMiddle().AlignCenter()
                        .Text("EFETIVO DIÁRIO").SemiBold().FontSize(16);
                    row.ConstantItem(200).AlignMiddle().Column(col =>
                    {
                        col.Item().Text($"PERÍODO: {periodo}").SemiBold().FontSize(8);
                        col.Item().PaddingTop(4).Text($"OBRA: {obra}").SemiBold().FontSize(8);
                    });
                });

                page.Content().PaddingTop(10).Column(col =>
                {
                    col.Item().Row(r =>
                    {
                        void Box(string label, int qtd, Color color)
                        {
                            r.RelativeItem().Border(1).BorderColor(Colors.Black).Padding(4)
                                .AlignCenter().Text($"{label}: {qtd}").FontColor(color).SemiBold().FontSize(9);
                        }
                        Box("PRESENTE", presente, CorPresente);
                        Box("EM FALTA", emFalta, CorEmFalta);
                        Box("AUSENTE", ausente, CorAusente);
                        Box("DE FOLGA", deFolga, CorDeFolga);
                    });

                    col.Item().PaddingTop(10).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.ConstantColumn(75);
                            c.RelativeColumn(1.4f);
                            c.RelativeColumn(2f);
                            c.ConstantColumn(80);
                        });

                        table.Header(h =>
                        {
                            void Head(string t) => h.Cell().Border(1).BorderColor(Colors.Black)
                                .Background(Colors.Grey.Lighten2).Padding(4)
                                .AlignCenter().Text(t).SemiBold();
                            Head("DATA");
                            Head("CARGO");
                            Head("NOME DO COLABORADOR");
                            Head("STATUS");
                        });

                        if (rows.Count == 0)
                        {
                            table.Cell().ColumnSpan(4).Border(1).Padding(8)
                                .Text("Nenhum registro no período.");
                        }
                        else
                        {
                            foreach (var r in rows)
                            {
                                var sc = StatusQuestColor(r.Status, r.Cor);
                                table.Cell().Border(1).BorderColor(Colors.Black).Padding(3)
                                    .AlignCenter().Text(r.Data.ToString("dd/MM/yyyy", PtBr));
                                table.Cell().Border(1).BorderColor(Colors.Black).Padding(3).Text(r.Cargo);
                                table.Cell().Border(1).BorderColor(Colors.Black).Padding(3).Text(r.Nome);
                                table.Cell().Border(1).BorderColor(Colors.Black).Padding(3)
                                    .AlignCenter().Text(r.Status).FontColor(sc).SemiBold();
                            }
                        }
                    });
                });

                page.Footer().AlignRight().Text(t =>
                {
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

    private readonly record struct RelatorioLinha(
        DateTime Data,
        string Nome,
        string Cargo,
        string Status,
        string Cor);
}