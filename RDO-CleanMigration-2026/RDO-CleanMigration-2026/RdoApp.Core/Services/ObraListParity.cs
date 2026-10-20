using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Services;

/// <summary>Paridade ObraModel.ProgressoPorcentagem / ClasseStatusCss (EQ-L).</summary>
internal static class ObraListParity
{
    public static int ProgressoPorcentagem(Obra obra)
    {
        var inicio = obra.ObrDtInicio.Date;
        var fim = obra.ObrDtPrevisaoFim?.Date;
        if (fim == null || fim <= inicio)
        {
            return 0;
        }

        var atual = DateTime.Now.Date;
        if (atual >= fim)
        {
            return 100;
        }

        if (atual < inicio)
        {
            return 0;
        }

        var total = (fim.Value - inicio).Days;
        if (total <= 0)
        {
            return 0;
        }

        var decorrido = (atual - inicio).Days;
        return (int)Math.Round(100.0 / total * decorrido, MidpointRounding.AwayFromZero);
    }

    public static bool ObraFinalizada(Obra obra)
    {
        if (obra.ObrDtFim == null)
        {
            return true;
        }

        return obra.ObrDtFim.Value == DateTime.MinValue;
    }

    public static string ClasseStatusCss(Obra obra, int progresso, bool existeTarefaPendenteAposPrazo)
    {
        if (progresso == 100)
        {
            return existeTarefaPendenteAposPrazo ? "bg-vermelho" : "bg-verde";
        }

        return "bg-cinza";
    }

    public static string ContratanteContratadaIcon(Grupo? grupo)
    {
        if (grupo?.GruStContratante == 1)
        {
            return "contratante";
        }

        return "contratada";
    }
}
