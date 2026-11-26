using System.Globalization;
using System.IO.Compression;
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
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public HorasEquipamentoReportService(
        RdoDbContext context,
        IConfiguration configuration,
        IWebHostEnvironment env)
    {
        _context = context;
        _configuration = configuration;
        _env = env;
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

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrDsObra, o.ObrDsFoto })
            .FirstOrDefaultAsync(cancellationToken);
        var obraNome = obra?.ObrDsObra ?? "";

        var descricao = string.IsNullOrWhiteSpace(request.DescricaoTarefa)
            ? cabeca.TarDsTarefa
            : request.DescricaoTarefa.Trim();
        var logoBytes = TryLoadLogoBytes(obra?.ObrDsFoto);

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
        var bytes = excel
            ? BuildExcelXlsx(obraNome, descricao, periodo, rows)
            : BuildPdf(obraNome, descricao, periodo, rows, logoBytes);

        var di = dataInicial.ToString("dd-MM-yyyy", PtBr);
        var df = dataFinal.ToString("dd-MM-yyyy", PtBr);
        var nome =
            $"Controle_de_Horas_{Sanitize(obraNome)}__{Sanitize(descricao)}__{di}__ate__{df}"
            + (excel ? ".xlsx" : ".pdf");

        return new HorasEquipamentoReportResult
        {
            Bytes = bytes,
            FileName = nome,
            ContentType = excel
                ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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

        var v = value.Trim();
        if (DateTime.TryParseExact(
                v,
                new[]
                {
                    "dd/MM/yyyy",
                    "dd/MM/yyyy HH:mm:ss",
                    "yyyy-MM-dd",
                    "yyyy-MM-ddTHH:mm:ss",
                    "yyyy-MM-ddTHH:mm:ss.fffZ",
                    "yyyy-MM-ddTHH:mm:ssZ",
                },
                CultureInfo.InvariantCulture,
                DateTimeStyles.AllowWhiteSpaces | DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal,
                out date)
            || DateTime.TryParseExact(v, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date)
            || DateTime.TryParse(v, PtBr, DateTimeStyles.None, out date)
            || DateTime.TryParse(v, CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out date))
        {
            date = date.Date;
            return true;
        }

        return false;
    }

    private static string Sanitize(string value)
    {
        foreach (var c in Path.GetInvalidFileNameChars())
            value = value.Replace(c, '-');
        // Evita %20 / dois-pontos no Content-Disposition (Excel mostra nome URL-encoded).
        return value.Replace('/', '-').Replace(':', '-').Replace(' ', '_');
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

    private byte[]? TryLoadLogoBytes(string? obraFoto)
    {
        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        if (string.IsNullOrWhiteSpace(uploadsRoot))
            uploadsRoot = Path.Combine(_env.ContentRootPath, "Uploads");
        var relatives = new List<string>();
        if (!string.IsNullOrWhiteSpace(obraFoto)) relatives.Add(obraFoto.Trim());
        relatives.AddRange(["/images/logo.jpg", "/Assets/images/logo.jpg", "images/logo.jpg", "Assets/images/logo.jpg"]);
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

    private static byte[] BuildPdf(string obra, string equipamento, string periodo, List<HoraRow> rows, byte[]? logoBytes)
    {
        var somaHe = rows.Sum(x => x.TotalHorasExtras ?? 0).ToString("N", HorimetroFormat);
        var somaHn = rows.Sum(x => x.TotalHorasNormais ?? 0).ToString("N", HorimetroFormat);
        var somaHt = rows.Sum(x => x.HorimetroTotal ?? 0).ToString("N", HorimetroFormat);
        var somaMan = rows.Sum(x => x.SomaTotalHorasManut ?? 0).ToString("N", HorimetroFormat);
        var headBg = Color.FromHex("#A4C2F4");
        var totBg = Color.FromHex("#9abded");

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(12);
                page.DefaultTextStyle(x => x.FontSize(7));

                page.Content().Column(main =>
                {
                    // Cabeçalho = Excel (logo bitmap + grade meta)
                    main.Item().Border(1).BorderColor(Colors.Black).Padding(4).Column(hdr =>
                    {
                        hdr.Item().Row(r =>
                        {
                            r.ConstantItem(78).Height(46).AlignMiddle().AlignCenter().Element(e =>
                            {
                                if (logoBytes is { Length: > 32 }) e.Image(logoBytes).FitArea();
                                else e.Text("rdo").Bold().FontSize(14).FontColor(Navy);
                            });
                            r.RelativeItem().AlignMiddle().AlignCenter()
                                .Text("CONTROLE DE HORAS").Bold().FontSize(14).FontColor(Navy);
                        });
                        hdr.Item().PaddingTop(4).Table(t =>
                        {
                            t.ColumnsDefinition(c =>
                            {
                                c.ConstantColumn(72); c.RelativeColumn(2);
                                c.ConstantColumn(48); c.RelativeColumn(2);
                                c.ConstantColumn(78); c.RelativeColumn(2);
                            });
                            void L(string s) => t.Cell().Border(0.5f).Padding(2).Text(s).Bold().FontSize(7);
                            void V(string s) => t.Cell().Border(0.5f).Padding(2).Text(s).FontSize(7);
                            L("Equipamento"); V(equipamento); L("Período"); V(periodo);
                            L("Frente de Serviço"); V(obra);
                        });
                    });

                    main.Item().PaddingTop(6).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.ConstantColumn(50); c.ConstantColumn(34); c.ConstantColumn(34); c.ConstantColumn(40);
                            c.ConstantColumn(48); c.ConstantColumn(34); c.ConstantColumn(34); c.ConstantColumn(40);
                            c.ConstantColumn(48); c.ConstantColumn(44); c.ConstantColumn(44); c.ConstantColumn(46);
                            c.RelativeColumn();
                        });

                        void Gh(string s, uint span) =>
                            table.Cell().ColumnSpan(span).Background(headBg).Border(0.5f).Padding(2)
                                .AlignCenter().AlignMiddle().Text(s).Bold().FontSize(6);
                        void Sh(string s) =>
                            table.Cell().Background(headBg).Border(0.5f).Padding(2)
                                .AlignCenter().AlignMiddle().Text(s).Bold().FontSize(6);

                        Gh("", 1); Gh("HORAS NORMAIS", 4); Gh("HORAS EXTRAS", 4); Gh("", 3); Gh("", 1);
                        foreach (var h in new[]
                                 {
                                     "Data", "Entrada", "Saída", "Manutenção", "Total Horas Normais",
                                     "Entrada", "Saída", "Manut./OP.", "Total Horas Extras",
                                     "Horímetro Inicial", "Horímetro Final", "Horas Trabalhadas", "Observações"
                                 })
                            Sh(h);

                        foreach (var r in rows)
                        {
                            Cell(table, r.Data); Cell(table, r.HoraInicialTxt); Cell(table, r.HoraFinalTxt);
                            Cell(table, r.ManutencaoFormatado); Cell(table, r.TotalHorasNormaisFormatado);
                            Cell(table, r.HoraExtraInicialTxt); Cell(table, r.HoraExtraFinalTxt);
                            Cell(table, r.ManutOpFormatado); Cell(table, r.TotalHorasExtrasFormatado);
                            Cell(table, r.HorimetroInicialFormatado); Cell(table, r.HorimetroFinalFormatado);
                            Cell(table, r.HorimetroTotalFormatado); Cell(table, r.Comentario);
                        }

                        table.Cell().ColumnSpan(3).Background(totBg).Border(0.5f).Padding(2)
                            .AlignRight().AlignMiddle().Text("TOTAL").Bold().FontSize(6);
                        Tot(table, "", totBg); Tot(table, somaHn, totBg);
                        Tot(table, "", totBg); Tot(table, "", totBg); Tot(table, "", totBg);
                        Tot(table, somaHe, totBg); Tot(table, "", totBg); Tot(table, "", totBg);
                        Tot(table, somaHt, totBg); Tot(table, "", totBg);
                    });

                    main.Item().PaddingTop(8).Table(t =>
                    {
                        t.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(); c.RelativeColumn(); c.RelativeColumn();
                            c.RelativeColumn(); c.RelativeColumn();
                        });
                        void Th(string s) => t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2)
                            .AlignCenter().Text(s).Bold().FontSize(6);
                        void Td(string s, bool b = false)
                        {
                            var cell = t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2).AlignCenter();
                            if (b) cell.Text(s).Bold().FontSize(6); else cell.Text(s).FontSize(6);
                        }
                        Th(""); Th("TOTAL APONTAMENTO"); Th("TOTAL MEDIÇÃO"); Th("VALOR DA HORA"); Th("TOTAL MEDIÇÃO");
                        Td("HORAS MANUT."); Td(somaMan, true); Td(""); Td(""); Td("");
                        Td("HORAS NORMAIS"); Td(somaHn, true); Td(""); Td(""); Td("");
                        Td("HORAS EXTRAS"); Td(somaHe, true); Td(""); Td(""); Td("");
                        Td("HORAS HORÍMETRO"); Td(somaHt, true); Td(""); Td(""); Td("");
                        t.Cell().ColumnSpan(2).Border(0.5f).BorderColor("#D3D3D3").Padding(2)
                            .AlignCenter().Text("TOTAL").Bold().FontSize(6);
                        Td(""); Td(""); Td("");
                    });

                    main.Item().PaddingTop(6).Table(t =>
                    {
                        t.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(); c.RelativeColumn(); c.RelativeColumn();
                            c.RelativeColumn(); c.RelativeColumn();
                        });
                        void Th(string s) => t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2)
                            .AlignCenter().Text(s).Bold().FontSize(6);
                        void Td(string s) => t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2)
                            .AlignCenter().Text(s).FontSize(6);
                        Th(""); Th("QUANTIDADE ABASTECIDA"); Th("PREÇO DO COMB."); Th("VALOR");
                        Th("ABASTECIDO P/ HORIMETRO RODADO (LITROS)");
                        Td("COMBUSTÍVEL"); Td(""); Td(""); Td(""); Td("");
                    });

                    main.Item().PaddingTop(6).Width(220).Table(t =>
                    {
                        t.ColumnsDefinition(c => { c.RelativeColumn(2); c.RelativeColumn(); });
                        t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2).Text("Horas mínimas mês").FontSize(6);
                        t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2);
                        t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2).Text("Hora extra").FontSize(6);
                        t.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2);
                    });
                });
            });
        }).GeneratePdf();
    }

    private static void Cell(TableDescriptor table, string? text) =>
        table.Cell().Border(0.5f).BorderColor("#D3D3D3").Padding(2).AlignCenter().Text(text ?? "").FontSize(6);

    private static void Tot(TableDescriptor table, string text, Color bg) =>
        table.Cell().Background(bg).Border(0.5f).Padding(2).AlignCenter().AlignMiddle().Text(text).Bold().FontSize(6);

    /// <summary>
    /// Excel OOXML (.xlsx) — HTML-.xls abre no desktop mas o Excel Android marca como corrompido.
    /// </summary>
    private static byte[] BuildExcelXlsx(string obra, string equipamento, string periodo, List<HoraRow> rows)
    {
        var somaHe = rows.Sum(x => x.TotalHorasExtras ?? 0).ToString("N", HorimetroFormat);
        var somaHn = rows.Sum(x => x.TotalHorasNormais ?? 0).ToString("N", HorimetroFormat);
        var somaHt = rows.Sum(x => x.HorimetroTotal ?? 0).ToString("N", HorimetroFormat);
        var somaMan = rows.Sum(x => x.SomaTotalHorasManut ?? 0).ToString("N", HorimetroFormat);

        var sheet = new StringBuilder(16_384);
        sheet.Append("""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>""");
        sheet.Append("""<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">""");
        sheet.Append("<sheetData>");

        var r = 1;
        void Row(params string?[] cells)
        {
            sheet.Append($"<row r=\"{r}\">");
            for (var i = 0; i < cells.Length; i++)
            {
                var col = XlsxColName(i + 1);
                sheet.Append($"<c r=\"{col}{r}\" t=\"inlineStr\"><is><t>{XlsxEsc(cells[i])}</t></is></c>");
            }
            sheet.Append("</row>");
            r++;
        }

        Row("rdo", "CONTROLE DE HORAS");
        Row("Equipamento", equipamento, "Período", periodo);
        Row("Frente de Serviço", obra);
        Row();
        Row(
            "",
            "HORAS NORMAIS", "", "", "",
            "HORAS EXTRAS", "", "", "",
            "", "", "", "");
        Row(
            "Data", "Entrada", "Saída", "Manutenção", "Total Horas Normais",
            "Entrada", "Saída", "Manut./OP.", "Total Horas Extras",
            "Horímetro Inicial", "Horímetro Final", "Horas Trabalhadas", "Observações");

        foreach (var row in rows)
        {
            Row(
                row.Data,
                row.HoraInicialTxt,
                row.HoraFinalTxt,
                row.ManutencaoFormatado,
                row.TotalHorasNormaisFormatado,
                row.HoraExtraInicialTxt,
                row.HoraExtraFinalTxt,
                row.ManutOpFormatado,
                row.TotalHorasExtrasFormatado,
                row.HorimetroInicialFormatado,
                row.HorimetroFinalFormatado,
                row.HorimetroTotalFormatado,
                row.Comentario);
        }

        Row("TOTAL", "", "", "", somaHn, "", "", "", somaHe, "", "", somaHt, "");
        Row();
        Row("", "TOTAL APONTAMENTO", "TOTAL MEDIÇÃO", "VALOR DA HORA", "TOTAL MEDIÇÃO");
        Row("HORAS MANUT.", somaMan, "", "", "");
        Row("HORAS NORMAIS", somaHn, "", "", "");
        Row("HORAS EXTRAS", somaHe, "", "", "");
        Row("HORAS HORÍMETRO", somaHt, "", "", "");
        Row("TOTAL", "", "", "", "");
        Row();
        Row("", "QUANTIDADE ABASTECIDA", "PREÇO DO COMB.", "VALOR", "ABASTECIDO P/ HORIMETRO RODADO (LITROS)");
        Row("COMBUSTÍVEL", "", "", "", "");
        Row();
        Row("Horas mínimas mês", "");
        Row("Hora extra", "");

        sheet.Append("</sheetData></worksheet>");

        return PackXlsx(sheet.ToString());
    }

    private static string XlsxColName(int index1Based)
    {
        var n = index1Based;
        var name = "";
        while (n > 0)
        {
            n--;
            name = (char)('A' + n % 26) + name;
            n /= 26;
        }
        return name;
    }

    private static string XlsxEsc(string? value)
    {
        if (string.IsNullOrEmpty(value)) return "";
        return WebUtility.HtmlEncode(value)
            .Replace("\r\n", "&#10;")
            .Replace("\n", "&#10;")
            .Replace("\r", "&#10;");
    }

    private static byte[] PackXlsx(string sheet1Xml)
    {
        const string contentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
              <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
              <Default Extension="xml" ContentType="application/xml"/>
              <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
              <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
              <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
            </Types>
            """;

        const string rootRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
              <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
            </Relationships>
            """;

        const string workbook = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
              <sheets>
                <sheet name="Controle" sheetId="1" r:id="rId1"/>
              </sheets>
            </workbook>
            """;

        const string workbookRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
              <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
              <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
            </Relationships>
            """;

        const string styles = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
              <fonts count="1"><font><sz val="10"/><name val="Arial"/></font></fonts>
              <fills count="1"><fill><patternFill patternType="none"/></fill></fills>
              <borders count="1"><border/></borders>
              <cellStyleXfs count="1"><xf/></cellStyleXfs>
              <cellXfs count="1"><xf xfId="0"/></cellXfs>
            </styleSheet>
            """;

        using var ms = new MemoryStream();
        using (var zip = new ZipArchive(ms, ZipArchiveMode.Create, leaveOpen: true))
        {
            void Put(string path, string content)
            {
                var entry = zip.CreateEntry(path, CompressionLevel.Optimal);
                using var writer = new StreamWriter(entry.Open(), new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
                writer.Write(content);
            }

            Put("[Content_Types].xml", contentTypes);
            Put("_rels/.rels", rootRels);
            Put("xl/workbook.xml", workbook);
            Put("xl/_rels/workbook.xml.rels", workbookRels);
            Put("xl/styles.xml", styles);
            Put("xl/worksheets/sheet1.xml", sheet1Xml);
        }

        return ms.ToArray();
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
