using rdoappClass;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace rdoappProject.Api.Models
{
    public class EtapaModel
    {
        private IQueryable<etapa> Filter(EtapaViewModel filter, rdoappEntities context)
        {
            IQueryable<etapa> query = context.etapa;
            if (filter != null)
            {
                if (filter.Id > 0)
                {
                    query = query.Where(e => e.eta_id_etapa == filter.Id);
                }
                if (!string.IsNullOrEmpty(filter.Titulo))
                {
                    query = query.Where(e => e.eta_ds_etapa.Contains(filter.Titulo));
                }

                query = query.Where(e => e.obra.obr_id_obra == filter.IdObra);

                if (!string.IsNullOrEmpty(filter.descricao))
                {
                    query = query.Where(e => e.tarefa.All(t => t.tar_ds_tarefa.ToLower().Contains(filter.descricao.ToLower())));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(x => x.tar_ds_tarefa.ToLower().Contains(filter.descricao.ToLower())).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
                if (filter.dataInicial > DateTime.MinValue)
                {

                    query = query.Where(tar => tar.tarefa.Any(t => t.tar_dt_inicio == filter.dataInicial.Date));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => t.tar_dt_inicio == filter.dataInicial.Date).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
                if (filter.dataFinalPlanejada > DateTime.MinValue)
                {
                    query = query.Where(tar => tar.tarefa.Any(t => t.tar_dt_previsao_fim == filter.dataFinalPlanejada.Date));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => t.tar_dt_previsao_fim?.Date == filter.dataFinalPlanejada.Date)?.ToList();
                    }

                    query = tempEtapas.AsQueryable();

                }
                if (filter.dataInicialExecutada > DateTime.MinValue)
                {
                    List<int> idTarefas = ObterTarefasDataMedicaoInicial(filter.dataInicialExecutada, filter.IdObra);
                    query = query.Where(tar => tar.tarefa.Any(t => idTarefas.Contains(t.tar_id_tarefa)));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => idTarefas.Contains(t.tar_id_tarefa)).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
                if (filter.dataFinalExecutada > DateTime.MinValue)
                {
                    query = query.Where(tar => tar.tarefa.Any(t => t.tar_dt_medicao == filter.dataFinalExecutada.Date));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => t.tar_dt_medicao == filter.dataFinalExecutada.Date).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
                if (filter.idStatus > 0)
                {
                    query = query.Where(e => e.tarefa.Any(t => t.tar_id_status == filter.idStatus));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => t.tar_id_status == filter.idStatus).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
                if (filter.DataMedicao != null && filter.DataMedicao != DateTime.MinValue)
                {
                    var dataMedicao = ((DateTime)filter.DataMedicao);
                    query = query.Where(e => e.tarefa.Any(t => t.tar_dt_medicao == dataMedicao));

                    var tempEtapas = query.ToList();

                    foreach (var etapa in tempEtapas)
                    {
                        etapa.tarefa = etapa.tarefa.Where(t => t.tar_dt_medicao == dataMedicao).ToList();
                    }

                    query = tempEtapas.AsQueryable();
                }
            }
            return query;
        }

        public static List<EtapaViewModel> Lista(dynamic param)
        {
            rdoappEntities context = new rdoappEntities();

            string nome = param.titulo.ToString();
            int idObra = String.IsNullOrEmpty(param.idObra.ToString()) ? 0 : Convert.ToInt32(param.idObra);
            IQueryable<etapa> query = context.etapa.Where(e => e.obra.obr_id_obra == idObra);

            if (!String.IsNullOrEmpty(nome))
            {
                query = query.Where(e => e.eta_ds_etapa.ToLower().Contains(nome.ToLower()));
            }

            List<EtapaViewModel> Lista = new List<EtapaViewModel>();
            query.ToList().ForEach(et => Lista.Add(new EtapaViewModel
            {
                Titulo = et.eta_ds_etapa,
                Ordem = et.eta_nr_orderm,
                Id = et.eta_id_etapa
            }));

            string orderby = param.orderby ?? "";
            string orderbydescending = param.orderbydescending ?? "";

            if (!string.IsNullOrEmpty(orderby))
            {
                return Lista.OrderBy(x => x.Titulo).ToList();
            }
            if (!string.IsNullOrEmpty(orderbydescending))
            {
                return Lista.OrderByDescending(x => x.Titulo).ToList();
            }

            return Lista.OrderBy(et => et.Ordem).ToList();
        }

        public static int Create(EtapaViewModel view)
        {
            using (var context = new rdoappEntities())
            {
                var entity = EtapaViewModel.ViewToEntity(view);
                if (ExisteEtapaComMesmaOrdem(entity))
                {
                    throw new System.Exception("Já existe uma Etapa cadastrada com o mesmo número de ordem. Por favor, verifique!");
                }
                else
                {
                    context.etapa.Add(EtapaViewModel.ViewToEntity(view));
                    var result = context.SaveChanges();
                    return result;
                }
            }
        }
        public static List<EtapaViewModel> Retrieve(EtapaViewModel filter, bool rdo = false)
        {
            var result = new List<EtapaViewModel>();

            using (var context = new rdoappEntities())
            {
                IQueryable<etapa> query = new EtapaModel().Filter(filter, context);

                var list = query.OrderBy(x => x.eta_nr_orderm).ToList();

                if (list.Count > 0)
                {
                    foreach (var item in list)
                    {
                        result.Add(new EtapaViewModel(item, rdo));
                    }
                }
            }

            return result;
        }

        public static List<EtapaViewModel> ObterEtapasParaRDO(EtapaViewModel filter)
        {
            var result = new List<EtapaViewModel>();

            using (var context = new rdoappEntities())
            {
                IQueryable<etapa> query = context.etapa.Where(et => et.eta_id_obra == filter.IdObra);
                var list = query.OrderBy(x => x.eta_nr_orderm).ToList();

                if (list.Count > 0)
                {
                    foreach (var item in list)
                    {
                        if (item.tarefa.Count > 0)
                        {
                            EtapaViewModel etapa = new EtapaViewModel();

                            etapa.Id = item.eta_id_etapa;
                            etapa.Titulo = item.eta_ds_etapa;
                            etapa.IdObra = item.obra != null ? item.obra.obr_id_obra : item.eta_id_obra;
                            etapa.TituloObra = item.obra != null ? item.obra.obr_ds_obra : "";
                            etapa.Ordem = item.eta_nr_orderm;

                            if (item.tarefa.Count > 0)
                            {
                                etapa.Tarefas = new List<TarefaViewModel>();

                                foreach (var itemTar in item.tarefa.Where(l => l.tar_id_status != 1).OrderByDescending(o => o.tar_id_tarefa).OrderByDescending(t => t.tar_dt_medicao).ThenByDescending(t => t.tar_dt_medicao_hora_inicial).GroupBy(t => t.tar_nr_agrupador).Select(t => t.FirstOrDefault()).ToList())
                                {
                                    if (itemTar.tar_id_status != 1)
                                    {
                                        TarefaViewModel newTar = new TarefaViewModel(itemTar, filter.DataMedicao, item.obra.obr_dt_inicio);
                                        newTar.ListaImagem = TarefaModel.ObterTodasImagensHistoricoMedicao(itemTar.tar_nr_agrupador, filter.DataMedicao.Value.Date);
                                        etapa.Tarefas.Add(newTar);
                                    }
                                }

                                etapa.Tarefas = etapa.Tarefas.OrderBy(tar => tar.OrdemStatus).ThenBy(tar => tar.OrdemDataInicial).ToList();
                            }
                            result.Add(etapa);
                        }

                    }
                }
            }

            return result.Where(et => et.Tarefas.Count() > 0).ToList();
        }

        public static int Update(EtapaViewModel view)
        {
            using (var context = new rdoappEntities())
            {
                var entity = context.etapa.Find(view.Id);
                entity.eta_ds_etapa = view.Titulo;

                context.etapa.Add(entity);
                context.Entry(entity).State = System.Data.Entity.EntityState.Modified;

                var result = context.SaveChanges();
                return result;
            }
        }
        public static int Delete(int id)
        {
            using (var context = new rdoappEntities())
            {
                var entity = context.etapa.Find(id);
                context.etapa.Remove(entity);
                var result = 0;
                try
                {
                    result = context.SaveChanges();
                }
                catch
                {
                    throw new System.Exception("Não foi possível excluir a etapa. Existem registros dependentes!");
                }

                return result;
            }
        }
        internal static EtapaViewModel CreateRetrieve(EtapaViewModel view)
        {
            using (var context = new rdoappEntities())
            {
                var entity = EtapaViewModel.ViewToEntity(view);

                if (ExisteEtapaComMesmaOrdem(entity))
                {
                    throw new System.Exception("Já existe uma Etapa cadastrada com o mesmo número de ordem. Por favor, verifique!");
                }
                else
                {
                    context.etapa.Add(entity);
                    context.SaveChanges();
                    var viewComplete = new EtapaViewModel(entity);
                    return viewComplete;
                }
            }
        }
        internal static bool ExisteEtapaComMesmoNome(etapa entity)
        {
            using (var context = new rdoappEntities())
            {
                var result = context.etapa.Any(e => e.eta_ds_etapa.Contains(entity.eta_ds_etapa) && e.eta_id_obra == entity.eta_id_obra);
                return result;
            }
        }
        internal static bool ExisteEtapaComMesmaOrdem(etapa entity)
        {
            using (var context = new rdoappEntities())
            {
                var result = context.etapa.Any(e => e.eta_nr_orderm == entity.eta_nr_orderm && e.eta_id_obra == entity.eta_id_obra && e.eta_id_etapa != entity.eta_id_etapa);
                return result;
            }
        }

        internal static EtapaViewModel ObterEtapa(int id)
        {
            EtapaViewModel etapa = new EtapaViewModel();
            rdoappEntities context = new rdoappEntities();
            etapa mirror = context.etapa.FirstOrDefault(et => et.eta_id_etapa == id);
            etapa.Id = id;
            etapa.IdObra = mirror.eta_id_obra;
            etapa.Titulo = mirror.eta_ds_etapa;
            etapa.Ordem = mirror.eta_nr_orderm;

            return etapa;
        }

        internal static int AtualizarEtapa(EtapaViewModel etapa)
        {
            rdoappEntities context = new rdoappEntities();
            etapa eta = context.etapa.FirstOrDefault(et => et.eta_id_etapa == etapa.Id);
            eta.eta_ds_etapa = etapa.Titulo;
            eta.eta_nr_orderm = etapa.Ordem;
            if (ExisteEtapaComMesmaOrdem(eta))
            {
                throw new System.Exception("Já existe uma Etapa cadastrada com o mesmo número de ordem. Por favor, verifique!");
            }

            var result = context.SaveChanges();
            return result;
        }
        internal static List<int> ObterTarefasDataMedicaoInicial(DateTime dataInicial, int idObra)
        {
            rdoappEntities context = new rdoappEntities();
            List<Guid> agrupador = new List<Guid>();
            List<int> idsTarefas = new List<int>();
            if (dataInicial != null && dataInicial != DateTime.MinValue)
            {
                agrupador = context.tarefa.Where(t => t.etapa.eta_id_obra == idObra).OrderBy(t => t.tar_dt_medicao).GroupBy(t => t.tar_nr_agrupador).Select(t => t.FirstOrDefault()).Where(t => t.tar_dt_medicao == dataInicial.Date).Select(t => t.tar_nr_agrupador).ToList();
            }
            idsTarefas = context.tarefa.Where(t => t.etapa.eta_id_obra == idObra && agrupador.Contains(t.tar_nr_agrupador)).OrderByDescending(t => t.tar_dt_medicao).Select(t => t.tar_id_tarefa).ToList();

            return idsTarefas;
        }

        public static List<EtapaViewModel> ObterEtapaTarefa(EtapaViewModel filter)
        {
            var context = new rdoappEntities();

            IQueryable<etapa> query = context.etapa;

            query = query.Where(e => e.eta_id_obra == filter.IdObra);

            if (filter.Id > 0)
            {
                query = query.Where(e => e.eta_id_etapa == filter.Id);
            }

            var listTemp = query.OrderBy(x => x.eta_nr_orderm).ToList();

            var list = new List<EtapaViewModel>();

            foreach (var item in listTemp)
            {
                var listTarefa = new List<TarefaViewModel>();
                var tarefas = item.tarefa;

                if (filter.dataInicial > DateTime.MinValue)
                {
                    if (filter.dataFinalPlanejada > DateTime.MinValue)
                    {
                        tarefas = tarefas.Where(t => t.tar_dt_inicio >= filter.dataInicial.Date && t.tar_dt_previsao_fim <= filter.dataFinalPlanejada).ToList();
                    }
                    else
                    {
                        tarefas = tarefas.Where(t => t.tar_dt_inicio == filter.dataInicial.Date).ToList();
                    }
                }
                else if (filter.dataFinalPlanejada > DateTime.MinValue)
                {
                    tarefas = tarefas.Where(t => t.tar_dt_previsao_fim == filter.dataFinalPlanejada.Date).ToList();
                }

                if (filter.dataInicialExecutada > DateTime.MinValue)
                {
                    if (filter.dataFinalExecutada > DateTime.MinValue)
                    {
                        tarefas = tarefas.Where(t => t.tar_dt_medicao >= filter.dataInicialExecutada.Date && t.tar_dt_medicao <= filter.dataFinalExecutada).ToList();
                    }
                    else
                    {
                        tarefas = tarefas.Where(t => t.tar_dt_medicao == filter.dataInicialExecutada.Date).ToList();
                    }
                }
                else if (filter.dataFinalExecutada > DateTime.MinValue)
                {
                    tarefas = tarefas.Where(t => t.tar_dt_medicao == filter.dataFinalExecutada.Date).ToList();
                }

                tarefas = tarefas.OrderByDescending(t => t.tar_id_tarefa).ThenByDescending(t => t.tar_dt_medicao).ThenByDescending(t => t.tar_dt_medicao_hora_final).GroupBy(t => t.tar_nr_agrupador).Select(t => t.FirstOrDefault()).ToList();

                if (!string.IsNullOrEmpty(filter.descricao))
                {
                    tarefas = tarefas.Where(t => t.tar_ds_tarefa.ToLower().Contains(filter.descricao.ToLower())).ToList();
                }

                if (filter.idStatus > 0)
                {
                    tarefas = tarefas.Where(t => t.tar_id_status == filter.idStatus).ToList();
                }

                if (tarefas.Count > 0)
                {
                    foreach (var t in tarefas)
                    {
                        var percentualConcluido = TarefaModel.CalcularPercentualConcluido(t);

                        listTarefa.Add(new TarefaViewModel
                        {
                            Id = t.tar_id_tarefa,
                            Descricao = t.tar_ds_tarefa,
                            NomeStatus = t.status_tarefa.stt_ds_status,
                            DataInicio = t.tar_dt_inicio.Date.ToString().Substring(0, 10),
                            DataPrevisaoFim = t.tar_dt_previsao_fim == null ? "" : t.tar_dt_previsao_fim.ToString().Substring(0, 10),
                            PrimeiraExecucao = TarefaModel._ObterPrimeiroDiaExecutado(t.tar_nr_agrupador),
                            UltimaExecucao = TarefaModel._ObterUltimoDiaExecutado(t.tar_nr_agrupador),
                            QuantidadeColaboradores = t.obra_tarefa_colaborador.Count,
                            QuantidadeEquipamentos = t.obra_tarefa_equipamento.Count,
                            OrdemStatus = TarefaModel.AjustarOrdenamentoTarefas(t.status_tarefa.stt_ds_status),
                            OrdemDataInicial = t.tar_dt_inicio,
                            PercentualConcluido = percentualConcluido > 100 ? 100 : percentualConcluido,
                            PercentualExtrapolado = (percentualConcluido > 100) ? "false" : "true",
                            ClasseStatusCss = t.tar_id_status == 1 ? "bg-cinza" : (t.tar_id_status == 2 ? "bg-azul" : (t.tar_id_status == 3 ? "bg-verde" : (t.tar_id_status == 4 ? "bg-laranja" : (t.tar_id_status == 5 ? "bg-vermelho" : "bg-cinza")))),
                            ExisteExecucao = t.tar_id_status == 1,
                            listaStatusPermitidos = TarefaModel.PreencherStatusTarefaPermitidos(t)
                        });
                    }
                }

                list.Add(new EtapaViewModel
                {
                    Id = item.eta_id_etapa,
                    Titulo = item.eta_ds_etapa,
                    Tarefas = listTarefa.OrderBy(tar => tar.OrdemStatus).ThenBy(tar => tar.OrdemDataInicial).ThenBy(tar => tar.Descricao).ToList()
                });
            }

            return list;
        }
    }
    public class EtapaViewModel
    {
        public int Id { get; set; }
        public string Titulo { get; set; }
        public int Ordem { get; set; }
        public int IdObra { get; set; }
        public string TituloObra { get; set; }

        #region Campos da Tarefa
        /// <summary>
        /// Descrição da Tarefa
        /// </summary>
        public string descricao { get; set; }
        /// <summary>
        /// Data de Inicial da Tarefa
        /// </summary>
        public DateTime dataInicial { get; set; }
        /// <summary>
        /// Data Final Planejada da Tarefa
        /// </summary>
        [DisplayFormat(DataFormatString = "{dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime dataFinalPlanejada { get; set; }
        /// <summary>
        /// Data Inicial da Tarefa
        /// </summary>
        public DateTime dataInicialExecutada { get; set; }
        /// <summary>
        /// Data Final Executada da Tarefa
        /// </summary>
        public DateTime dataFinalExecutada { get; set; }
        /// <summary>
        /// Id do Status da Tarefa
        /// </summary>
        public int idStatus { get; set; }
        /// <summary>
        /// Campo para ser utilizado para filtrar a listagem de tarefas no RDO
        /// </summary>
        public DateTime? DataMedicao { get; set; }
        #endregion Campos da Tarefa       

        public ObraViewModel Obra { get; set; }
        public List<TarefaViewModel> Tarefas { get; set; }
        public EtapaViewModel() { }
        public EtapaViewModel(etapa entity, bool rdo = false)
        {
            if (entity != null)
            {
                Id = entity.eta_id_etapa;
                Titulo = entity.eta_ds_etapa;
                IdObra = entity.obra != null ? entity.obra.obr_id_obra : entity.eta_id_obra;
                TituloObra = entity.obra != null ? entity.obra.obr_ds_obra : "";
                Ordem = entity.eta_nr_orderm;

                if (entity.tarefa.Count > 0)
                {
                    Tarefas = new List<TarefaViewModel>();

                    if (rdo)
                    {
                        foreach (var item in entity.tarefa.Where(t => t.tar_id_status == 2 || t.tar_id_status == 4).OrderByDescending(t => t.tar_dt_medicao).ThenByDescending(t => t.tar_dt_medicao_hora_inicial).GroupBy(t => t.tar_nr_agrupador).Select(t => t.FirstOrDefault()).ToList())
                        {
                            Tarefas.Add(new TarefaViewModel(item));
                        }
                    }
                    else
                    {
                        foreach (var item in entity.tarefa.OrderByDescending(t => t.tar_dt_medicao).ThenByDescending(t => t.tar_dt_medicao_hora_inicial).GroupBy(t => t.tar_nr_agrupador).Select(t => t.FirstOrDefault()).ToList())
                        {
                            Tarefas.Add(new TarefaViewModel(item));
                        }
                    }
                    Tarefas = Tarefas.OrderBy(tar => tar.OrdemStatus).ThenBy(tar => tar.OrdemDataInicial).ToList();
                }
            }
        }
        internal static etapa ViewToEntity(EtapaViewModel view)
        {
            if (view != null)
            {
                var entity = new etapa();
                entity.eta_id_etapa = view.Id;
                entity.eta_ds_etapa = view.Titulo;
                entity.eta_nr_orderm = view.Ordem;
                entity.eta_id_obra = view.IdObra;
                return entity;
            }
            return null;
        }
    }
}