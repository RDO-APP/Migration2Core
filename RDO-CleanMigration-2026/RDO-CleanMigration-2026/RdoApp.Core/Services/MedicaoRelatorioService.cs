using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>Paridade prod api/medicao/gerarrelatorio + RelatorioModel.Medicao.</summary>
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

    public MedicaoRelatorioService(RdoDbContext context) => _context = context;

    public async Task<(byte[] Bytes, string ContentType, string FileName)> GenerateAsync(
        int obraId,
        MedicaoRelatorioRequestDto request,
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
            .Select(o => new
            {
                o.ObrDsObra,
                o.ObrDsLogradouro,
                o.ObrDsBairro,
                o.ObrIdEmpresaContratada,
            })
            .FirstOrDefaultAsync(ct)
            ?? throw new InvalidOperationException("Obra não encontrada.");

        if (obra.ObrIdEmpresaContratada is null or <= 0)
        {
            throw new InvalidOperationException(
                "Não foi possível gerar o Relatório. É necessário existir uma empresa contratada associada à obra: "
                + (obra.ObrDsObra ?? "") + ".");
        }

        var contratada = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdEmpresa == obra.ObrIdEmpresaContratada)
            .Select(e => e.EmpDsRazaoSocial)
            .FirstOrDefaultAsync(ct) ?? "";

        var periodoRows = await (
            from t in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            join u in _context.UnidadesDeMedida.AsNoTracking() on t.TarIdUnidade equals u.UnmIdUnidade into us
            from u in us.DefaultIfEmpty()
            where e.EtaIdObra == obraId
                  && t.TarIdStatus == StatusEmExecucao
                  && t.TarDtMedicao >= diaIni
                  && t.TarDtMedicao < diaFimExcl
            select new
            {
                t.TarNrAgrupador,
                t.TarIdEtapa,
                Etapa = e.EtaDsEtapa ?? "",
                Tarefa = t.TarDsTarefa ?? "",
                t.TarVlValorUnitario,
                t.TarNrQtdPrevisao,
                t.TarNrQtdConstruida,
                Unidade = u == null
                    ? ""
                    : (!string.IsNullOrEmpty(u.UnmDsSimbolo) ? u.UnmDsSimbolo : u.UnmDsUnidade ?? ""),
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

        var groups = periodoRows.GroupBy(x => x.TarNrAgrupador).ToList();
        var linhas = new List<LinhaMedicao>();
        decimal tgValor = 0, tgPeriodo = 0, tgAcumulado = 0, tgSaldo = 0;

        foreach (var g in groups.OrderBy(x => x.First().Etapa).ThenBy(x => x.First().Tarefa))
        {
            var first = g.First();
            var preco = first.TarVlValorUnitario ?? 0m;
            var qtdPlan = (decimal)(first.TarNrQtdPrevisao ?? 0);
            var valor = preco * qtdPlan;
            var qmPeriodo = g.Sum(x => (decimal)(x.TarNrQtdConstruida ?? 0));
            var qmAcum = acumuladoRows
                .Where(t => t.TarNrAgrupador == first.TarNrAgrupador && t.TarIdEtapa == first.TarIdEtapa)
                .Sum(t => (decimal)(t.TarNrQtdConstruida ?? 0));
            var qmSaldo = qtdPlan - qmAcum;
            var vmPeriodo = qmPeriodo * preco;
            var vmAcum = qmAcum * preco;
            var vmSaldo = valor - vmAcum;

            linhas.Add(new LinhaMedicao(
                first.Etapa, first.Tarefa, first.Unidade,
                qtdPlan, preco, valor, qmPeriodo, qmAcum, qmSaldo, vmPeriodo, vmAcum, vmSaldo));

            tgValor += valor;
            tgPeriodo += vmPeriodo;
            tgAcumulado += vmAcum;
            tgSaldo += vmSaldo;
        }

        var dias = (diaFim - diaIni).Days;
        var prazo = dias / 30 <= 0 ? $"{dias + 1} dia(s)" : $"{dias / 30} mes(es)";
        var periodo = $"De {diaIni:dd/MM/yyyy} Até {diaFim:dd/MM/yyyy}";
        var local = (obra.ObrDsLogradouro ?? "")
            + (!string.IsNullOrWhiteSpace(obra.ObrDsBairro) ? ", " + obra.ObrDsBairro : "");
        var cabeca = new Cabeca(contratada, periodo, obra.ObrDsObra ?? "", local, prazo, tgValor, tgPeriodo, tgAcumulado, tgSaldo);

        var tipo = (request.TipoRelatorio ?? "PDF").Trim();
        var labelIni = diaIni.ToString("dd_MM_yyyy", PtBr);
        var labelFim = diaFim.ToString("dd_MM_yyyy", PtBr);

        if (tipo.Equals("Excel", StringComparison.OrdinalIgnoreCase)
            || tipo.Equals("xls", StringComparison.OrdinalIgnoreCase))
        {
            return (BuildExcel(cabeca, linhas), "application/vnd.ms-excel", $"Medicao_{labelIni}_{labelFim}.xls");
        }

        return (BuildPdf(cabeca, linhas), "application/pdf", $"Medicao_{labelIni}_{labelFim}.pdf");
    }

    private static string N(decimal v) => v.ToString("N", PtBr);

    private static byte[] BuildExcel(Cabeca c, IReadOnlyList<LinhaMedicao> rows)
    {
        var sb = new StringBuilder();
        sb.Append('\uFEFF');
        sb.AppendLine("Relatório de Medição");
        sb.AppendLine($"Contratada\t{c.Contratada}");
        sb.AppendLine($"Serviço\t{c.Servico}");
        sb.AppendLine($"Local\t{c.Local}");
        sb.AppendLine($"Período\t{c.Periodo}");
        sb.AppendLine($"Prazo\t{c.Prazo}");
        sb.AppendLine($"Total valor\t{N(c.TgValor)}\tPeríodo\t{N(c.TgPeriodo)}\tAcumulado\t{N(c.TgAcumulado)}\tSaldo\t{N(c.TgSaldo)}");
        sb.AppendLine();
        sb.AppendLine("Etapa\tTarefa\tUnidade\tQtd planejada\tPreço\tValor\tQm período\tQm acumulado\tQm saldo\tVm período\tVm acumulado\tVm saldo");
        foreach (var r in rows)
        {
            sb.Append(Esc(r.Etapa)).Append('\t').Append(Esc(r.Tarefa)).Append('\t').Append(Esc(r.Unidade)).Append('\t')
                .Append(N(r.QtdPlan)).Append('\t').Append(N(r.Preco)).Append('\t').Append(N(r.Valor)).Append('\t')
                .Append(N(r.QmPeriodo)).Append('\t').Append(N(r.QmAcumulado)).Append('\t').Append(N(r.QmSaldo)).Append('\t')
                .Append(N(r.VmPeriodo)).Append('\t').Append(N(r.VmAcumulado)).Append('\t').Append(N(r.VmSaldo)).AppendLine();
        }
        return Encoding.UTF8.GetBytes(sb.ToString());
    }

    private static string Esc(string s) => s.Replace('\t', ' ').Replace('\r', ' ').Replace('\n', ' ');

    private static byte[] BuildPdf(Cabeca c, IReadOnlyList<LinhaMedicao> rows)
    {
        return Document.Create(doc =>
        {
            doc.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(20);
                page.DefaultTextStyle(t => t.FontSize(8));

                page.Header().Column(col =>
                {
                    col.Item().Background(Navy).Padding(6)
                        .Text("RELATÓRIO DE MEDIÇÃO").FontColor(Colors.White).SemiBold().FontSize(13);
                    col.Item().PaddingTop(6).Text($"Contratada: {c.Contratada}").SemiBold();
                    col.Item().Text($"Serviço: {c.Servico}");
                    col.Item().Text($"Local: {c.Local}");
                    col.Item().Text($"Período: {c.Periodo}  ·  Prazo: {c.Prazo}");
                    col.Item().PaddingTop(2).Text(
                        $"Totais — Valor: {N(c.TgValor)}  ·  Período: {N(c.TgPeriodo)}  ·  Acumulado: {N(c.TgAcumulado)}  ·  Saldo: {N(c.TgSaldo)}");
                });

                page.Content().PaddingTop(8).Table(table =>
                {
                    table.ColumnsDefinition(cols =>
                    {
                        cols.RelativeColumn(1.4f);
                        cols.RelativeColumn(1.6f);
                        cols.ConstantColumn(36);
                        cols.ConstantColumn(48);
                        cols.ConstantColumn(48);
                        cols.ConstantColumn(52);
                        cols.ConstantColumn(48);
                        cols.ConstantColumn(52);
                        cols.ConstantColumn(48);
                        cols.ConstantColumn(52);
                        cols.ConstantColumn(52);
                        cols.ConstantColumn(48);
                    });

                    table.Header(h =>
                    {
                        void Head(string t) => h.Cell().Background(Navy).Padding(2)
                            .Text(t).FontColor(Colors.White).FontSize(7).SemiBold();
                        Head("Etapa"); Head("Tarefa"); Head("Un."); Head("Qtd plan."); Head("Preço"); Head("Valor");
                        Head("Qm per."); Head("Qm acum."); Head("Qm saldo"); Head("Vm per."); Head("Vm acum."); Head("Vm saldo");
                    });

                    foreach (var r in rows)
                    {
                        void Cell(string t) => table.Cell().BorderBottom(0.4f).BorderColor(Colors.Grey.Lighten2)
                            .Padding(2).Text(t).FontSize(7);
                        Cell(r.Etapa); Cell(r.Tarefa); Cell(r.Unidade);
                        Cell(N(r.QtdPlan)); Cell(N(r.Preco)); Cell(N(r.Valor));
                        Cell(N(r.QmPeriodo)); Cell(N(r.QmAcumulado)); Cell(N(r.QmSaldo));
                        Cell(N(r.VmPeriodo)); Cell(N(r.VmAcumulado)); Cell(N(r.VmSaldo));
                    }
                });

                page.Footer().AlignRight().Text(t =>
                {
                    t.Span("RDO App · ").FontSize(7).FontColor("#555");
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