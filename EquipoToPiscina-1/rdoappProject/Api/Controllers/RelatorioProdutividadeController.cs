using rdoappProject.Api.Models;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class RelatorioProdutividadeController : ApiController
    {
        [HttpPost]
        public byte[] GerarRelatorio([FromBody] dynamic param)
        {
            return RelatorioProdutividadeModel.GerarRelatorio(param);
        }
    }
}