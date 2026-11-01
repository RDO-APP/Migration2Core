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
}
