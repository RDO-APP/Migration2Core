using Microsoft.Reporting.WebForms;
using rdoappClass;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web;

namespace rdoappProject.Api.Models
{
    public class RelatorioModel
    {
        public static byte[] Medicao(RelatorioMedicaoViewModel filter)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("etapa");
            dt.Columns.Add("tarefa");
            dt.Columns.Add("unidade");
            dt.Columns.Add("quantidade");
            dt.Columns.Add("preco");
            dt.Columns.Add("valor");
            dt.Columns.Add("QmPeriodo");
            dt.Columns.Add("QmAcumulado");
            dt.Columns.Add("QmSaldo");
            dt.Columns.Add("VmPeriodo");
            dt.Columns.Add("VmAcumulado");
            dt.Columns.Add("VmSaldo");

            bool licencaLiberaLogo = false;

            decimal TgValor = 0;
            decimal TgNoPeriodo = 0;
            decimal TgAcumulado = 0;
            decimal TgSaldo = 0;

            string contratada = "";
            string periodo = string.Format("De {0} Até {1}", ((DateTime)filter.DataInicial).ToString("dd/MM/yyyy"), ((DateTime)filter.DataPrevisaoFinalObra).ToString("dd/MM/yyyy"));
            string servico = "";
            string logoContratada = "";
            string local = "";
            string prazo = "";

