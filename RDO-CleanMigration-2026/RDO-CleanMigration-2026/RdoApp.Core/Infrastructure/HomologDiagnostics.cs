using Microsoft.AspNetCore.Hosting;

namespace RdoApp.Core.Infrastructure;

/// <summary>Homolog (Staging): cabeçalhos e mensagens para F12 → Rede → Cabeçalhos.</summary>
public static class HomologDiagnostics
{
    public const string HeaderDiag = "X-RdoApp-Diag";
    public const string HeaderRedirectReason = "X-RdoApp-Redirect-Motivo";

    public static void SetDiag(HttpContext ctx, string message)
    {
        if (!ctx.RequestServices.GetRequiredService<IWebHostEnvironment>().IsStaging())
        {
            return;
        }

        ctx.Response.Headers[HeaderDiag] = message;
    }

    public static void SetRedirectMotivo(HttpContext ctx, string motivo)
    {
        if (!ctx.RequestServices.GetRequiredService<IWebHostEnvironment>().IsStaging())
        {
            return;
        }

        ctx.Response.Headers[HeaderRedirectReason] = motivo;
    }

    public static string BuildSnapshot(HttpContext ctx)
    {
        var auth = ctx.User?.Identity?.IsAuthenticated == true ? "logado" : "nao-logado";
        var obra = ObraSessionHelper.HasObraSelected(ctx) ? $"obra={ObraSessionHelper.GetObraId(ctx)}" : "sem-obra";
        var loginData = string.IsNullOrEmpty(ctx.Session.GetString(SessionKeys.LoginData)) ? "sem-LoginData" : "LoginData-ok";
        var path = ctx.Request.Path.Value ?? "/";
        return $"homolog; {path}; {auth}; {obra}; {loginData}";
    }
}
