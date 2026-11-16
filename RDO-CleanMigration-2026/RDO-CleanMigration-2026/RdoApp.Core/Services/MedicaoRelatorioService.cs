using System.Globalization;
using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>
/// Paridade prod api/medicao/gerarrelatorio + RelatorioMedicao.rdlc
/// (PLANILHA DE MEDIÇÃO, logo, cabecalho, grupos PLANEJADO/QM/VM, TOTAL GERAL).
/// PDF = QuestPDF. Excel = HTML .xls.
/// </summary>
public sealed class MedicaoRelatorioService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private static readonly Color Navy = Color.FromHex("#28496f");
    private const int StatusEmExecucao = 2;

    static MedicaoRelatorioService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public MedicaoRelatorioService(RdoDbContext context, IConfiguration configuration, IWebHostEnvironment env)
    {
        _context = context;
        _configuration = configuration;
        _env = env;
    }

    public async Task<(byte[] Bytes, string ContentType, string FileName)> GenerateAsync(
        int obraId, MedicaoRelatorioRequestDto request, CancellationToken ct)
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
            .Select(o => new { o.ObrDsObra, o.ObrDsLogradouro, o.ObrDsBairro, o.ObrDsFoto, o.ObrIdEmpresaContratada, o.ObrIdEmpresaContratante })
            .FirstOrDefaultAsync(ct)
            ?? throw new InvalidOperationException("Obra não encontrada.");

        if (obra.ObrIdEmpresaContratada is null or <= 0)
            throw new InvalidOperationException(
                "Não foi possível gerar o Relatorio. É necessário existir uma empresa contratada associada à obra: "
                + (obra.ObrDsObra ?? "") + ".");

        var contratada = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdEmpresa == obra.ObrIdEmpresaContratada)
            .Select(e => e.EmpDsRazaoSocial)
            .FirstOrDefaultAsync(ct) ?? "";

        var permiteLogo = false;
        if (obra.ObrIdEmpresaContratante is > 0)
        {
            var empLic = await (
                from e in _context.Empresas.AsNoTracking()
                join l in _context.Licencas.AsNoTracking() on e.EmpIdLicenca equals l.LicIdLicenca into ls
                from l in ls.DefaultIfEmpty()
                where e.EmpIdEmpresa == obra.ObrIdEmpresaContratante
                select l == null ? (bool?)null : l.LicStPermiteLogoRdo
            ).FirstOrDefaultAsync(ct);
            permiteLogo = empLic == true;
        }

        var logoBytes = TryLoadLogoBytes(permiteLogo ? obra.ObrDsFoto : null);

        var periodoRows = await (
            from t in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            join u in _context.UnidadesDeMedida.AsNoTracking() on t.TarIdUnidade equals u.UnmIdUnidade into us
            from u in us.DefaultIfEmpty()
            where e.EtaIdObra == obraId && t.TarIdStatus == StatusEmExecucao
                  && t.TarDtMedicao >= diaIni && t.TarDtMedicao < diaFimExcl
            select new
            {
                t.TarNrAgrupador, t.TarIdEtapa,
                Etapa = e.EtaDsEtapa ?? "", Tarefa = t.TarDsTarefa ?? "",
                t.TarVlValorUnitario, t.TarNrQtdPrevisao, t.TarNrQtdConstruida,
                Unidade = u == null ? "" : (!string.IsNullOrEmpty(u.UnmDsSimbolo) ? u.UnmDsSimbolo : u.UnmDsUnidade ?? ""),
            }
        ).ToListAsync(ct);

        if (periodoRows.Count == 0)
            throw new InvalidOperationException("Não existem dados para o filtro informado.");

        var acumuladoRows = await (
            from t in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            where e.EtaIdObra == obraId && t.TarDtMedicao < diaFimExcl
            select new { t.TarNrAgrupador, t.TarIdEtapa, t.TarNrQtdConstruida }
        ).ToListAsync(ct);

        var linhas = new List<LinhaMedicao>();
        decimal tgValor = 0, tgPeriodo = 0, tgAcumulado = 0, tgSaldo = 0;
        foreach (var g in periodoRows.GroupBy(x => x.TarNrAgrupador).OrderBy(x => x.First().Etapa).ThenBy(x => x.First().Tarefa))
        {
            var first = g.First();
            var preco = first.TarVlValorUnitario ?? 0m;
            var qtdPlan = (decimal)(first.TarNrQtdPrevisao ?? 0);
            var valor = preco * qtdPlan;
            var qmPeriodo = g.Sum(x => (decimal)(x.TarNrQtdConstruida ?? 0));
            var qmAcum = acumuladoRows.Where(t => t.TarNrAgrupador == first.TarNrAgrupador && t.TarIdEtapa == first.TarIdEtapa)
                .Sum(t => (decimal)(t.TarNrQtdConstruida ?? 0));
            var qmSaldo = qtdPlan - qmAcum;
            var vmPeriodo = qmPeriodo * preco;
            var vmAcum = qmAcum * preco;
            var vmSaldo = valor - vmAcum;
            linhas.Add(new LinhaMedicao(first.Etapa, first.Tarefa, first.Unidade, qtdPlan, preco, valor, qmPeriodo, qmAcum, qmSaldo, vmPeriodo, vmAcum, vmSaldo));
            tgValor += valor; tgPeriodo += vmPeriodo; tgAcumulado += vmAcum; tgSaldo += vmSaldo;
        }

        var dias = (diaFim - diaIni).Days;
        var prazo = dias / 30 <= 0 ? $"{dias + 1} dia(s)" : $"{dias / 30} mes(es)";
        var periodo = $"De {diaIni:dd/MM/yyyy} Até {diaFim:dd/MM/yyyy}";
        var local = (obra.ObrDsLogradouro ?? "") + (!string.IsNullOrWhiteSpace(obra.ObrDsBairro) ? ", " + obra.ObrDsBairro : "");
        var cabeca = new Cabeca(contratada, periodo, obra.ObrDsObra ?? "", local, prazo, tgValor, tgPeriodo, tgAcumulado, tgSaldo);

        var tipo = (request.TipoRelatorio ?? "PDF").Trim();
        var labelIni = diaIni.ToString("dd_MM_yyyy", PtBr);
        var labelFim = diaFim.ToString("dd_MM_yyyy", PtBr);
        if (tipo.Equals("Excel", StringComparison.OrdinalIgnoreCase) || tipo.Equals("xls", StringComparison.OrdinalIgnoreCase))
            return (BuildExcelHtml(cabeca, linhas, logoBytes), "application/vnd.ms-excel", $"Medicao_{labelIni}_{labelFim}.xls");
        return (BuildPdf(cabeca, linhas, logoBytes), "application/pdf", $"Medicao_{labelIni}_{labelFim}.pdf");
    }

    private byte[]? TryLoadLogoBytes(string? obraFoto)
    {
        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        if (string.IsNullOrWhiteSpace(uploadsRoot))
            uploadsRoot = Path.Combine(_env.ContentRootPath, "Uploads");
        var relatives = new List<string>();
        if (!string.IsNullOrWhiteSpace(obraFoto)) relatives.Add(obraFoto.Trim());
        relatives.AddRange(new[] { "/images/logo.jpg", "/Assets/images/logo.jpg", "images/logo.jpg", "Assets/images/logo.jpg", "wwwroot/images/logo.jpg" });
        var roots = new[] { uploadsRoot, _env.WebRootPath, _env.ContentRootPath, Path.Combine(_env.ContentRootPath, "wwwroot") };
        foreach (var rel in relatives.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            var trimmed = rel.Replace('\\', '/').Trim();
            if (trimmed.StartsWith("/Uploads/", StringComparison.OrdinalIgnoreCase)) trimmed = trimmed["/Uploads/".Length..];
            else if (trimmed.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase)) trimmed = trimmed["Uploads/".Length..];
            trimmed = trimmed.TrimStart('/');
            var asFs = trimmed.Replace('/', Path.DirectorySeparatorChar);
            foreach (var root in roots)
            {
                if (string.IsNullOrWhiteSpace(root)) continue;
                var physical = Path.Combine(root.TrimEnd('\\', '/'), asFs);
                if (File.Exists(physical)) return File.ReadAllBytes(physical);
            }
        }
        return null;
    }

    private static string N(decimal v) => v.ToString("N", PtBr);
    private static string H(string s) => WebUtility.HtmlEncode(s);

    private static byte[] BuildExcelHtml(Cabeca c, IReadOnlyList<LinhaMedicao> rows, byte[]? logoBytes)
    {
        var sb = new StringBuilder();
        sb.Append("<html><head><meta charset=\"utf-8\"/><style>");
        sb.Append("table{border-collapse:collapse;font-family:Arial,sans-serif;font-size:9pt;}");
        sb.Append("td,th{border:1px solid #000;padding:3px 4px;}");
        sb.Append(".title{font-size:14pt;font-weight:bold;text-align:center;}");
        sb.Append(".grp{background:#28496f;color:#fff;font-weight:bold;text-align:center;font-size:8pt;}");
        sb.Append(".sub{background:#D9D9D9;font-weight:bold;text-align:center;font-size:8pt;}");
        sb.Append(".etapa{background:#EEEEEE;font-weight:bold;}");
        sb.Append(".tot{background:#CFD8DC;font-weight:bold;}");
        sb.Append(".num{text-align:right;}");
        sb.Append("</style></head><body><table>");

        sb.Append("<tr>");
        sb.Append("<td rowspan=\"4\" style=\"width:110px;text-align:center;vertical-align:middle;\">");
        if (logoBytes is { Length: > 0 })
        {
            var b64 = Convert.ToBase64String(logoBytes);
            var mime = logoBytes[0] == 0x89 ? "image/png" : "image/jpeg";
            sb.Append($"<img src=\"data:{mime};base64,{b64}\" width=\"100\" height=\"55\"/>");
        }
        else sb.Append("&nbsp;");
        sb.Append("</td>");
        sb.Append("<td colspan=\"11\" class=\"title\">PLANILHA DE MEDIÇÃO</td></tr>");
        sb.Append($"<tr><td colspan=\"6\"><b>Contratada:</b> {H(c.Contratada)}</td><td colspan=\"5\"><b>Período:</b> {H(c.Periodo)}</td></tr>");
        sb.Append($"<tr><td colspan=\"6\"><b>Serviço:</b> {H(c.Servico)}</td><td colspan=\"5\"><b>Prazo:</b> {H(c.Prazo)}</td></tr>");
        sb.Append($"<tr><td colspan=\"6\"><b>Local:</b> {H(c.Local)}</td><td colspan=\"5\"><b>VALOR DE MEDIÇÃO:</b> R$ {N(c.TgPeriodo)} &nbsp; Acum.: R$ {N(c.TgAcumulado)}</td></tr>");

        sb.Append("<tr>");
        sb.Append("<th colspan=\"2\" class=\"grp\">ETAPA / TAREFA</th>");
        sb.Append("<th colspan=\"4\" class=\"grp\">PLANEJADO</th>");
        sb.Append("<th colspan=\"3\" class=\"grp\">QUANTIDADES MEDIDAS</th>");
        sb.Append("<th colspan=\"3\" class=\"grp\">VALORES MEDIDOS</th>");
        sb.Append("</tr>");
        sb.Append("<tr class=\"sub\">");
        sb.Append("<th>ETAPA</th><th>TAREFA</th><th>UNID.</th><th>QUANT.</th><th>P. UNIT.</th><th>VALOR</th>");
        sb.Append("<th>NO PERÍODO</th><th>ACUMUL.</th><th>SALDO</th>");
        sb.Append("<th>NO PERÍODO</th><th>ACUMUL.</th><th>SALDO</th>");
        sb.Append("</tr>");

        string? etapaAtual = null;
        foreach (var r in rows)
        {
            if (!string.Equals(etapaAtual, r.Etapa, StringComparison.Ordinal))
            {
                etapaAtual = r.Etapa;
                sb.Append($"<tr class=\"etapa\"><td colspan=\"12\">{H(r.Etapa)}</td></tr>");
            }
            sb.Append("<tr>");
            sb.Append($"<td>&nbsp;</td><td>{H(r.Tarefa)}</td><td>{H(r.Unidade)}</td>");
            sb.Append($"<td class=\"num\">{N(r.QtdPlan)}</td><td class=\"num\">{N(r.Preco)}</td><td class=\"num\">{N(r.Valor)}</td>");
            sb.Append($"<td class=\"num\">{N(r.QmPeriodo)}</td><td class=\"num\">{N(r.QmAcumulado)}</td><td class=\"num\">{N(r.QmSaldo)}</td>");
            sb.Append($"<td class=\"num\">{N(r.VmPeriodo)}</td><td class=\"num\">{N(r.VmAcumulado)}</td><td class=\"num\">{N(r.VmSaldo)}</td>");
            sb.Append("</tr>");
        }

        sb.Append("<tr class=\"tot\">");
        sb.Append("<td colspan=\"5\">TOTAL GERAL</td>");
        sb.Append($"<td class=\"num\">{N(c.TgValor)}</td><td colspan=\"2\">&nbsp;</td><td>&nbsp;</td>");
        sb.Append($"<td class=\"num\">{N(c.TgPeriodo)}</td><td class=\"num\">{N(c.TgAcumulado)}</td><td class=\"num\">{N(c.TgSaldo)}</td>");
        sb.Append("</tr>");
        sb.Append("</table></body></html>");
        return Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(sb.ToString())).ToArray();
    }

    private static byte[] BuildPdf(Cabeca c, IReadOnlyList<LinhaMedicao> rows, byte[]? logoBytes)
    {
        return Document.Create(doc =>
        {
            doc.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(16);
                page.DefaultTextStyle(t => t.FontSize(7).FontFamily("Arial"));

                page.Header().Border(1).BorderColor(Colors.Black).Padding(4).Column(col =>
                {
                    col.Item().Row(row =>
                    {
                        row.ConstantItem(85).Height(48).AlignMiddle().AlignCenter().Element(e =>
                        {
                            if (logoBytes is { Length: > 32 }) e.Image(logoBytes).FitArea();
                            else e.AlignCenter().Text("LOGO").FontSize(7).FontColor(Colors.Grey.Medium);
                        });
                        row.RelativeItem().AlignMiddle().AlignCenter()
                            .Text("PLANILHA DE MEDIÇÃO").SemiBold().FontSize(14);
                        row.ConstantItem(210).AlignMiddle().Column(m =>
                        {
                            m.Item().Text($"Período: {c.Periodo}").SemiBold().FontSize(7);
                            m.Item().Text($"Prazo: {c.Prazo}").FontSize(7);
                            m.Item().Text($"VALOR DE MEDIÇÃO: R$ {N(c.TgPeriodo)}").SemiBold().FontSize(7);
                            m.Item().Text($"Acumulado: R$ {N(c.TgAcumulado)}").FontSize(7);
                        });
                    });
                    col.Item().PaddingTop(3).Text($"Contratada: {c.Contratada}").FontSize(7);
                    col.Item().Text($"Serviço: {c.Servico}").FontSize(7);
                    col.Item().Text($"Local: {c.Local}").FontSize(7);
                });

                page.Content().PaddingTop(6).Table(table =>
                {
                    table.ColumnsDefinition(cols =>
                    {
                        cols.RelativeColumn(1.1f); cols.RelativeColumn(1.3f);
                        cols.ConstantColumn(32); cols.ConstantColumn(42); cols.ConstantColumn(42); cols.ConstantColumn(48);
                        cols.ConstantColumn(42); cols.ConstantColumn(42); cols.ConstantColumn(42);
                        cols.ConstantColumn(48); cols.ConstantColumn(48); cols.ConstantColumn(42);
                    });

                    table.Header(h =>
                    {
                        void G(string t, int span) => h.Cell().ColumnSpan((uint)span).Background(Navy).Border(0.5f).BorderColor(Colors.Black)
                            .Padding(2).AlignCenter().Text(t).FontColor(Colors.White).SemiBold().FontSize(6);
                        void S(string t) => h.Cell().Background(Colors.Grey.Lighten2).Border(0.5f).BorderColor(Colors.Black)
                            .Padding(2).AlignCenter().Text(t).SemiBold().FontSize(6);
                        G("ETAPA / TAREFA", 2); G("PLANEJADO", 4); G("QUANTIDADES MEDIDAS", 3); G("VALORES MEDIDOS", 3);
                        S("ETAPA"); S("TAREFA"); S("UNID."); S("QUANT."); S("P. UNIT."); S("VALOR");
                        S("NO PERÍODO"); S("ACUMUL."); S("SALDO");
                        S("NO PERÍODO"); S("ACUMUL."); S("SALDO");
                    });

                    void Cell(string t, bool right = false)
                    {
                        var cell = table.Cell().Border(0.5f).BorderColor(Colors.Black).Padding(2);
                        if (right) cell.AlignRight().Text(t).FontSize(6);
                        else cell.Text(t).FontSize(6);
                    }

                    string? etapaAtual = null;
                    foreach (var r in rows)
                    {
                        if (!string.Equals(etapaAtual, r.Etapa, StringComparison.Ordinal))
                        {
                            etapaAtual = r.Etapa;
                            table.Cell().ColumnSpan(12).Background(Colors.Grey.Lighten3).Border(0.5f).BorderColor(Colors.Black)
                                .Padding(2).Text(r.Etapa).SemiBold().FontSize(7);
                        }
                        Cell(""); Cell(r.Tarefa); Cell(r.Unidade);
                        Cell(N(r.QtdPlan), true); Cell(N(r.Preco), true); Cell(N(r.Valor), true);
                        Cell(N(r.QmPeriodo), true); Cell(N(r.QmAcumulado), true); Cell(N(r.QmSaldo), true);
                        Cell(N(r.VmPeriodo), true); Cell(N(r.VmAcumulado), true); Cell(N(r.VmSaldo), true);
                    }

                    table.Cell().ColumnSpan(5).Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2)
                        .Text("TOTAL GERAL").SemiBold().FontSize(7);
                    table.Cell().Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2).AlignRight().Text(N(c.TgValor)).SemiBold().FontSize(6);
                    table.Cell().ColumnSpan(3).Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2).Text("");
                    table.Cell().Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2).AlignRight().Text(N(c.TgPeriodo)).SemiBold().FontSize(6);
                    table.Cell().Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2).AlignRight().Text(N(c.TgAcumulado)).SemiBold().FontSize(6);
                    table.Cell().Background(Colors.BlueGrey.Lighten4).Border(0.5f).Padding(2).AlignRight().Text(N(c.TgSaldo)).SemiBold().FontSize(6);
                });

                page.Footer().AlignRight().Text(t =>
                {
                    t.CurrentPageNumber().FontSize(7);
                    t.Span(" / ").FontSize(7);
                    t.TotalPages().FontSize(7);
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

    private readonly record struct Cabeca(
        string Contratada, string Periodo, string Servico, string Local, string Prazo,
        decimal TgValor, decimal TgPeriodo, decimal TgAcumulado, decimal TgSaldo);

    private readonly record struct LinhaMedicao(
        string Etapa, string Tarefa, string Unidade,
        decimal QtdPlan, decimal Preco, decimal Valor,
        decimal QmPeriodo, decimal QmAcumulado, decimal QmSaldo,
        decimal VmPeriodo, decimal VmAcumulado, decimal VmSaldo);
}
