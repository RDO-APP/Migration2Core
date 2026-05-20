using rdoappProject.Api.Models;
using System.Collections.Generic;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class SetorController : ApiController
    {
        [HttpGet]
        public List<SetorViewModel> Lista()
        {
            return SetorModel.Lista();
        }

        [HttpPost]
        public bool Atualizar([FromBody] dynamic param)
        {
            return SetorModel.Atualizar(param);
        }

        [HttpPost]
        public bool Remover([FromBody] dynamic param)
        {
            return SetorModel.Remove(param);
        }
    }
}