            using (var context = new rdoappEntities())
            {
                if (filter != null)
                {
                    IQueryable<tarefa> query = context.tarefa.Where(t => t.etapa.eta_id_obra == filter.IdObra && t.status_tarefa.stt_id_status == 2);
                    List<tarefa> TodasTarefasAteDataFinalRelatorio = context.tarefa.Where(t => t.etapa.eta_id_obra == filter.IdObra && t.tar_dt_medicao <= filter.DataPrevisaoFinalObra).ToList();


                    if (filter.DataInicial != null)
                    {
                        query = query.Where(t => t.tar_dt_medicao >= filter.DataInicial);
                    }
                    if (filter.DataPrevisaoFinalObra != null)
                    {
                        query = query.Where(t => t.tar_dt_medicao <= filter.DataPrevisaoFinalObra);
                    }

                    var list = query.GroupBy(t => t.tar_nr_agrupador).ToList();

                    if (list.Count <= 0)
                    {
                        throw new Exception("Não existem dados para o filtro informado.");
                    }

                    if (list.First().First().etapa.obra.empresa2 == null)
                    {
                        throw new Exception("Não foi possível gerar o Relatório. É necessário existir uma empresa contratada associada à obra: " + TodasTarefasAteDataFinalRelatorio.FirstOrDefault().etapa.obra.obr_ds_obra + ".");
                    }
                    contratada = list.First().First().etapa.obra.empresa2.emp_ds_razao_social;
                    servico = list.First().First().etapa.obra.obr_ds_obra;
                    logoContratada = list.First().First().etapa.obra.obr_ds_foto;
                    licencaLiberaLogo = list.First().First().etapa.obra.empresa.licenca.lic_st_permite_logo_rdo;
                    local = list.First().First().etapa.obra.obr_ds_logradouro + ((list.First().First().etapa.obra.obr_ds_bairro != null && list.First().First().etapa.obra.obr_ds_bairro != "") ? ", " + list.First().First().etapa.obra.obr_ds_bairro : "");

                    prazo = (((DateTime)filter.DataPrevisaoFinalObra - (DateTime)filter.DataInicial).Days / 30) <= 0
                        ? (((((DateTime)filter.DataPrevisaoFinalObra - (DateTime)filter.DataInicial).Days)) + 1) + " dia(s)"
                        : (((DateTime)filter.DataPrevisaoFinalObra - (DateTime)filter.DataInicial).Days / 30) + " mes(es)";


                    List<TarefasPorHistoricoViewModel> ListaTarefasPorHistorico = new List<TarefasPorHistoricoViewModel>();
                    foreach (var tarefasAgrupada in list)
                    {
                        TarefasPorHistoricoViewModel TarefasPorHistorico = new TarefasPorHistoricoViewModel();
                        var primeiroTarefa = tarefasAgrupada.First();

                        TarefasPorHistorico.precoUnitario = primeiroTarefa.tar_vl_valor_unitario ?? 0;
                        TarefasPorHistorico.descricaoEtapa = primeiroTarefa.etapa.eta_ds_etapa;
                        TarefasPorHistorico.descricaoTarefa = primeiroTarefa.tar_ds_tarefa;
                        TarefasPorHistorico.quantidadePlanejada = Convert.ToDecimal(primeiroTarefa.tar_nr_qtd_previsao);
                        TarefasPorHistorico.valor = Convert.ToDecimal(primeiroTarefa.tar_vl_valor_unitario) * Convert.ToDecimal(primeiroTarefa.tar_nr_qtd_previsao);

                        if (primeiroTarefa.unidade_de_medida != null)
                        {
                            if (string.IsNullOrEmpty(primeiroTarefa.unidade_de_medida.unm_ds_unidade))
                                TarefasPorHistorico.unidadeMedida = string.Empty;
                            else
                            {
                                if (string.IsNullOrEmpty(primeiroTarefa.unidade_de_medida.unm_ds_simbolo))
                                {
                                    TarefasPorHistorico.unidadeMedida = primeiroTarefa.unidade_de_medida.unm_ds_unidade;
                                }
                                else
                                {
                                    TarefasPorHistorico.unidadeMedida = primeiroTarefa.unidade_de_medida.unm_ds_simbolo;

                                }
                            }
                        }

                        foreach (var tarefa in tarefasAgrupada)
                        {
                            TarefasPorHistorico.QmPeriodo += Convert.ToDecimal(tarefa.tar_nr_qtd_construida);
                        }
                        TarefasPorHistorico.QmAcumulado = Convert.ToDecimal(TodasTarefasAteDataFinalRelatorio.Where(t => t.tar_dt_medicao <= filter.DataPrevisaoFinalObra && t.tar_id_etapa == primeiroTarefa.tar_id_etapa && t.tar_nr_agrupador == primeiroTarefa.tar_nr_agrupador).Sum(t => t.tar_nr_qtd_construida)); //Quantidade acumulado do inicio da obra até a data final do relatório
                        TarefasPorHistorico.QmSaldo = TarefasPorHistorico.quantidadePlanejada - TarefasPorHistorico.QmAcumulado;
                        TarefasPorHistorico.VmAcumulado = Convert.ToDecimal(TarefasPorHistorico.QmAcumulado) * Convert.ToDecimal(TarefasPorHistorico.precoUnitario);
                        TarefasPorHistorico.VmPeriodo = Convert.ToDecimal(TarefasPorHistorico.QmPeriodo) * Convert.ToDecimal(TarefasPorHistorico.precoUnitario);
                        TarefasPorHistorico.VmSaldo = TarefasPorHistorico.valor - TarefasPorHistorico.VmAcumulado;

                        TarefasPorHistorico.EtapaTotalValorPlanejado = TarefasPorHistorico.valor;
                        TarefasPorHistorico.EtapaVmAcumulado = TarefasPorHistorico.VmAcumulado;
                        TarefasPorHistorico.EtapaVmPeriodo = TarefasPorHistorico.VmPeriodo;
                        TarefasPorHistorico.EtapaVmSaldo = TarefasPorHistorico.VmSaldo;

                        TgValor += TarefasPorHistorico.valor;
                        TgNoPeriodo += TarefasPorHistorico.VmPeriodo;
                        TgAcumulado += TarefasPorHistorico.VmAcumulado;
                        TgSaldo += TarefasPorHistorico.VmSaldo;
                        ListaTarefasPorHistorico.Add(TarefasPorHistorico);
                    }

                    ListaTarefasPorHistorico.ForEach(ltph =>
                        dt.Rows.Add(ltph.descricaoEtapa, ltph.descricaoTarefa, ltph.unidadeMedida, ltph.quantidadePlanejada.ToString("N", new CultureInfo("is-IS")), ltph.precoUnitario.ToString("N", new CultureInfo("is-IS")), ltph.valor.ToString("N", new CultureInfo("is-IS")), ltph.QmPeriodo.ToString("N", new CultureInfo("is-IS")), ltph.QmAcumulado.ToString("N", new CultureInfo("is-IS")), ltph.QmSaldo.ToString("N", new CultureInfo("is-IS")), ltph.VmPeriodo.ToString("N", new CultureInfo("is-IS")), ltph.VmAcumulado.ToString("N", new CultureInfo("is-IS")), ltph.VmSaldo.ToString("N", new CultureInfo("is-IS")))
                    );
                }
            }

