using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Threading.Tasks;

namespace RdoApp.Core.Middleware
{
    /// <summary>
    /// Protects Razor MVC views from Blazor hot-reload middleware interference.
    /// This middleware prevents BrowserRefreshMiddleware from intercepting and blocking
    /// simple Razor views that don't have Blazor component injection points.
    /// </summary>
    public class RazorViewProtectionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RazorViewProtectionMiddleware> _logger;

        public RazorViewProtectionMiddleware(RequestDelegate next, ILogger<RazorViewProtectionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var path = context.Request.Path.Value?.ToLower();
            
            // Identify Razor MVC views (not Blazor pages)
            bool isRazorView = path?.StartsWith("/obra/") == true ||
                              path?.StartsWith("/tarefa/") == true ||
                              path?.StartsWith("/etapa/") == true ||
                              path?.StartsWith("/account/") == true;
            
            if (isRazorView)
            {
                _logger.LogDebug("Protecting Razor view from hot-reload: {Path}", path);
                
                // Mark this request to skip hot-reload injection
                context.Items["__ASPNETCORE_BROWSER_TOOLS"] = "false";
                context.Items["DOTNET_MODIFIABLE_ASSEMBLIES"] = "false";
                
                // Wrap response stream to prevent buffering by hot-reload middleware
                var originalBodyStream = context.Response.Body;
                using var responseBody = new MemoryStream();
                context.Response.Body = responseBody;
                
                await _next(context);
                
                // Copy response directly without middleware interference
                context.Response.Body = originalBodyStream;
                responseBody.Seek(0, SeekOrigin.Begin);
                await responseBody.CopyToAsync(originalBodyStream);
                
                _logger.LogInformation("Razor view protected and rendered: {Path}", path);
            }
            else
            {
                await _next(context);
            }
        }
    }
}
