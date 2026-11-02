using System.Data;
using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Services;

/// <summary>M7 7b — PDF do RDO. L9: QuestPDF (RDLC/ReportViewer explode DBNull→String no homolog).</summary>
public class RdoPdfService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private static readonly NumberFormatInfo HorimetroFormat = CreateHorimetroFormat();
    private static readonly Color Navy = Color.FromHex("#28496f");
    private static readonly Color GrayBar = Color.FromHex("#f4f4f4");
    private static readonly Color Grid = Color.FromHex("#D3D3D3");

    static RdoPdfService()
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
    private readonly IWebHostEnvironment _env;
    private readonly IConfiguration _configuration;
    private readonly ILogger<RdoPdfService> _logger;

    public RdoPdfService(
        RdoDbContext context,
        IWebHostEnvironment env,
        IConfiguration configuration,
        ILogger<RdoPdfService> logger)
    {
        _context = context;
        _env = env;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<byte[]> GenerateAsync(int obraId, int idRdo, bool gerarRelatorioFotografico, CancellationToken cancellationToken)
    {
        try
        {
            return await GenerateAsyncCore(obraId, idRdo, gerarRelatorioFotografico, cancellationToken);
        }
        catch (InvalidOperationException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"PDF.gerar: {ex.GetType().Name}: {ex.Message}", ex);
        }
    }

    private static async Task<T> Step<T>(string name, Func<Task<T>> work)
    {
        try
        {
            return await work();
        }
        catch (InvalidOperationException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"PDF.{name}: {ex.GetType().Name}: {ex.Message}", ex);
        }
    }

    private async Task<byte[]> GenerateAsyncCore(int obraId, int idRdo, bool gerarRelatorioFotografico, CancellationToken cancellationToken)
    {
        // Não materializar entidade Rdo/Obra: colunas NULL (clima opcional) + string não-nullable = InvalidCast DBNull (L10).
        var rdoRow = await _context.Rdos.AsNoTracking()
            .Where(r => r.RdoIdRdo == idRdo && r.RdoIdObra == obraId)
            .Select(r => new
            {
                r.RdoIdRdo,
                r.RdoIdObra,
                r.RdoDtRdo,
                r.RdoIdStatus,
                r.RdoIdColaborador,
                ComentarioAssinatura = (string?)r.RdoDsComentarioAssinatura,
                ComentarioGeracao = (string?)r.RdoDsComentarioGeracao,
                ClimaManha = (string?)r.RdoDsClimaManha,
                ClimaTarde = (string?)r.RdoDsClimaTarde,
                ClimaNoite = (string?)r.RdoDsClimaNoite,
                ChuvaManha = (string?)r.RdoDsChuvaManha,
                ChuvaTarde = (string?)r.RdoDsChuvaTarde,
                ChuvaNoite = (string?)r.RdoDsChuvaNoite,
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (rdoRow == null)
        {
            throw new InvalidOperationException("RDO não encontrado para esta obra.");
        }

        var rdo = new Rdo
        {
            RdoIdRdo = rdoRow.RdoIdRdo,
            RdoIdObra = rdoRow.RdoIdObra,
            RdoDtRdo = rdoRow.RdoDtRdo,
            RdoIdStatus = rdoRow.RdoIdStatus,
            RdoIdColaborador = rdoRow.RdoIdColaborador,
            RdoDsComentarioAssinatura = rdoRow.ComentarioAssinatura ?? "",
            RdoDsComentarioGeracao = rdoRow.ComentarioGeracao ?? "",
            RdoDsClimaManha = rdoRow.ClimaManha ?? "",
            RdoDsClimaTarde = rdoRow.ClimaTarde ?? "",
            RdoDsClimaNoite = rdoRow.ClimaNoite ?? "",
            RdoDsChuvaManha = rdoRow.ChuvaManha ?? "",
            RdoDsChuvaTarde = rdoRow.ChuvaTarde ?? "",
            RdoDsChuvaNoite = rdoRow.ChuvaNoite ?? "",
        };

        var hasImagens = await _context.RdoImagens.AsNoTracking()
            .AnyAsync(ri => ri.RimIdRdo == idRdo, cancellationToken);
        // Prod: se há rdo_imagem, o relatório fotográfico entra mesmo sem o flag do cliente.
        gerarRelatorioFotografico = hasImagens || gerarRelatorioFotografico;

        var obraRow = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == rdo.RdoIdObra)
            .Select(o => new
            {
                o.ObrIdObra,
                o.ObrIdMunicipio,
                o.ObrDtInicio,
                o.ObrDtPrevisaoFim,
                Nome = (string?)o.ObrDsObra,
                Logradouro = (string?)o.ObrDsLogradouro,
                Numero = (string?)o.ObrDsNumero,
                Complemento = (string?)o.ObrDsComplemento,
                Bairro = (string?)o.ObrDsBairro,
                Cep = (string?)o.ObrDsCep,
                Foto = (string?)o.ObrDsFoto,
            })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new InvalidOperationException("Obra do RDO não encontrada.");

        var obra = new Obra
        {
            ObrIdObra = obraRow.ObrIdObra,
            ObrIdMunicipio = obraRow.ObrIdMunicipio,
            ObrDtInicio = obraRow.ObrDtInicio,
            ObrDtPrevisaoFim = obraRow.ObrDtPrevisaoFim,
            ObrDsObra = obraRow.Nome ?? "",
            ObrDsLogradouro = obraRow.Logradouro ?? "",
            ObrDsNumero = obraRow.Numero ?? "",
            ObrDsComplemento = obraRow.Complemento ?? "",
            ObrDsBairro = obraRow.Bairro ?? "",
            ObrDsCep = obraRow.Cep ?? "",
            ObrDsFoto = obraRow.Foto ?? "",
        };

        var municipioNome = await _context.Municipios.AsNoTracking()
            .Where(m => m.MunIdMunicipio == obra.ObrIdMunicipio)
            .Select(m => (string?)m.MunDsMunicipio)
            .FirstOrDefaultAsync(cancellationToken) ?? "";
        var ufId = await _context.Municipios.AsNoTracking()
            .Where(m => m.MunIdMunicipio == obra.ObrIdMunicipio)
            .Select(m => (int?)m.MunIdUf)
            .FirstOrDefaultAsync(cancellationToken);
        var ufSigla = ufId == null
            ? ""
            : await _context.UFs.AsNoTracking()
                .Where(u => u.UfeIdUf == ufId.Value)
                .Select(u => (string?)u.UfeDsSigla)
                .FirstOrDefaultAsync(cancellationToken) ?? "";

        var statusLabel = await _context.StatusRdos.AsNoTracking()
            .Where(s => s.StrIdStatus == rdo.RdoIdStatus)
            .Select(s => (string?)s.StrDsStatus)
            .FirstOrDefaultAsync(cancellationToken) ?? "";

        var donoCc = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            where oc.OcoIdObra == obraId && rdo.RdoIdColaborador != null && oc.OcoIdColaborador == rdo.RdoIdColaborador
            select (string?)oc.OcoStContratanteContratada
        ).FirstOrDefaultAsync(cancellationToken) ?? "";

        var dtCargos = await Step("cargos", () => BuildCargosTableAsync(idRdo, cancellationToken));
        var dtEquip = await Step("equipamentos", () => BuildEquipamentosTableAsync(idRdo, cancellationToken));
        var dtTarefas = await Step("tarefas", () => BuildTarefasTableAsync(idRdo, cancellationToken));
        var dtClima = BuildClimaTable(rdo);
        var dtAcidentes = await Step("acidentes", () => BuildAcidentesTableAsync(rdo, obraId, cancellationToken));
        var (dtAssinaturaContratante, dtAssinaturaContratada) =
            await Step("assinaturas", () => BuildAssinaturasAsync(idRdo, cancellationToken));
        var dtImagem = await Step("imagens", () => BuildImagensTableAsync(idRdo, gerarRelatorioFotografico, cancellationToken));
        var dtDadosRdo = BuildDadosRdoTable(rdo, obra, statusLabel);

        try
        {
            return RenderPdf(
            rdo,
            obra,
            municipioNome,
            ufSigla,
            statusLabel,
            donoCc,
            dtCargos,
            dtEquip,
            dtTarefas,
            dtClima,
            dtAcidentes,
            dtAssinaturaContratante,
            dtAssinaturaContratada,
            dtImagem,
            dtDadosRdo,
            gerarRelatorioFotografico);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"PDF.render: {ex.GetType().Name}: {ex.Message}", ex);
        }
    }

    private byte[] RenderPdf(
        Rdo rdo,
        Obra obra,
        string municipioObra,
        string ufSigla,
        string statusLabel,
        string donoCc,
        DataTable dtCargosAgrupados,
        DataTable dtEquipamentosAgrupados,
        DataTable tarefas,
        DataTable dtClima,
        DataTable dtAcidentes,
        DataTable dtAssinaturaContratante,
        DataTable dtAssinaturaContratada,
        DataTable dtImagem,
        DataTable dtDadosRdo,
        bool gerarRelatorioFotografico)
    {
        _ = dtDadosRdo;
        var enderecoObra = BuildEnderecoObra(obra, municipioObra, ufSigla);
        var previsaoFim = obra.ObrDtPrevisaoFim?.Date ?? rdo.RdoDtRdo.Date;
        var diasRestantes = Math.Max(0, (previsaoFim - rdo.RdoDtRdo.Date).Days);
        var diaDaSemana = PtBr.DateTimeFormat.GetDayName(rdo.RdoDtRdo.DayOfWeek);
        var dataStr = rdo.RdoDtRdo.ToString("dd/MM/yyyy");
        var comentarioGeracao = Str(donoCc == "d" ? rdo.RdoDsComentarioGeracao : rdo.RdoDsComentarioAssinatura);
        var comentarioAssinatura = Str(donoCc == "t" ? rdo.RdoDsComentarioGeracao : rdo.RdoDsComentarioAssinatura);
        var logoBytes = TryLoadLogoBytes(obra);

        try
        {
            return Document.Create(doc =>
            {
                doc.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.MarginHorizontal(28);
                    page.MarginVertical(22);
                    page.DefaultTextStyle(t => t.FontSize(9).FontColor("#1a1a1a"));

                    page.Content().Column(col =>
                    {
                        col.Spacing(8);
                        var diasDecorridos = (rdo.RdoDtRdo.AddDays(1) - obra.ObrDtInicio.Date).Days;
                        var previsaoStr = obra.ObrDtPrevisaoFim?.ToString("dd/MM/yyyy", PtBr) ?? "—";
                        col.Item().Element(h => RenderCabecalho(
                            h, logoBytes, Str(obra.ObrDsObra), dataStr, diaDaSemana.ToUpperInvariant(),
                            previsaoStr, obra.ObrDtInicio.ToString("dd/MM/yyyy", PtBr),
                            diasDecorridos, diasRestantes, Str(statusLabel), enderecoObra));

                        TarefasTable(col, tarefas);

                        col.Item().Row(row =>
                        {
                            row.RelativeItem().Element(e => TwoColTable(
                                e, dtCargosAgrupados, "DescricaoCargo", "QuantidadeCargo",
                                "COLABORADORES", "Cargo", "Qtd."));
                            row.ConstantItem(10);
                            row.RelativeItem().Element(e => TwoColTable(
                                e, dtEquipamentosAgrupados, "DescricaoEquipamento", "QuantidadeEquipamento",
                                "EQUIPAMENTOS", "Tipo", "Qtd."));
                        });

                        col.Item().Row(row =>
                        {
                            row.RelativeItem().Element(e => ClimaTable(e, dtClima));
                            row.ConstantItem(10);
                            row.RelativeItem().Element(e => AcidentesTable(e, dtAcidentes));
                        });

                        ComentarioBloco(col, "COMENTÁRIO CONTRATADA:", comentarioGeracao);
                        ComentarioBloco(col, "COMENTÁRIO CONTRATANTE:", comentarioAssinatura);

                        var showT = Assinado(dtAssinaturaContratante);
                        var showD = Assinado(dtAssinaturaContratada);
                        if (showT || showD)
                        {
                            col.Item().Row(row =>
                            {
                                row.RelativeItem().Element(e => AssinaturaBox(e, "ASSINATURA CONTRATANTE", dtAssinaturaContratante, showT));
                                row.ConstantItem(10);
                                row.RelativeItem().Element(e => AssinaturaBox(e, "ASSINATURA CONTRATADA", dtAssinaturaContratada, showD));
                            });
                        }

                        if (gerarRelatorioFotografico && HasFotoBytes(dtImagem))
                        {
                            GrayTitle(col, "RELATÓRIO FOTOGRÁFICO");
                            Fotos(col, dtImagem);
                        }
                    });

                    page.Footer().Row(row =>
                    {
                        row.RelativeItem().AlignLeft().Text("RDO App © 2026").FontSize(8).FontColor("#555");
                        row.RelativeItem().AlignRight().Text(t =>
                        {
                            t.CurrentPageNumber().FontSize(8).Bold().FontColor("#333");
                            t.Span(" de ").FontSize(8).Bold().FontColor("#333");
                            t.TotalPages().FontSize(8).Bold().FontColor("#333");
                        });
                    });
                });
            }).GeneratePdf();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Falha ao renderizar PDF RDO {RdoId} (QuestPDF)", rdo.RdoIdRdo);
            var detail = ex.InnerException?.Message ?? ex.Message;
            throw new InvalidOperationException($"Não foi possível gerar o PDF do RDO. {detail}", ex);
        }
    }

    private static void RenderCabecalho(
        IContainer header,
        byte[]? logoBytes,
        string nomeObra,
        string dataStr,
        string diaSemanaUpper,
        string previsaoFim,
        string inicioObra,
        int diasDecorridos,
        int diasRestantes,
        string statusLabel,
        string enderecoObra)
    {
        header.Column(col =>
        {
            col.Item().Row(row =>
            {
                if (logoBytes is { Length: > 0 })
                {
                    row.ConstantItem(78).Height(42).Image(logoBytes).FitArea();
                    row.ConstantItem(8);
                }

                row.RelativeItem(2).Column(c =>
                {
                    c.Item().Text("RELATÓRIO DIÁRIO DE OBRA").Bold().FontSize(11);
                    c.Item().PaddingTop(4).Text(nomeObra).Bold().FontSize(10);
                });

                row.RelativeItem(3).Background(GrayBar).Padding(6).Table(t =>
                {
                    t.ColumnsDefinition(d =>
                    {
                        d.RelativeColumn(1.15f);
                        d.RelativeColumn(1);
                    });

                    t.Cell().Text(txt =>
                    {
                        txt.Span("Data do RDO: ").FontSize(7);
                        txt.Span(dataStr).Bold().FontSize(7);
                        txt.Span("  ");
                        txt.Span(diaSemanaUpper).Bold().Underline().FontSize(7);
                    });
                    t.Cell().Text(txt =>
                    {
                        txt.Span("Dias Decorridos: ").FontSize(7);
                        txt.Span(diasDecorridos.ToString()).Bold().FontSize(7);
                    });
                    t.Cell().PaddingTop(3).Text(txt =>
                    {
                        txt.Span("Previsão Final Obra: ").FontSize(7);
                        txt.Span(previsaoFim).Bold().FontSize(7);
                    });
                    t.Cell().PaddingTop(3).Text(txt =>
                    {
                        txt.Span("Dias Restantes: ").FontSize(7);
                        txt.Span(diasRestantes.ToString()).Bold().FontSize(7);
                    });
                    t.Cell().PaddingTop(3).Text(txt =>
                    {
                        txt.Span("Início da Obra: ").FontSize(7);
                        txt.Span(inicioObra).Bold().FontSize(7);
                    });
                    t.Cell().PaddingTop(3).Text(txt =>
                    {
                        txt.Span("Status RDO: ").FontSize(7);
                        txt.Span(statusLabel).Bold().FontSize(7);
                    });
                });
            });

            col.Item().PaddingTop(8).Text(enderecoObra).Bold().FontSize(9);
        });
    }

    private static void GrayTitle(ColumnDescriptor col, string title)
    {
        col.Item().Background(GrayBar).Border(0.5f).BorderColor(Grid).Padding(4)
            .Text(title).Bold().FontSize(9);
    }

    private static IContainer GridCell(IContainer c, bool header = false) =>
        header
            ? c.Border(0.5f).BorderColor(Grid).Background(GrayBar).Padding(3)
            : c.Border(0.5f).BorderColor(Grid).Padding(3);

    private static string Cell(DataRow row, string column)
    {
        if (!row.Table.Columns.Contains(column) || row.IsNull(column))
        {
            return "";
        }

        return Convert.ToString(row[column], PtBr) ?? "";
    }

    private static List<DataRow> RealRows(DataTable dt, string keyColumn)
    {
        return dt.Rows.Cast<DataRow>()
            .Where(r => !string.IsNullOrWhiteSpace(Cell(r, keyColumn)))
            .ToList();
    }

    private static void TwoColTable(
        IContainer box,
        DataTable dt,
        string c1,
        string c2,
        string titulo,
        string h1,
        string h2)
    {
        var rows = RealRows(dt, c1);
        var total = rows.Sum(r => int.TryParse(Cell(r, c2), out var n) ? n : 0);
        box.Table(t =>
        {
            t.ColumnsDefinition(d =>
            {
                d.RelativeColumn(4);
                d.RelativeColumn(1);
            });
            t.Cell().ColumnSpan(2).Element(c => GridCell(c, true)).Text(titulo).Bold().FontSize(9);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text(h1).Bold().FontSize(8);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text(h2).Bold().FontSize(8);
            foreach (var r in rows)
            {
                t.Cell().Element(c => GridCell(c)).Text(Cell(r, c1)).FontSize(8);
                t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, c2)).FontSize(8);
            }

            t.Cell().Element(c => GridCell(c)).Text("Total").Bold().FontSize(8);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text(total.ToString()).Bold().FontSize(8);
        });
    }

    private static void TarefasTable(ColumnDescriptor col, DataTable dt)
    {
        var rows = RealRows(dt, "tar_ds_tarefa");
        col.Item().Table(t =>
        {
            t.ColumnsDefinition(d =>
            {
                d.RelativeColumn(2.6f);
                d.RelativeColumn(1.3f);
                d.ConstantColumn(52);
                d.ConstantColumn(48);
                d.ConstantColumn(42);
                d.RelativeColumn(2.8f);
            });
            t.Cell().ColumnSpan(6).Background(Color.FromHex("#D3D3D3")).Border(0.5f).BorderColor(Grid).Padding(3)
                .Text("ETAPAS / TAREFAS").FontSize(8);

            if (rows.Count == 0)
            {
                t.Cell().ColumnSpan(6).Element(c => GridCell(c)).Text("Nenhuma tarefa neste RDO.").FontSize(8).FontColor("#888");
                return;
            }

            foreach (var grupo in rows.GroupBy(r => Cell(r, "tar_ds_etapa")))
            {
                t.Cell().ColumnSpan(6).Element(c => GridCell(c, true)).Text(grupo.Key).Bold().FontSize(8);
                foreach (var title in new[] { "Descrição", "Status", "Horímetro Inicial", "Horímetro Final", "Total Horas", "Comentário" })
                {
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(title).Bold().FontSize(8);
                }

                foreach (var r in grupo)
                {
                    t.Cell().Element(c => GridCell(c)).Text(Cell(r, "tar_ds_tarefa")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, "tar_ds_status")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, "tar_dt_medicao_horimetro_inicial")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, "tar_dt_medicao_horimetro_final")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, "tar_dt_medicao_horimetro_total")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).Text(Cell(r, "tar_ds_comentario")).FontSize(8);
                }
            }
        });
    }

    private static void ClimaTable(IContainer box, DataTable dt)
    {
        var row0 = dt.Rows.Count > 0 ? dt.Rows[0] : null;
        string V(string col) => row0 == null ? "Não Informado" : Cell(row0, col);
        var linhas = new[]
        {
            ("Manhã", V("ClimaManha"), V("ChuvaManha")),
            ("Tarde", V("ClimaTarde"), V("ChuvaTarde")),
            ("Noite", V("ClimaNoite"), V("ChuvaNoite")),
        };
        box.Table(t =>
        {
            t.ColumnsDefinition(d =>
            {
                d.RelativeColumn(1);
                d.RelativeColumn(1.1f);
                d.RelativeColumn(1.2f);
            });
            t.Cell().ColumnSpan(3).Element(c => GridCell(c, true)).Text("CONDIÇÕES CLIMÁTICAS").Bold().FontSize(9);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text("Período").Bold().FontSize(8);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text("Tempo").Bold().FontSize(8);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text("Chuva").Bold().FontSize(8);
            foreach (var (periodo, tempo, chuva) in linhas)
            {
                t.Cell().Element(c => GridCell(c)).AlignCenter().Text(periodo).FontSize(8);
                t.Cell().Element(c => GridCell(c)).AlignCenter().Text(tempo).FontSize(8);
                t.Cell().Element(c => GridCell(c)).AlignCenter().Text(chuva).FontSize(8);
            }
        });
    }

    private static void AcidentesTable(IContainer box, DataTable dt)
    {
        var rows = RealRows(dt, "aci_ds_acidente");
        box.Table(t =>
        {
            t.ColumnsDefinition(d =>
            {
                d.RelativeColumn(2);
                d.RelativeColumn(1.2f);
            });
            t.Cell().ColumnSpan(2).Element(c => GridCell(c, true)).Text("ACIDENTES").Bold().FontSize(9);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text("Descrição").Bold().FontSize(8);
            t.Cell().Element(c => GridCell(c)).AlignCenter().Text("Houve Afastamento?").Bold().FontSize(8);
            if (rows.Count == 0)
            {
                t.Cell().ColumnSpan(2).Padding(8).AlignCenter().Text("Não houveram acidentes.").FontSize(9);
            }
            else
            {
                foreach (var r in rows)
                {
                    t.Cell().Element(c => GridCell(c)).Text(Cell(r, "aci_ds_acidente")).FontSize(8);
                    t.Cell().Element(c => GridCell(c)).AlignCenter().Text(Cell(r, "aci_st_afastamento")).FontSize(8);
                }
            }
        });
    }

    private static void ComentarioBloco(ColumnDescriptor col, string titulo, string texto)
    {
        if (string.IsNullOrWhiteSpace(texto))
        {
            return;
        }

        GrayTitle(col, titulo);
        col.Item().Padding(4).Text(texto).FontSize(8);
    }

    private static bool Assinado(DataTable dt)
    {
        if (dt.Rows.Count == 0)
        {
            return false;
        }

        var nome = Cell(dt.Rows[0], "responsavel_assinatura");
        return !string.IsNullOrWhiteSpace(nome) &&
               !nome.Equals("Não assinado", StringComparison.OrdinalIgnoreCase);
    }

    private static void AssinaturaBox(IContainer box, string titulo, DataTable dt, bool visivel)
    {
        if (!visivel)
        {
            box.Text("");
            return;
        }

        var r = dt.Rows[0];
        box.Table(t =>
        {
            t.ColumnsDefinition(d =>
            {
                d.RelativeColumn(1.2f);
                d.RelativeColumn(1.4f);
            });
            t.Cell().ColumnSpan(2).Element(c => GridCell(c, true)).Text(titulo).Bold().FontSize(9);
            void Linha(string label, string valor)
            {
                t.Cell().Element(c => GridCell(c)).Text(label).FontSize(8);
                t.Cell().Element(c => GridCell(c)).Text(valor).FontSize(8);
            }

            Linha("Responsável Assinatura:", Cell(r, "responsavel_assinatura"));
            Linha("Data / Hora:", Cell(r, "data_hora"));
            Linha("Cargo:", Cell(r, "cargo"));
            var ip = Cell(r, "ip");
            if (!string.IsNullOrWhiteSpace(ip) && !ip.Equals("Não assinado", StringComparison.OrdinalIgnoreCase))
            {
                Linha("IP:", ip);
            }
        });
    }

    private static void Fotos(ColumnDescriptor col, DataTable dt)
    {
        foreach (DataRow r in dt.Rows)
        {
            var nome = Cell(r, "tarefa");
            var imgs = new[] { "imagem", "imagem1", "imagem2", "imagem3" }
                .Select(cn => r.Table.Columns.Contains(cn) && !r.IsNull(cn) ? r[cn] as byte[] : null)
                .Where(b => b is { Length: > 32 })
                .Cast<byte[]>()
                .ToList();
            if (imgs.Count == 0)
            {
                continue;
            }

            if (!string.IsNullOrWhiteSpace(nome))
            {
                col.Item().PaddingTop(4).Text(nome).SemiBold();
            }

            col.Item().Row(row =>
            {
                foreach (var bytes in imgs)
                {
                    row.RelativeItem().Padding(3).MaxHeight(140).Image(bytes).FitArea();
                }
            });
        }
    }

    private static bool HasFotoBytes(DataTable dt)
    {
        foreach (DataRow r in dt.Rows)
        {
            foreach (var cn in new[] { "imagem", "imagem1", "imagem2", "imagem3" })
            {
                if (r.Table.Columns.Contains(cn) && !r.IsNull(cn) && r[cn] is byte[] { Length: > 0 })
                {
                    return true;
                }
            }
        }

        return false;
    }

    private byte[]? TryLoadLogoBytes(Obra obra)
    {
        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        var webRoot = _env.WebRootPath;
        var contentRoot = _env.ContentRootPath;
        var relative = string.IsNullOrWhiteSpace(obra.ObrDsFoto) ? null : obra.ObrDsFoto.Trim();

        foreach (var candidate in EnumerateLogoCandidates(relative, uploadsRoot, webRoot, contentRoot))
        {
            if (File.Exists(candidate))
            {
                return File.ReadAllBytes(candidate);
            }
        }

        return null;
    }

    private static IEnumerable<string> EnumerateLogoCandidates(
        string? obraFoto,
        string? uploadsRoot,
        string? webRoot,
        string? contentRoot)
    {
        var relatives = new List<string>();
        if (!string.IsNullOrWhiteSpace(obraFoto))
        {
            relatives.Add(obraFoto);
        }

        relatives.AddRange(new[]
        {
            "/images/logo.jpg",
            "/Assets/images/logo.jpg",
            "images/logo.jpg",
            "Assets/images/logo.jpg",
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
            var trimmed = rel.Replace('\\', '/').TrimStart('/');
            var asFs = trimmed.Replace('/', Path.DirectorySeparatorChar);
            foreach (var root in roots)
            {
                if (string.IsNullOrWhiteSpace(root))
                {
                    continue;
                }

                yield return Path.Combine(root.TrimEnd('\\', '/'), asFs);
            }

            if (Path.IsPathRooted(rel) && File.Exists(rel))
            {
                yield return rel;
            }
        }
    }

    private static string BuildEnderecoObra(Obra obra, string municipioObra, string ufSigla)
    {
        var sb = new StringBuilder(obra.ObrDsLogradouro ?? "");
        if (!string.IsNullOrWhiteSpace(obra.ObrDsNumero))
        {
            sb.Append(", ").Append(obra.ObrDsNumero);
        }

        if (!string.IsNullOrWhiteSpace(obra.ObrDsComplemento))
        {
            sb.Append(", ").Append(obra.ObrDsComplemento);
        }

        if (!string.IsNullOrWhiteSpace(obra.ObrDsBairro))
        {
            sb.Append(", ").Append(obra.ObrDsBairro);
        }

        sb.Append(", ").Append(municipioObra).Append(" - ").Append(ufSigla);
        if (!string.IsNullOrWhiteSpace(obra.ObrDsCep) && ulong.TryParse(obra.ObrDsCep, out var cep))
        {
            sb.Append(", CEP: ").Append(cep.ToString("00000-000"));
        }

        sb.Append('.');
        return sb.ToString();
    }

    private async Task<DataTable> BuildCargosTableAsync(int idRdo, CancellationToken cancellationToken)
    {
        var dt = new DataTable();
        dt.Columns.Add("DescricaoCargo");
        dt.Columns.Add("QuantidadeCargo");

        var pairs = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join otc in _context.ObraTarefaColaboradores.AsNoTracking() on rt.RtaIdTarefa equals otc.OtcIdTarefa
            join oc in _context.ObraColaboradores.AsNoTracking() on otc.OtcIdObraColaborador equals oc.OcoIdObraColaborador
            join cargo in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals cargo.CarIdCargo
            where rt.RtaIdRdo == idRdo
            select new { oc.OcoIdColaborador, CarDsCargo = (string?)cargo.CarDsCargo, oc.OcoIdGrupo }
        ).ToListAsync(cancellationToken);

        var distinct = pairs
            .GroupBy(p => new { p.OcoIdColaborador, p.CarDsCargo })
            .Select(g => g.First())
            .ToList();

        var grouped = distinct
            .GroupBy(x => x.CarDsCargo)
            .Select(g => new { DescricaoCargo = g.Key, QuantidadeCargo = g.Count() })
            .OrderBy(x => x.DescricaoCargo);

        foreach (var item in grouped)
        {
            dt.Rows.Add(Str(item.DescricaoCargo), item.QuantidadeCargo.ToString());
        }

        return dt;
    }

    private async Task<DataTable> BuildEquipamentosTableAsync(int idRdo, CancellationToken cancellationToken)
    {
        var dt = new DataTable();
        dt.Columns.Add("DescricaoEquipamento");
        dt.Columns.Add("QuantidadeEquipamento");

        var equipIds = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join ote in _context.ObraTarefaEquipamentos.AsNoTracking() on rt.RtaIdTarefa equals ote.OteIdTarefa
            join oe in _context.ObraEquipamentos.AsNoTracking() on ote.OteIdObraEquipamento equals oe.OeqIdObraEquipamento
            join eq in _context.Equipamentos.AsNoTracking() on oe.OeqIdEquipamento equals eq.EquIdEquipamento
            where rt.RtaIdRdo == idRdo
            select new { eq.EquIdEquipamento, eq.EquIdTipoEquipamento }
        ).ToListAsync(cancellationToken);

        var distinctEquips = equipIds.GroupBy(x => x.EquIdEquipamento).Select(g => g.First()).ToList();
        var tipoIds = distinctEquips.Select(x => x.EquIdTipoEquipamento).Distinct().ToList();
        var tipos = new Dictionary<int, string>();
        if (tipoIds.Count > 0)
        {
            var tipoRows = await _context.TipoEquipamentos.AsNoTracking()
                .Where(t => tipoIds.Contains(t.TeqIdTipoEquipamento))
                .Select(t => new { t.TeqIdTipoEquipamento, Nome = (string?)t.TeqNmTipoEquipamento })
                .ToListAsync(cancellationToken);
            tipos = tipoRows.ToDictionary(t => t.TeqIdTipoEquipamento, t => t.Nome ?? "");
        }

        var grouped = distinctEquips
            .GroupBy(e => e.EquIdTipoEquipamento)
            .Select(g => new
            {
                DescricaoEquipamento = tipos.GetValueOrDefault(g.Key, ""),
                QuantidadeEquipamento = g.Count(),
            })
            .OrderBy(x => x.DescricaoEquipamento);

        foreach (var item in grouped)
        {
            dt.Rows.Add(Str(item.DescricaoEquipamento), item.QuantidadeEquipamento.ToString());
        }

        return dt;
    }

    private async Task<DataTable> BuildTarefasTableAsync(int idRdo, CancellationToken cancellationToken)
    {
        var dt = new DataTable();
        dt.Columns.Add("tar_ds_tarefa");
        dt.Columns.Add("tar_ds_comentario");
        dt.Columns.Add("tar_ds_status");
        dt.Columns.Add("tar_ds_etapa");
        dt.Columns.Add("tar_dt_medicao_horimetro_inicial");
        dt.Columns.Add("tar_dt_medicao_horimetro_final");
        dt.Columns.Add("tar_dt_medicao_horimetro_total");

        var rows = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join t in _context.Tarefas.AsNoTracking() on rt.RtaIdTarefa equals t.TarIdTarefa
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            join st in _context.StatusTarefas.AsNoTracking() on t.TarIdStatus equals st.SttIdStatus
            where rt.RtaIdRdo == idRdo
            select new
            {
                t.TarIdTarefa,
                TarDsTarefa = (string?)t.TarDsTarefa,
                TarDsComentario = (string?)t.TarDsComentario,
                SttDsStatus = (string?)st.SttDsStatus,
                EtaDsEtapa = (string?)e.EtaDsEtapa,
            }
        ).ToListAsync(cancellationToken);

        var horimetro = await TryLoadHorimetroAsync(rows.Select(r => r.TarIdTarefa).ToList(), cancellationToken);

        foreach (var item in rows.OrderBy(o => o.EtaDsEtapa).ThenBy(o => o.TarDsTarefa))
        {
            horimetro.TryGetValue(item.TarIdTarefa, out var h);
            dt.Rows.Add(
                Str(item.TarDsTarefa),
                Str(item.TarDsComentario),
                Str(item.SttDsStatus),
                Str(item.EtaDsEtapa),
                h.Hi ?? "",
                h.Hf ?? "",
                h.Ht ?? "");
        }

        return dt;
    }

    private static DataTable BuildClimaTable(Rdo rdo)
    {
        var dt = new DataTable();
        dt.Columns.Add("ClimaManha");
        dt.Columns.Add("ClimaTarde");
        dt.Columns.Add("ClimaNoite");
        dt.Columns.Add("ChuvaManha");
        dt.Columns.Add("ChuvaTarde");
        dt.Columns.Add("ChuvaNoite");

        static string Clima(string? v) =>
            v == "b" ? "Bom" : v == "r" ? "Ruim" : "Não Informado";

        static string Chuva(string? v) =>
            v == "m" ? "Muita Chuva" : v == "p" ? "Pouca Chuva" : v == "s" ? "Sem Chuva" : "Não Informado";

        dt.Rows.Add(
            Clima(rdo.RdoDsClimaManha),
            Clima(rdo.RdoDsClimaTarde),
            Clima(rdo.RdoDsClimaNoite),
            Chuva(rdo.RdoDsChuvaManha),
            Chuva(rdo.RdoDsChuvaTarde),
            Chuva(rdo.RdoDsChuvaNoite));
        return dt;
    }

    private async Task<DataTable> BuildAcidentesTableAsync(Rdo rdo, int obraId, CancellationToken cancellationToken)
    {
        var dt = new DataTable();
        dt.Columns.Add("aci_ds_acidente");
        dt.Columns.Add("aci_st_afastamento");

        var dataStr = rdo.RdoDtRdo.ToString("dd/MM/yyyy");
        var tarefaIds = await (
            from e in _context.Etapas.AsNoTracking()
            join t in _context.Tarefas.AsNoTracking() on e.EtaIdEtapa equals t.TarIdEtapa
            where e.EtaIdObra == obraId
            select t.TarIdTarefa
        ).ToListAsync(cancellationToken);

        var acidentes = await _context.Acidentes.AsNoTracking()
            .Where(a => tarefaIds.Contains(a.AciIdTarefa))
            .Select(a => new
            {
                a.AciDtDataHora,
                AciDsAcidente = (string?)a.AciDsAcidente,
                AciStAfastamento = (string?)a.AciStAfastamento,
            })
            .ToListAsync(cancellationToken);

        foreach (var aci in acidentes)
        {
            var dtAc = aci.AciDtDataHora ?? DateTime.MinValue;
            if (dtAc.ToString("dd/MM/yyyy") != dataStr)
            {
                continue;
            }

            var afast = aci.AciStAfastamento == "s" ? "Sim" : aci.AciStAfastamento == "n" ? "Não" : "Não Informado";
            dt.Rows.Add(Str(aci.AciDsAcidente), afast);
        }

        return dt;
    }

    private async Task<(DataTable Contratante, DataTable Contratada)> BuildAssinaturasAsync(
        int idRdo,
        CancellationToken cancellationToken)
    {
        var dtContratante = CreateAssinaturaTable();
        var dtContratada = CreateAssinaturaTable();

        var assinaturas = await (
            from ass in _context.AssinaturaRdos.AsNoTracking()
            join oc in _context.ObraColaboradores.AsNoTracking() on ass.AssIdObraColaboradorAssinante equals oc.OcoIdObraColaborador
            join col in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals col.ColIdColaborador
            join cargo in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals cargo.CarIdCargo
            where ass.AssIdRdo == idRdo
            select new
            {
                OcoStContratanteContratada = (string?)oc.OcoStContratanteContratada,
                ColNmColaborador = (string?)col.ColNmColaborador,
                ass.AssDtAssinatura,
                CarDsCargo = (string?)cargo.CarDsCargo,
                AssDsIp = (string?)ass.AssDsIp,
            }
        ).ToListAsync(cancellationToken);

        var contratante = assinaturas.FirstOrDefault(a => a.OcoStContratanteContratada == "t");
        var contratada = assinaturas.FirstOrDefault(a => a.OcoStContratanteContratada == "d");

        if (contratante != null)
        {
            dtContratante.Rows.Add(
                Str(contratante.ColNmColaborador),
                contratante.AssDtAssinatura?.ToString("dd/MM/yyyy HH:mm", PtBr) ?? "",
                Str(contratante.CarDsCargo),
                Str(contratante.AssDsIp));
        }
        else
        {
            dtContratante.Rows.Add("Não assinado", "Não assinado", "Não assinado", "Não assinado");
        }

        if (contratada != null)
        {
            dtContratada.Rows.Add(
                Str(contratada.ColNmColaborador),
                contratada.AssDtAssinatura?.ToString("dd/MM/yyyy HH:mm", PtBr) ?? "",
                Str(contratada.CarDsCargo),
                Str(contratada.AssDsIp));
        }
        else
        {
            dtContratada.Rows.Add("Não assinado", "Não assinado", "Não assinado", "Não assinado");
        }

        return (dtContratante, dtContratada);
    }

    private static DataTable CreateAssinaturaTable()
    {
        var dt = new DataTable();
        dt.Columns.Add("responsavel_assinatura");
        dt.Columns.Add("data_hora");
        dt.Columns.Add("cargo");
        dt.Columns.Add("ip");
        return dt;
    }

    private async Task<DataTable> BuildImagensTableAsync(
        int idRdo,
        bool gerarRelatorioFotografico,
        CancellationToken cancellationToken)
    {
        var dt = new DataTable();
        dt.Columns.Add("tarefa", typeof(string));
        dt.Columns.Add("imagem", typeof(byte[]));
        dt.Columns.Add("idImagem", typeof(string));
        dt.Columns.Add("tarefa1", typeof(string));
        dt.Columns.Add("imagem1", typeof(byte[]));
        dt.Columns.Add("idImagem1", typeof(string));
        dt.Columns.Add("tarefa2", typeof(string));
        dt.Columns.Add("imagem2", typeof(byte[]));
        dt.Columns.Add("idImagem2", typeof(string));
        dt.Columns.Add("tarefa3", typeof(string));
        dt.Columns.Add("imagem3", typeof(byte[]));
        dt.Columns.Add("idImagem3", typeof(string));

        if (!gerarRelatorioFotografico)
        {
            return dt;
        }

        var rawImagens = await (
            from ri in _context.RdoImagens.AsNoTracking()
            join img in _context.Imagens.AsNoTracking() on ri.RimIdImagem equals img.ImaIdImagem
            join t in _context.Tarefas.AsNoTracking() on img.ImaIdTarefa equals t.TarIdTarefa
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            where ri.RimIdRdo == idRdo
            orderby e.EtaNrOrderm, t.TarIdTarefa
            select new
            {
                ri.RimIdImagem,
                Caminho = (string?)img.ImaDsCaminho,
                Etapa = (string?)e.EtaDsEtapa,
                Tarefa = (string?)t.TarDsTarefa,
            }
        ).ToListAsync(cancellationToken);

        var linhas = rawImagens
            .Select(x => new
            {
                x.RimIdImagem,
                ImaDsCaminho = x.Caminho ?? "",
                NomeTarefa = $"{x.Etapa ?? ""} / {x.Tarefa ?? ""}",
            })
            .OrderBy(x => x.NomeTarefa)
            .ToList();

        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        var webRoot = _env.WebRootPath;
        var contentRoot = _env.ContentRootPath;

        for (var i = 0; i < linhas.Count;)
        {
            var nome = linhas[i].NomeTarefa;
            var batch = new List<(string Nome, byte[] Bytes, string Id)>();
            while (i < linhas.Count && batch.Count < 4 && linhas[i].NomeTarefa == nome)
            {
                var bytes = LoadImageBytes(linhas[i].ImaDsCaminho, uploadsRoot, webRoot, contentRoot);
                batch.Add((linhas[i].NomeTarefa, bytes, linhas[i].RimIdImagem.ToString()));
                i++;
            }

            while (batch.Count < 4)
            {
                batch.Add(("", Array.Empty<byte>(), ""));
            }

            dt.Rows.Add(
                batch[0].Nome, batch[0].Bytes, batch[0].Id,
                batch[1].Nome, batch[1].Bytes, batch[1].Id,
                batch[2].Nome, batch[2].Bytes, batch[2].Id,
                batch[3].Nome, batch[3].Bytes, batch[3].Id);
        }

        return dt;
    }

    private async Task<Dictionary<int, (string Hi, string Hf, string Ht)>> TryLoadHorimetroAsync(
        List<int> tarefaIds,
        CancellationToken cancellationToken)
    {
        var map = new Dictionary<int, (string, string, string)>();
        if (tarefaIds.Count == 0)
        {
            return map;
        }

        try
        {
            var ids = string.Join(",", tarefaIds.Distinct());
            var sql =
                "SELECT tar_id_tarefa AS TarId, tar_dt_medicao_horimetro_inicial AS Hi, " +
                "tar_dt_medicao_horimetro_final AS Hf, tar_dt_medicao_horimetro_total AS Ht " +
                "FROM tarefa WHERE tar_id_tarefa IN (" + ids + ")";
            var rows = await _context.Database
                .SqlQueryRaw<HorimetroSqlRow>(sql)
                .ToListAsync(cancellationToken);

            foreach (var row in rows)
            {
                map[row.TarId] = (
                    FormatHorimetro(row.Hi),
                    FormatHorimetro(row.Hf),
                    FormatHorimetro(row.Ht));
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Horímetro indisponível neste catálogo — Hi/Hf/Ht vazios no PDF.");
        }

        return map;
    }

    private static string FormatHorimetro(float? value) =>
        value.HasValue ? value.Value.ToString("N", HorimetroFormat) : "";

    private sealed class HorimetroSqlRow
    {
        public int TarId { get; set; }
        public float? Hi { get; set; }
        public float? Hf { get; set; }
        public float? Ht { get; set; }
    }

    private static byte[] LoadImageBytes(string? caminho, string? uploadsRoot, string? webRoot, string? contentRoot)
    {
        if (string.IsNullOrWhiteSpace(caminho))
        {
            return Array.Empty<byte>();
        }

        var rel = caminho.Replace('\\', '/').Trim();
        if (!rel.StartsWith('/'))
        {
            rel = "/" + rel;
        }

        var underUploads = rel.StartsWith("/Uploads/", StringComparison.OrdinalIgnoreCase)
            ? rel["/Uploads/".Length..]
            : rel.TrimStart('/');

        var candidates = new List<string>();
        void Add(string? root, string tail)
        {
            if (string.IsNullOrWhiteSpace(root))
            {
                return;
            }

            candidates.Add(Path.Combine(root.TrimEnd('\\', '/'), tail.Replace('/', Path.DirectorySeparatorChar)));
        }

        Add(uploadsRoot, underUploads);
        Add(uploadsRoot, rel.TrimStart('/'));
        Add(webRoot, rel.TrimStart('/'));
        Add(webRoot, underUploads);
        Add(contentRoot, rel.TrimStart('/'));
        Add(contentRoot, Path.Combine("Uploads", underUploads));
        Add(contentRoot, Path.Combine("wwwroot", rel.TrimStart('/')));

        foreach (var physical in candidates.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (File.Exists(physical))
            {
                return File.ReadAllBytes(physical);
            }
        }

        return Array.Empty<byte>();
    }

    private static DataTable BuildDadosRdoTable(Rdo rdo, Obra obra, string statusLabel)
    {
        var dt = new DataTable();
        dt.Columns.Add("DataRdo", typeof(string));
        dt.Columns.Add("NomeObra", typeof(string));
        dt.Columns.Add("StatusRdo", typeof(string));
        dt.Rows.Add(
            rdo.RdoDtRdo.ToString("dd/MM/yyyy"),
            Str(obra.ObrDsObra),
            Str(statusLabel));
        return dt;
    }

    private static string Str(string? value) => value ?? "";

    /// <summary>
    /// ReportViewer faz (string)Fields!x.Value. Dataset vazio ou célula DBNull explode (L7/L8).
    /// </summary>
    private static void PrepareRdlcTable(DataTable dt)
    {
        ReplaceDbNulls(dt);
        EnsurePlaceholderRow(dt);
        ReplaceDbNulls(dt);
    }

    private static void EnsurePlaceholderRow(DataTable dt)
    {
        if (dt.Rows.Count > 0)
        {
            return;
        }

        var vals = new object[dt.Columns.Count];
        for (var i = 0; i < dt.Columns.Count; i++)
        {
            vals[i] = dt.Columns[i].DataType == typeof(byte[])
                ? Array.Empty<byte>()
                : "";
        }

        dt.Rows.Add(vals);
    }

    private static void ReplaceDbNulls(DataTable dt)
    {
        foreach (DataRow row in dt.Rows)
        {
            foreach (DataColumn col in dt.Columns)
            {
                if (!row.IsNull(col))
                {
                    continue;
                }

                if (col.DataType == typeof(byte[]))
                {
                    row[col] = Array.Empty<byte>();
                }
                else
                {
                    row[col] = "";
                }
            }
        }
    }
}