            dt.AcceptChanges();

            string mappath = HttpContext.Current.Server.MapPath("~/Api/Contents/Reports/RelatorioMedicao.rdlc");
            LocalReport ReportViewer = new LocalReport();
            ReportViewer.ReportPath = mappath;
            ReportViewer.EnableExternalImages = true;

            ReportViewer.DataSources.Add(new ReportDataSource("DataSet1", dt));

            ReportViewer.SetParameters(new ReportParameter("contratada", contratada));
            ReportViewer.SetParameters(new ReportParameter("periodo", periodo));
            ReportViewer.SetParameters(new ReportParameter("servico", servico));
            ReportViewer.SetParameters(new ReportParameter("local", local));
            ReportViewer.SetParameters(new ReportParameter("prazo", prazo));
            ReportViewer.SetParameters(new ReportParameter("TgValor", TgValor.ToString("N", new CultureInfo("is-IS"))));
            ReportViewer.SetParameters(new ReportParameter("TgPeriodo", TgNoPeriodo.ToString("N", new CultureInfo("is-IS"))));
            ReportViewer.SetParameters(new ReportParameter("TgAcumulado", TgAcumulado.ToString("N", new CultureInfo("is-IS"))));
            ReportViewer.SetParameters(new ReportParameter("TgSaldo", TgSaldo.ToString("N", new CultureInfo("is-IS"))));

            string basePath = ConfigurationManager.AppSettings["basePath"];
            basePath = basePath.Remove(basePath.Length - 1);

            if (!licencaLiberaLogo || string.IsNullOrEmpty(logoContratada))
            {
                logoContratada = basePath + "/Assets/images/logo.jpg";
                ReportViewer.SetParameters(new ReportParameter("logoContratada", new Uri(HttpContext.Current.Server.MapPath(logoContratada)).AbsoluteUri));
            }
            else
            {
                ReportViewer.SetParameters(new ReportParameter("logoContratada", new Uri(HttpContext.Current.Server.MapPath(basePath + logoContratada)).AbsoluteUri));
            }

            if (filter.TipoRelatorio == TipoRelatorio.Excel)
            {
                return ReportViewer.Render("Excel");
            }
            return ReportViewer.Render("PDF");
        }
    }

    public class RelatorioMedicaoViewModel
    {
        public DateTime? DataInicial { get; set; }
        public DateTime? DataPrevisaoFinalObra { get; set; }
        public int? IdObra { get; set; }
        public int? IdStatusTarefa { get; set; }
        public TipoRelatorio? TipoRelatorio { get; set; }
        public RelatorioMedicaoViewModel() { }
        public RelatorioMedicaoViewModel(dynamic param)
        {
            if (param != null)
            {
                DataInicial = param.dataInicial;
                DataPrevisaoFinalObra = param.dataPrevisaoFinalObra;
                IdObra = param.idObra;
                IdStatusTarefa = param.idStatusTarefa;
                TipoRelatorio = param.tipoRelatorio;
            }
        }
    }

    public class TarefasPorHistoricoViewModel
    {
        public string descricaoEtapa { get; set; }
        public string descricaoTarefa { get; set; }
        public string unidadeMedida { get; set; }
        public decimal quantidadePlanejada { get; set; }
        public decimal precoUnitario { get; set; }
        public decimal valor { get; set; }
        public decimal QmPeriodo { get; set; }
        public decimal QmAcumulado { get; set; }
        public decimal QmSaldo { get; set; }
        public decimal VmPeriodo { get; set; }
        public decimal VmAcumulado { get; set; }
        public decimal VmSaldo { get; set; }
        public decimal EtapaTotalValorPlanejado { get; set; }
        public decimal EtapaVmPeriodo { get; set; }
        public decimal EtapaVmAcumulado { get; set; }
        public decimal EtapaVmSaldo { get; set; }
    }

    public enum TipoRelatorio
    {
        Excel, PDF
    }
}