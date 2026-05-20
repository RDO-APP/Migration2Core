using Microsoft.AspNetCore.Authentication.Cookies;

namespace RdoApp.Core.Configuration
{
    public static class SecurityConfiguration
    {
        public static void ConfigureAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.LoginPath = "/Auth/Login";
                    options.LogoutPath = "/Auth/Logout";
                    options.AccessDeniedPath = "/Auth/AccessDenied";
                    options.ExpireTimeSpan = TimeSpan.FromHours(8);
                    options.SlidingExpiration = true;
                    options.Cookie.HttpOnly = true;
                    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                    options.Cookie.SameSite = SameSiteMode.Strict;
                    options.Cookie.Name = "RdoApp.Auth";
                });
        }

        public static void ConfigureSecurityHeaders(this IApplicationBuilder app)
        {
            app.Use(async (context, next) =>
            {
                // Security headers
                context.Response.Headers["X-Content-Type-Options"] = "nosniff";
                context.Response.Headers["X-Frame-Options"] = "DENY";
                context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
                context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
                context.Response.Headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()";
                
                // Content Security Policy
                var csp = "default-src 'self'; " +
                         "script-src 'self' 'unsafe-inline' 'unsafe-eval'; " +
                         "style-src 'self' 'unsafe-inline'; " +
                         "img-src 'self' data: https:; " +
                         "font-src 'self'; " +
                         "connect-src 'self'; " +
                         "frame-ancestors 'none';";
                
                context.Response.Headers["Content-Security-Policy"] = csp;
                
                await next();
            });
        }

        public static void ConfigureRequestLimiting(this IApplicationBuilder app)
        {
            app.Use(async (context, next) =>
            {
                // Request size limiting is handled by Kestrel configuration
                // This middleware can be used for additional request validation
                await next();
            });
        }
    }
}
