using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Middleware;

public class HomologDiagnosticsMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IWebHostEnvironment _env;

    public HomologDiagnosticsMiddleware(RequestDelegate next, IWebHostEnvironment env)
    {
        _next = next;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (_env.IsStaging())
        {
            HomologDiagnostics.SetDiag(context, HomologDiagnostics.BuildSnapshot(context));
        }

        await _next(context);

        if (_env.IsStaging() && !context.Response.HasStarted)
        {
            HomologDiagnostics.SetDiag(context, HomologDiagnostics.BuildSnapshot(context));
        }
    }
}
