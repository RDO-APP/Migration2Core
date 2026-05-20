using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace RdoApp.Core.ViewComponents
{
    /// <summary>
    /// View Component wrapper for UnifiedRdoHeader Blazor component
    /// This allows the Blazor component to be used in traditional MVC Views
    /// </summary>
    public class UnifiedRdoHeaderViewComponent : ViewComponent
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UnifiedRdoHeaderViewComponent(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public IViewComponentResult Invoke()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            
            var userName = "Usuário";
            string? obraNome = null;

            if (httpContext?.User?.Identity?.IsAuthenticated == true)
            {
                userName = httpContext.User.Identity.Name ?? "Usuário";
                obraNome = httpContext.Session.GetString("ObraNome");
            }

            ViewData["UserName"] = userName;
            ViewData["ObraNome"] = obraNome;

            return View();
        }
    }
}
