using rdoappClass;
using System.Collections.Generic;
using System.Linq;

namespace rdoappProject.Api.Models
{
    public class StatusRdoModel
    {
        public static List<StatusRdoViewModel> Lista()
        {
            rdoappEntities context = new rdoappEntities();

            IQueryable<status_rdo> query = context.Set<status_rdo>();

            List<StatusRdoViewModel> Lista = new List<StatusRdoViewModel>();
            query.ToList().ForEach(str => Lista.Add(new StatusRdoViewModel
            {
                Id = str.str_id_status,
                Nome = str.str_ds_status

            }));

            return Lista.OrderBy(x => x.Id).ToList();
        }

        public class StatusRdoViewModel
        {
            public long Id { get; set; }
            public string Nome { get; set; }
        }
    }
}