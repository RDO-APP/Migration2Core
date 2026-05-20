using rdoappClass;
using System;
using System.Collections.Generic;
using System.Linq;

namespace rdoappProject.Api.Models
{
    public class ParametroModel
    {
        public static List<parametro> ObterParametros(dynamic param)
        {
            string descricao = param.descricao;

            rdoappEntities context = new rdoappEntities();
            context.Configuration.LazyLoadingEnabled = false;

            return context.parametro.Where(u => u.par_ds_parametro.ToLower().Contains(descricao)).ToList();
        }

        public static string ObterValor(string alias)
        {
            try
            {
                rdoappEntities bd = new rdoappEntities();
                return bd.parametro.FirstOrDefault(p => p.par_ds_parametro.Contains(alias)).par_vl_parametro;
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
}