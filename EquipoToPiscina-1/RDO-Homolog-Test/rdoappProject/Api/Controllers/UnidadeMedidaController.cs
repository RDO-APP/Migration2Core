using rdoappProject.Api.Models;
using System.Collections.Generic;
using System.Web.Http;
using static rdoappProject.Api.Models.UnidadeMedidaModel;

namespace rdoappProject.Api.Controllers
{
    public class UnidadeMedidaController : ApiController
    {
        public List<UnidadeMedidaViewModel> Lista()
        {
            return UnidadeMedidaModel.Lista();
        }
    }
}