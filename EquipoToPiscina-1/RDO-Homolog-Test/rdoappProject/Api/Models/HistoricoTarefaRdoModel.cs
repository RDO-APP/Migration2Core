using rdoappClass;
using System;

namespace rdoappProject.Api.Models
{
    public class HistoricoTarefaRdoModel
    {
        public static bool Salvar(rdo_tarefa htr)
        {
            rdoappEntities context = new rdoappEntities();

            bool result = context.SaveChanges() > 0;

            return result;
        }

        public static rdo_tarefa TarefaAtual(int idTarefa)
        {
            rdoappEntities context = new rdoappEntities();

            rdo_tarefa h = null;

            return h;
        }

        public static rdo_tarefa ObterHistorico(int idTarefa, DateTime dataHistorico)
        {
            rdoappEntities context = new rdoappEntities();

            rdo_tarefa h = null;

            return h;
        }

    }
}