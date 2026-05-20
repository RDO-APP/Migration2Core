using rdoappProject.Api.Models;
using System.Web.Http;

namespace rdoappProject.Api.Controllers
{
    public class DashboardController : ApiController
    {
        [HttpPost]
        public object CarregarDashboards(dynamic param)
        {
            return DashboardModel.CarregarDashboards(param);
        }
    }
}