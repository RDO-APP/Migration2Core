using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Controllers;

namespace RdoApp.Core.Infrastructure;

/// <summary>
/// Entrada MVC → SPA React (P2/P3/P5a). Mesma regra de sessão/obra que Cards.
/// </summary>
public static class OperadorSpaEntry
{
    public static IActionResult? RequireObraOrRedirectToEscolher(Controller controller, HttpContext httpContext)
    {
        if (ObraSessionHelper.HasObraSelected(httpContext))
        {
            return null;
        }

        return controller.RedirectToAction(nameof(ObraController.Escolher), "Obra");
    }

    public static IActionResult ServeSpaIndex(
        Controller controller,
        IWebHostEnvironment env,
        string? razorTitle = null,
        Action<Controller>? configureRazorFallback = null)
    {
        var obraRedirect = RequireObraOrRedirectToEscolher(controller, controller.HttpContext);
        if (obraRedirect != null)
        {
            return obraRedirect;
        }

        var spaIndex = Path.Combine(env.WebRootPath, "app", "index.html");
        if (System.IO.File.Exists(spaIndex))
        {
            HomologDiagnostics.SetDiag(
                controller.HttpContext,
                HomologDiagnostics.BuildSnapshot(controller.HttpContext) + "; acao=ServeSpaIndex-200");
            return controller.PhysicalFile(spaIndex, "text/html");
        }

        if (!string.IsNullOrEmpty(razorTitle))
        {
            controller.ViewData["Title"] = razorTitle;
        }

        controller.ViewData["ObraId"] = ObraSessionHelper.GetObraId(controller.HttpContext);
        controller.ViewData["ObraNome"] = ObraSessionHelper.GetObraNome(controller.HttpContext);
        configureRazorFallback?.Invoke(controller);
        return controller.View();
    }
}
