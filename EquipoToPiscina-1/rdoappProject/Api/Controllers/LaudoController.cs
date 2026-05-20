using rdoappProject.Api.Models;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class LaudoController : ApiController
    {
        [HttpPost]
        public List<LaudoViewModel> DashboardGrafico(dynamic param)
        {
            return LaudoModel.DashboardGrafico(param);
        }

        [HttpPost]
        public PagedList CarregarLista(dynamic param)
        {
            return PagedList.create((int)param.page, 10, LaudoModel.Lista(param));
        }

        [HttpPost]
        public HttpResponseMessage Salvar([FromBody] dynamic param)
        {
            try
            {
                LaudoViewModel retorno = LaudoModel.Salvar(param);
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
            return RdoModel.Deletar(param);
        }

        [HttpPost]
        public RdoViewModel ObterRdo([FromBody] dynamic param)
        {
            return RdoModel.ObterRegistro(param);
        }

        [HttpPost]
        public byte[] GerarDocumentoLaudo([FromBody] dynamic param)
        {
            int idRdo = param.idRdo ?? 0;
            bool gerarRelatorioFotografico = param.gerarRelatorioFotografico;
            return LaudoModel.GerarDocumentoRdo(idRdo, gerarRelatorioFotografico);
        }

        [HttpPost]
        public bool Assinar([FromBody] dynamic param)
        {
            return RdoModel.Assinar(param);
        }
    }
}