using rdoappProject.Api.Models;
using System.Collections.Generic;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class RamoController : ApiController
    {
        [HttpGet]
        public List<RamoViewModel> Lista()
        {
            return RamoModel.Lista();
        }
        [HttpPost]
        public bool Atualizar([FromBody] dynamic param)
        {
            return RamoModel.Atualizar(param);
        }
        [HttpPost]
        public bool Remover([FromBody] dynamic param)
        {
            return RamoModel.Remove(param);
        }
    }
}