using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Services;

/// <summary>
/// Mirrors EQ-L EtapaModel / TarefaModel fields used on cards.html (M2 C2).
/// </summary>
internal static class CardsTarefaParity
{
    internal sealed class PeriodoExecucao
    {
        public DateTime PrimeiroDia { get; init; }
        public DateTime UltimoDia { get; init; }
    }

    internal static string ClasseStatusCss(int tarIdStatus) =>
        tarIdStatus switch
        {
            1 => "bg-cinza",
            2 => "bg-azul",
            3 => "bg-verde",
            4 => "bg-laranja",
            5 => "bg-vermelho",
            _ => "bg-cinza"
        };

    internal static double CalcularPercentualConcluido(Tarefa tar, PeriodoExecucao? periodo)
    {
        if (tar.TarIdStatus == 1)
        {
            return 0;
        }

        if (periodo == null || (tar.TarDtMedicaoHoraInicial == null && tar.TarDtMedicaoHoraFinal == null))
        {
            return 0;
        }

        if (tar.TarDtPrevisaoFim == null)
        {
            return 0;
        }

        var denominador = (tar.TarDtPrevisaoFim.Value.AddDays(1).Date - tar.TarDtInicio).TotalSeconds;
        if (denominador <= 0)
        {
            return 0;
        }

        var numerador = (periodo.UltimoDia.AddDays(1) - periodo.PrimeiroDia).TotalSeconds;
        return Math.Round(numerador * 100 / denominador, 2);
    }

    internal static string FormatDate(DateTime date) =>
        date.Date.ToString("yyyy-MM-dd");

    internal static string FormatDate(DateTime? date) =>
        date.HasValue ? FormatDate(date.Value) : "";
}
