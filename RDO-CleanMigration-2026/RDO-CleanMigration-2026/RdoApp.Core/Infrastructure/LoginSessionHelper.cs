using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Infrastructure;

public static class LoginSessionHelper
{
    public static LoginViewModel? TryReadLogin(HttpContext context)
    {
        var json = context.Session.GetString(SessionKeys.LoginData);
        return LoginSessionJson.TryDeserialize(json);
    }

    public static string GetContratanteContratadaUsuario(HttpContext context) =>
        TryReadLogin(context)?.ObraColaborador?.ContratanteContratada ?? "";

    /// <summary>Licença do grupo na obra (paridade ListaPeloGrupo · idLicenca).</summary>
    /// <remarks>Prod grava <c>int.MinValue</c> quando <c>gru_id_licenca</c> é null — tratar como 0 (sem filtro).</remarks>
    public static int GetIdLicenca(HttpContext context)
    {
        var id = TryReadLogin(context)?.ObraColaborador?.IdLicenca ?? 0;
        return id > 0 ? id : 0;
    }

    public static int GetIdObraColaborador(HttpContext context)
    {
        var id = TryReadLogin(context)?.ObraColaborador?.IdObraColaborador ?? 0;
        return id > int.MaxValue ? 0 : (int)id;
    }

    public static int GetColaboradorId(HttpContext context)
    {
        var id = TryReadLogin(context)?.Usuario?.Id ?? 0;
        return id > int.MaxValue ? 0 : (int)id;
    }
}
