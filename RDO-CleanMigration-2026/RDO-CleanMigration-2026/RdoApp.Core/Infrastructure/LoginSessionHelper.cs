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
