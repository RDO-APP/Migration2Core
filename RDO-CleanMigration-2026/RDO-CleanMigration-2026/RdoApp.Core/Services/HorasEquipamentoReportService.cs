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

/// <summary>Impressora no card — paridade <c>TarefaModel.RelatorioControleHorasEquipamentoTarefa</c>.</summary>
public sealed class HorasEquipamentoReportService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private static readonly NumberFormatInfo HorimetroFormat = CreateHorimetroFormat();
    private static readonly Color Navy = Color.FromHex("#28496f");

    static HorasEquipamentoReportService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    private static NumberFormatInfo CreateHorimetroFormat()
    {
        var nfi = (NumberFormatInfo)CultureInfo.GetCultureInfo("en-US").NumberFormat.Clone();
        nfi.NumberDecimalDigits = 1;
        return nfi;
    }

    private readonly RdoDbContext _context;

    public HorasEquipamentoReportService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<HorasEquipamentoReportResult> GenerateAsync(
        int obraId,
        int tarefaId,
        HorasEquipamentoReportRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!TryParseBrDate(request.DataInicial, out var dataInicial))
        {
            throw new InvalidOperationException("A Data Inicial deve ser preenchida.");
        }

        if (!TryParseBrDate(request.DataFinal, out var dataFinal))
        {
            throw new InvalidOperationException("A Data Final deve ser preenchida.");
        }

        if (dataInicial > dataFinal)
        {
            throw new InvalidOperationException("A Data Final não pode ser menor que a Data Inicial.");
        }

        var dataFimInclusive = dataFinal.Date.AddDays(1).AddSeconds(-1);

        var cabeca = await (
            from tar in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on tar.TarIdEtapa equals e.EtaIdEtapa
            where tar.TarIdTarefa == tarefaId && e.EtaIdObra == obraId
            select new { tar.TarNrAgrupador, tar.TarDsTarefa }
        ).FirstOrDefaultAsync(cancellationToken);

        if (cabeca == null)
        {
            throw new InvalidOperationException("Tarefa não encontrada nesta obra.");
        }

        var obraNome = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => o.ObrDsObra)
            .FirstOrDefaultAsync(cancellationToken) ?? "";

        var descricao = string.IsNullOrWhiteSpace(request.DescricaoTarefa)
            ? cabeca.TarDsTarefa
            : request.DescricaoTarefa.Trim();

        var raw = await (
            from tar in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on tar.TarIdEtapa equals e.EtaIdEtapa
            where e.EtaIdObra == obraId
                  && tar.TarNrAgrupador == cabeca.TarNrAgrupador
                  && tar.TarIdStatus != 1
                  && tar.TarDtMedicao >= dataInicial.Date
                  && tar.TarDtMedicao <= dataFimInclusive
            orderby tar.TarDtMedicao, tar.TarDtMedicaoHoraInicial, tar.TarDtUltimaAtualizacao
            select new
            {
                tar.TarDtMedicao,
                tar.TarDtMedicaoHoraInicial,
                tar.TarDtMedicaoHoraFinal,
                tar.TarDtMedicaoHorimetroInicial,
                tar.TarDtMedicaoHorimetroFinal,
                tar.TarDtMedicaoHorimetroTotal,
                tar.TarDsComentario,
                tar.TarCodigoParalizacao
            }
        ).ToListAsync(cancellationToken);

        var codigos = raw.Select(r => r.TarCodigoParalizacao)
            .Where(c => !string.IsNullOrWhiteSpace(c))
            .Distinct()
            .ToList();

        var paralizacoes = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .Where(p => codigos.Contains(p.TarcpCodigoParalizacao))
            .ToDictionaryAsync(p => p.TarcpCodigoParalizacao, cancellationToken);

        var rows = new List<HoraRow>(raw.Count);
        foreach (var item in raw)
        {
            var comentario = item.TarDsComentario ?? "Sem Observações.";
            if (!string.IsNullOrWhiteSpace(item.TarCodigoParalizacao)
                && paralizacoes.TryGetValue(item.TarCodigoParalizacao, out var par))
            {
                comentario = $"{item.TarDsComentario} {par.TarcpCodigoParalizacao} - {par.TarcpDsParalizacao}";
            }

            var row = new HoraRow
            {
                Data = item.TarDtMedicao.ToString("dd/MM/yyyy", PtBr),
                DataMedicao = item.TarDtMedicao,
                HoraInicial = item.TarDtMedicaoHoraInicial ?? TimeSpan.Zero,
                HoraFinal = item.TarDtMedicaoHoraFinal ?? TimeSpan.Zero,
                HorimetroInicial = item.TarDtMedicaoHorimetroInicial,
                HorimetroFinal = item.TarDtMedicaoHorimetroFinal,
                HorimetroTotal = item.TarDtMedicaoHorimetroTotal,
                Comentario = comentario
            };
            AplicarRegras(row);
            FormatRow(row);
            rows.Add(row);
        }

        var periodo =
            $"{dataInicial:dd/MM/yyyy HH:mm:ss} A {dataFimInclusive:dd/MM/yyyy HH:mm:ss}";
        var excel = string.Equals(request.TipoRelatorio, "Excel", StringComparison.OrdinalIgnoreCase);
        var bytes = excel ? BuildExcel(obraNome, descricao, periodo, rows) : BuildPdf(obraNome, descricao, periodo, rows);

        var di = dataInicial.ToString("dd-MM-yyyy", PtBr);
        var df = dataFinal.ToString("dd-MM-yyyy", PtBr);
        var nome =
            $"Relatório Controle de Horas: {Sanitize(obraNome)}__{Sanitize(descricao)}__{di}__até__{df}"
            + (excel ? ".xls" : ".pdf");

        return new HorasEquipamentoReportResult
        {
            Bytes = bytes,
            FileName = nome,
            ContentType = excel
                ? "application/vnd.ms-excel"
                : "application/pdf"
        };
    }

    private static bool TryParseBrDate(string? value, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        return DateTime.TryParseExact(
            value.Trim(),
            "dd/MM/yyyy",
            PtBr,
            DateTimeStyles.None,
            out date);
    }

    private static string Sanitize(string value)
    {
        foreach (var c in Path.GetInvalidFileNameChars())
        {
            value = value.Replace(c, '-');
        }

        return value.Replace('/', '-');
    }

    private static void AplicarRegras(HoraRow historico)
    {
        var extra = ValidarHoraExtra(historico.DataMedicao.DayOfWeek, historico.HoraInicial, historico.HoraFinal);
        var sexta = historico.DataMedicao.DayOfWeek == DayOfWeek.Friday;
        var fds = historico.DataMedicao.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday;

        if (historico.Comentario.Contains("P99", StringComparison.Ordinal))
        {
            if (!extra)
            {
                ZerarExtrasEManut(historico, zerarNormais: true);
                return;
            }

            if (sexta)
            {
                SplitHoraExtra(historico, TimeSpan.FromHours(16));
            }
            else if (fds)
            {
                historico.HoraExtraInicial = historico.HoraInicial;
                historico.HoraExtraFinal = historico.HoraFinal;
                historico.HoraInicial = TimeSpan.Zero;
                historico.HoraFinal = TimeSpan.Zero;
            }
            else
            {
                SplitHoraExtra(historico, TimeSpan.FromHours(17));
            }

            historico.TotalHorasNormais = 0;
            historico.TotalHorasExtras = 0;
            historico.ManutOP = 0;
            historico.Manutencao = 0;
            historico.SomaTotalHorasManut = 0;
            return;
        }

        if (ValidarCategoriaUm(historico.Comentario))
        {
            if (!extra)
            {
                historico.TotalHorasNormais = DiffHours(historico.HoraFinal, historico.HoraInicial);
                ZerarExtrasEManut(historico, zerarNormais: false);
                return;
            }

            if (fds)
            {
                historico.HoraExtraInicial = historico.HoraInicial;
                historico.HoraExtraFinal = historico.HoraFinal;
                historico.TotalHorasExtras = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
                historico.HoraInicial = TimeSpan.Zero;
                historico.HoraFinal = TimeSpan.Zero;
                historico.TotalHorasNormais = 0;
            }
            else
            {
                SplitHoraExtra(historico, sexta ? TimeSpan.FromHours(16) : TimeSpan.FromHours(17));
                historico.TotalHorasNormais = DiffHours(historico.HoraFinal, historico.HoraInicial);
                historico.TotalHorasExtras = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
            }

            historico.ManutOP = 0;
            historico.Manutencao = 0;
            historico.SomaTotalHorasManut = 0;
            return;
        }

        if (ValidarCategoriaDois(historico.Comentario))
        {
            if (!extra)
            {
                historico.HoraExtraInicial = TimeSpan.Zero;
                historico.HoraExtraFinal = TimeSpan.Zero;
                historico.TotalHorasExtras = 0;
                historico.TotalHorasNormais = 0;
                historico.ManutOP = 0;
                historico.Manutencao = DiffHours(historico.HoraFinal, historico.HoraInicial);
                historico.SomaTotalHorasManut = historico.Manutencao;
                return;
            }

            if (fds)
            {
                historico.HoraExtraInicial = historico.HoraInicial;
                historico.HoraExtraFinal = historico.HoraFinal;
                historico.HoraInicial = TimeSpan.Zero;
                historico.HoraFinal = TimeSpan.Zero;
                historico.TotalHorasNormais = 0;
                historico.TotalHorasExtras = 0;
                historico.Manutencao = 0;
                historico.ManutOP = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
                historico.SomaTotalHorasManut = historico.ManutOP;
                return;
            }

            SplitHoraExtra(historico, sexta ? TimeSpan.FromHours(16) : TimeSpan.FromHours(17));
            historico.TotalHorasNormais = 0;
            historico.TotalHorasExtras = 0;
            historico.Manutencao = DiffHours(historico.HoraFinal, historico.HoraInicial);
            historico.ManutOP = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
            historico.SomaTotalHorasManut = (historico.ManutOP ?? 0) + (historico.Manutencao ?? 0);
            return;
        }

        if (!extra)
        {
            historico.TotalHorasNormais = DiffHours(historico.HoraFinal, historico.HoraInicial);
            ZerarExtrasEManut(historico, zerarNormais: false);
            return;
        }

        if (fds)
        {
            historico.HoraExtraInicial = historico.HoraInicial;
            historico.HoraExtraFinal = historico.HoraFinal;
            historico.TotalHorasExtras = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
            historico.HoraInicial = TimeSpan.Zero;
            historico.HoraFinal = TimeSpan.Zero;
            historico.TotalHorasNormais = 0;
            historico.ManutOP = 0;
            historico.Manutencao = 0;
            historico.SomaTotalHorasManut = 0;
            return;
        }

        SplitHoraExtra(historico, sexta ? TimeSpan.FromHours(16) : TimeSpan.FromHours(17));
        historico.TotalHorasNormais = DiffHours(historico.HoraFinal, historico.HoraInicial);
        historico.TotalHorasExtras = DiffHours(historico.HoraExtraFinal, historico.HoraExtraInicial);
        historico.ManutOP = 0;
        historico.Manutencao = 0;
        historico.SomaTotalHorasManut = 0;
    }

    private static void SplitHoraExtra(HoraRow historico, TimeSpan limite)
    {
        var horaInicial = historico.HoraInicial;
        var horaFinal = historico.HoraFinal;
        if (horaInicial >= limite)
        {
            historico.HoraInicial = TimeSpan.Zero;
            historico.HoraFinal = TimeSpan.Zero;
            historico.HoraExtraInicial = horaInicial;
            historico.HoraExtraFinal = horaFinal;
            return;
        }

        historico.HoraInicial = horaInicial;
        historico.HoraFinal = horaFinal <= limite ? horaFinal : limite;
        historico.HoraExtraInicial = horaFinal > limite
            ? (horaInicial > limite ? horaInicial : limite)
            : TimeSpan.Zero;
        historico.HoraExtraFinal = horaFinal > limite ? horaFinal : TimeSpan.Zero;
    }

    private static void ZerarExtrasEManut(HoraRow historico, bool zerarNormais)
    {
        historico.HoraExtraInicial = TimeSpan.Zero;
        historico.HoraExtraFinal = TimeSpan.Zero;
        historico.TotalHorasExtras = 0;
        historico.ManutOP = 0;
        historico.Manutencao = 0;
        historico.SomaTotalHorasManut = 0;
        if (zerarNormais)
        {
            historico.TotalHorasNormais = 0;
        }
    }

    private static float DiffHours(TimeSpan a, TimeSpan b) => (a - b).Hours;

    private static bool ValidarHoraExtra(DayOfWeek dia, TimeSpan horaInicial, TimeSpan horaFinal)
    {
        var hi = horaInicial.Hours;
        var hf = horaFinal.Hours;
        if (dia is >= DayOfWeek.Monday and <= DayOfWeek.Thursday)
        {
            return hi < 7 || hi >= 17 || hf < 7 || hf > 17;
        }

        if (dia == DayOfWeek.Friday)
        {
            return hi < 7 || hi >= 16 || hf < 7 || hf > 16;
        }

        return dia is DayOfWeek.Saturday or DayOfWeek.Sunday;
    }

    private static bool ValidarCategoriaUm(string comentario) =>
        comentario.Contains("C11") || comentario.Contains("C12")
        || comentario.Contains("M01") || comentario.Contains("M02") || comentario.Contains("M03")
        || comentario.Contains("P22") || comentario.Contains("P23") || comentario.Contains("P24")
        || comentario.Contains("P25") || comentario.Contains("P26") || comentario.Contains("P27")
        || comentario.Contains("P28") || comentario.Contains("P29") || comentario.Contains("P30")
        || comentario.Contains("P31");

    private static bool ValidarCategoriaDois(string comentario) =>
        comentario.Contains("M04") || comentario.Contains("M05") || comentario.Contains("M06")
        || comentario.Contains("M07") || comentario.Contains("M08") || comentario.Contains("P21");

    private static void FormatRow(HoraRow row)
    {
        row.TotalHorasExtrasFormatado = row.TotalHorasExtras?.ToString("N", HorimetroFormat);
        row.TotalHorasNormaisFormatado = row.TotalHorasNormais?.ToString("N", HorimetroFormat);
        row.HorimetroInicialFormatado = row.HorimetroInicial?.ToString("N", HorimetroFormat);
        row.HorimetroFinalFormatado = row.HorimetroFinal?.ToString("N", HorimetroFormat);
        row.HorimetroTotalFormatado = row.HorimetroTotal?.ToString("N", HorimetroFormat);
        row.ManutencaoFormatado = row.Manutencao?.ToString("N", HorimetroFormat);
        row.ManutOpFormatado = row.ManutOP?.ToString("N", HorimetroFormat);
        row.HoraInicialTxt = FormatTime(row.HoraInicial);
        row.HoraFinalTxt = FormatTime(row.HoraFinal);
        row.HoraExtraInicialTxt = FormatTime(row.HoraExtraInicial);
        row.HoraExtraFinalTxt = FormatTime(row.HoraExtraFinal);
    }

    private static string FormatTime(TimeSpan t) => t.ToString(@"hh\:mm");

    private static byte[] BuildPdf(string obra, string equipamento, string periodo, List<HoraRow> rows)
    {
        var somaHe = rows.Sum(x => x.TotalHorasExtras ?? 0).ToString("N", HorimetroFormat);
        var somaHn = rows.Sum(x => x.TotalHorasNormais ?? 0).ToString("N", HorimetroFormat);
        var somaHt = rows.Sum(x => x.HorimetroTotal ?? 0).ToString("N", HorimetroFormat);
        var somaMan = rows.Sum(x => x.SomaTotalHorasManut ?? 0).ToString("N", HorimetroFormat);

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(18);
                page.DefaultTextStyle(x => x.FontSize(8).FontColor(Navy));
                page.Header().Column(col =>
                {
                    col.Item().Text("Relatório Controle de Horas").Bold().FontSize(14);
                    col.Item().Text($"Obra: {obra}");
                    col.Item().Text($"Equipamento: {equipamento}");
                    col.Item().Text($"Período: {periodo}");
                    col.Item().PaddingTop(6).Text(
                        $"Totais — HN: {somaHn}  HE: {somaHe}  Horím. tot.: {somaHt}  Manut.: {somaMan}");
                });
                page.Content().PaddingTop(8).Table(table =>
                {
                    table.ColumnsDefinition(c =>
                    {
                        c.ConstantColumn(58);
                        c.ConstantColumn(38);
                        c.ConstantColumn(38);
                        c.ConstantColumn(42);
                        c.ConstantColumn(42);
                        c.ConstantColumn(42);
                        c.ConstantColumn(36);
                        c.ConstantColumn(36);
                        c.ConstantColumn(38);
                        c.ConstantColumn(38);
                        c.ConstantColumn(40);
                        c.ConstantColumn(40);
                        c.RelativeColumn();
                    });

                    string[] heads =
                    [
                        "Data", "Hi", "Hf", "Horím I", "Horím F", "Horím T",
                        "HN", "HE", "HEi", "HEf", "Manut", "ManutOP", "Comentário"
                    ];
                    table.Header(h =>
                    {
                        foreach (var head in heads)
                        {
                            h.Cell().Background(Navy).Padding(3).Text(head).FontColor(Colors.White).Bold();
                        }
                    });

                    foreach (var r in rows)
                    {
                        Cell(table, r.Data);
                        Cell(table, r.HoraInicialTxt);
                        Cell(table, r.HoraFinalTxt);
                        Cell(table, r.HorimetroInicialFormatado);
                        Cell(table, r.HorimetroFinalFormatado);
                        Cell(table, r.HorimetroTotalFormatado);
                        Cell(table, r.TotalHorasNormaisFormatado);
                        Cell(table, r.TotalHorasExtrasFormatado);
                        Cell(table, r.HoraExtraInicialTxt);
                        Cell(table, r.HoraExtraFinalTxt);
                        Cell(table, r.ManutencaoFormatado);
                        Cell(table, r.ManutOpFormatado);
                        Cell(table, r.Comentario);
                    }
                });
            });
        }).GeneratePdf();
    }

    private static void Cell(TableDescriptor table, string? text)
    {
        table.Cell().BorderBottom(0.5f).BorderColor("#D3D3D3").Padding(2).Text(text ?? "");
    }

    private static byte[] BuildExcel(string obra, string equipamento, string periodo, List<HoraRow> rows)
    {
        // HTML.xls — larguras estáveis no Excel (SpreadsheetML sem Column cortava Data/Equipamento).
        var somaHe = rows.Sum(x => x.TotalHorasExtras ?? 0).ToString("N", HorimetroFormat);
        var somaHn = rows.Sum(x => x.TotalHorasNormais ?? 0).ToString("N", HorimetroFormat);
        var somaHt = rows.Sum(x => x.HorimetroTotal ?? 0).ToString("N", HorimetroFormat);
        var somaMan = rows.Sum(x => x.SomaTotalHorasManut ?? 0).ToString("N", HorimetroFormat);

        static string H(string? s) => WebUtility.HtmlEncode(s ?? "");

        var sb = new StringBuilder();
        sb.Append("<html><head><meta charset=\"utf-8\"/><style>");
        sb.Append("table{border-collapse:collapse;font-family:Arial,sans-serif;font-size:9pt;}");
        sb.Append("td,th{border:1px solid #000;padding:3px 4px;vertical-align:middle;}");
        sb.Append(".title{font-size:14pt;font-weight:bold;}");
        sb.Append(".hdr{background:#28496f;color:#fff;font-weight:bold;text-align:center;font-size:8pt;}");
        sb.Append(".tot{background:#CFD8DC;font-weight:bold;}");
        sb.Append(".num{text-align:right;}");
        sb.Append("</style></head><body><table>");
        sb.Append("<tr><td colspan=\"13\" class=\"title\">Relatório Controle de Horas</td></tr>");
        sb.Append($"<tr><td colspan=\"2\"><b>Obra</b></td><td colspan=\"11\">{H(obra)}</td></tr>");
        sb.Append($"<tr><td colspan=\"2\"><b>Equipamento</b></td><td colspan=\"11\">{H(equipamento)}</td></tr>");
        sb.Append($"<tr><td colspan=\"2\"><b>Período</b></td><td colspan=\"11\">{H(periodo)}</td></tr>");
        sb.Append($"<tr><td colspan=\"13\"><b>Totais</b> — HN: {H(somaHn)} · HE: {H(somaHe)} · Horím. tot.: {H(somaHt)} · Manut.: {H(somaMan)}</td></tr>");
        sb.Append("<tr>");
        foreach (var head in new[]
                 {
                     "Data", "Hora Ini.", "Hora Fim", "Horím. Ini.", "Horím. Fim", "Horím. Tot.",
                     "HN", "HE", "HE Ini.", "HE Fim", "Manut", "ManutOP", "Comentário"
                 })
        {
            sb.Append($"<th class=\"hdr\">{head}</th>");
        }
        sb.Append("</tr>");

        foreach (var r in rows)
        {
            sb.Append("<tr>");
            sb.Append($"<td>{H(r.Data)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HoraInicialTxt)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HoraFinalTxt)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HorimetroInicialFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HorimetroFinalFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HorimetroTotalFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.TotalHorasNormaisFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.TotalHorasExtrasFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HoraExtraInicialTxt)}</td>");
            sb.Append($"<td class=\"num\">{H(r.HoraExtraFinalTxt)}</td>");
            sb.Append($"<td class=\"num\">{H(r.ManutencaoFormatado)}</td>");
            sb.Append($"<td class=\"num\">{H(r.ManutOpFormatado)}</td>");
            sb.Append($"<td>{H(r.Comentario)}</td>");
            sb.Append("</tr>");
        }

        sb.Append("<tr class=\"tot\">");
        sb.Append("<td colspan=\"6\">TOTAL</td>");
        sb.Append($"<td class=\"num\">{H(somaHn)}</td><td class=\"num\">{H(somaHe)}</td>");
        sb.Append("<td colspan=\"2\"></td>");
        sb.Append($"<td class=\"num\" colspan=\"2\">{H(somaMan)}</td><td></td>");
        sb.Append("</tr>");
        sb.Append("</table></body></html>");

        return Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(sb.ToString())).ToArray();
    }

    private sealed class HoraRow
    {
        public DateTime DataMedicao { get; set; }
        public string Data { get; set; } = "";
        public TimeSpan HoraInicial { get; set; }
        public TimeSpan HoraFinal { get; set; }
        public TimeSpan HoraExtraInicial { get; set; }
        public TimeSpan HoraExtraFinal { get; set; }
        public float? HorimetroInicial { get; set; }
        public float? HorimetroFinal { get; set; }
        public float? HorimetroTotal { get; set; }
        public float? TotalHorasNormais { get; set; }
        public float? TotalHorasExtras { get; set; }
        public float? Manutencao { get; set; }
        public float? ManutOP { get; set; }
        public float? SomaTotalHorasManut { get; set; }
        public string Comentario { get; set; } = "";
        public string HoraInicialTxt { get; set; } = "";
        public string HoraFinalTxt { get; set; } = "";
        public string HoraExtraInicialTxt { get; set; } = "";
        public string HoraExtraFinalTxt { get; set; } = "";
        public string? HorimetroInicialFormatado { get; set; }
        public string? HorimetroFinalFormatado { get; set; }
        public string? HorimetroTotalFormatado { get; set; }
        public string? TotalHorasNormaisFormatado { get; set; }
        public string? TotalHorasExtrasFormatado { get; set; }
        public string? ManutencaoFormatado { get; set; }
        public string? ManutOpFormatado { get; set; }
    }
}

public sealed class HorasEquipamentoReportResult
{
    public required byte[] Bytes { get; init; }
    public required string FileName { get; init; }
    public required string ContentType { get; init; }
}
