using rdoappProject.Api.Models;
using System.Collections.Generic;
using System.Web.Http;
using static rdoappProject.Api.Models.StatusRdoModel;

namespace rdoappProject.Api.Controllers
{
    public class StatusRdoController : ApiController
    {
        public List<StatusRdoViewModel> Lista()
        {
            return StatusRdoModel.Lista();
        }
    }
}