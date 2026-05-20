using System.Collections.Generic;

namespace rdoappProject.Api.Models
{
    public class RouteModel
    {
        public string Name { get; set; }
        public string Path { get; set; }
        public List<string> Permissions { get; set; }
    }
}
