using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Services;

/// <summary>Paridade ObraModel.ProgressoPorcentagem / ClasseStatusCss (EQ-L).</summary>
internal static class ObraListParity
{
    public static int ProgressoPorcentagem(DateTime obrDtInicio, DateTime? obrDtPrevisaoFim)
    {
        var inicio = obrDtInicio.Date;
        var fim = obrDtPrevisaoFim?.Date;
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

    public static int ProgressoPorcentagem(Obra obra) =>
        ProgressoPorcentagem(obra.ObrDtInicio, obra.ObrDtPrevisaoFim);

    public static bool ObraFinalizada(DateTime? obrDtFim)
    {
        if (obrDtFim == null)
        {
            return true;
        }

        return obrDtFim.Value == DateTime.MinValue;
    }

    public static bool ObraFinalizada(Obra obra) => ObraFinalizada(obra.ObrDtFim);

    public static string ClasseStatusCss(int progresso, bool existeTarefaPendenteAposPrazo)
    {
        if (progresso == 100)
        {
            return existeTarefaPendenteAposPrazo ? "bg-vermelho" : "bg-verde";
        }

        return "bg-cinza";
    }

    public static string ClasseStatusCss(Obra obra, int progresso, bool existeTarefaPendenteAposPrazo) =>
        ClasseStatusCss(progresso, existeTarefaPendenteAposPrazo);

    public static string ContratanteContratadaIcon(int? gruStContratante)
    {
        if (gruStContratante == 1)
        {
            return "contratante";
        }

        return "contratada";
    }

    public static string ContratanteContratadaIcon(Grupo? grupo) =>
        ContratanteContratadaIcon(grupo?.GruStContratante);
}
