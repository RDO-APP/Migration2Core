using rdoappProject.Api.Models;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class TarefaController : ApiController
    {
        [HttpPost]
        public PagedList CarregarLista(dynamic param)
        {
            return PagedList.create((int)param.page, 10, TarefaModel.Lista(param));
        }

        [HttpPost]
        [Route("api/tarefa/paralizacoes/CarregarLista")]
        public PagedList CarregarListaCodigoParalizacoes(dynamic param)
        {
            return PagedList.create((int)param.page, 10, TarefaModel.ListaCodigoParalizacoes(param));
        }

        [HttpGet]
        [Route("api/tarefa/paralizacoes/GetCodigosParalizacoes")]
        public IHttpActionResult GetCodigosParalizacoes()
        {
            return Ok(TarefaModel.GetAllCodigoParalizacoes());
        }

        [HttpPost]
        public List<TarefaViewModel> CarregarListaSimples(dynamic param)
        {
            return TarefaModel.Lista(param);
        }

        [HttpPost]
        public List<HistoricoTarefaViewModel> CarregarHistoricoTarefa(dynamic param)
        {
            int id = Convert.ToInt32(Convert.ToString(param.id));
            return TarefaModel.PreencherHistoricoTarefa(id);
        }

        [HttpPost]
        public float? CarregarHorimetroFinalUltimoHistoricoTarefa(dynamic param)
        {
            int id = Convert.ToInt32(Convert.ToString(param.id));
            var historico = TarefaModel.RecuperarUltimoHistoricoTarefa(id);
            return historico.HorimetroFinal;
        }

        [HttpPost]
        public HttpResponseMessage GerarRelatorioControleHorasEquipamentoTarefa(RelatorioControleHorasEquipamentoTarefaViewModel filter)
        {
            try
            {
                byte[] retorno = TarefaModel.RelatorioControleHorasEquipamentoTarefa(filter);
                return Request.CreateResponse(HttpStatusCode.OK, retorno);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }
        }

        public List<TarefaViewModel> CarregarListaTarefasRdo(dynamic param)
        {
            return TarefaModel.ListaRdo(param);
        }

        [HttpPost]
        public HttpResponseMessage Salvar([FromBody] TarefaViewModel param)
        {
            try
            {
                bool resultado = false;
                if (param.Id > 0)
                {
                    resultado = TarefaModel.Update(param) > 0;
                }
                else
                {
                    resultado = TarefaModel.Salvar(param);
                }
                return Request.CreateResponse(HttpStatusCode.OK, resultado);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }
        }

        [HttpPost]
        [Route("api/tarefa/paralizacoes/salvar")]
        public HttpResponseMessage SalvarCodigoParalizacao([FromBody] TarefaCodigoParalizacaoViewModel param)
        {
            try
            {
                bool resultado = false;
                if (param.update)
                {
                    resultado = TarefaModel.UpdateCodigoParalizacao(param) > 0;
                }
                else
                {
                    resultado = TarefaModel.SalvarCodigoParalizacao(param);
                }
                return Request.CreateResponse(HttpStatusCode.OK, resultado);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }
        }

        public bool AtualizarStatus([FromBody] dynamic param)
        {
            var resultado = TarefaModel.AtualizarStatus(param);
            return true;
        }

        public HttpResponseMessage AtualizarStatusEmMassa([FromBody] dynamic param)
        {
            try
            {
                bool retorno = TarefaModel.AtualizarStatusEmMassa(param);
                return Request.CreateResponse(HttpStatusCode.OK, retorno);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }
        }

        [HttpPost]
        public bool Deletar([FromBody] dynamic param)
        {
            int idTarefa = Convert.ToInt32(param.id);
            return TarefaModel.Deletar(idTarefa);
        }

        [HttpPost]
        [Route("api/tarefa/paralizacoes/excluir")]
        public bool DeletarCodigoParalizacao([FromBody] dynamic param)
        {
            return TarefaModel.DeletarCodigoParalizacao(param.codigoParalizacao);
        }

        [HttpPost]
        public TarefaViewModel ObterTarefa([FromBody] dynamic param)
        {
            return TarefaModel.ObterRegistro(param);
        }

        [HttpPost]
        [Route("api/tarefa/paralizacoes/obterCodigoParalizacao")]
        public TarefaCodigoParalizacaoViewModel obterRegistroCodigoParalizacao([FromBody] dynamic param)
        {
            var result = TarefaModel.ObterCodigoParalizacao(param.codigoParalizacao);
            return result;
        }

        [HttpPost]
        public object ObterImagensTarefa([FromBody] dynamic param)
        {
            return ImagemModel.ObterImagens((int)param);
        }

        [HttpPost]
        [Route("api/tarefa/SalvarLaudo")]
        public HttpResponseMessage SalvarLaudo([FromBody] dynamic param)
        {
            try
            {
                var resultado = TarefaModel.SalvarLaudo(param);
                return Request.CreateResponse(HttpStatusCode.OK, new { success = true, laudoId = resultado, message = "Laudo salvo com sucesso" });
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.OK, new { success = false, message = "Erro ao salvar laudo: " + ex.Message });
            }
        }
    }
}