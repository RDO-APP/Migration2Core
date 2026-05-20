using rdoappProject.Api.Models;
using System.Collections.Generic;
using System.Web.Http;
using static rdoappProject.Api.Models.CargoModel;

namespace rdoappProject.Api.Controllers
{
    public class CargoController : ApiController
    {
        public List<CargoViewModel> Lista()
        {
            return CargoModel.Lista();
        }
    }
}