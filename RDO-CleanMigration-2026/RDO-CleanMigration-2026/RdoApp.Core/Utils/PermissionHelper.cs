using Microsoft.AspNetCore.Http;
using RdoApp.Core.Models.ViewModels;
using System.Text.Json;

namespace RdoApp.Core.Utils
{
    /// <summary>
    /// Permission Helper - Exact copy of legacy Permission.check() logic
    /// Checks if user has a specific permission for a specific route
    /// Uses session data (LoginViewModel.Routes) like legacy AngularJS system
    /// </summary>
    public static class PermissionHelper
    {
        /// <summary>
        /// Check if user has permission for a specific route
        /// EXACT COPY of legacy Permission.check() logic from app.js
        /// </summary>
        /// <param name="context">HttpContext to access session</param>
        /// <param name="permission">Permission name (e.g. "visualizar", "acessarDashboard")</param>
        /// <param name="route">Route path (e.g. "/chart", "/dashboard/index")</param>
        /// <returns>True if user has permission for route, false otherwise</returns>
        public static bool HasPermission(HttpContext context, string permission, string route)
        {
            var loginDataJson = context.Session.GetString("LoginData");
            
            if (string.IsNullOrEmpty(loginDataJson))
            {
                return false;
            }

            try
            {
                var loginData = JsonSerializer.Deserialize<LoginViewModel>(loginDataJson);
                
                if (loginData?.Routes == null)
                {
                    return false;
                }

                var foundRoute = loginData.Routes.FirstOrDefault(r => r.Path == route);
                if (foundRoute == null)
                {
                    return false;
                }

                if (foundRoute.Permissions == null)
                {
                    return false;
                }

                return foundRoute.Permissions.Contains(permission);
            }
            catch (JsonException)
            {
                return false;
            }
        }

        /// <summary>
        /// Check if user is logged in
        /// </summary>
        public static bool IsLoggedIn(HttpContext context)
        {
            return context.User?.Identity?.IsAuthenticated == true;
        }

        /// <summary>
        /// Get user name from authentication
        /// </summary>
        public static string GetUserName(HttpContext context)
        {
            return context.User?.Identity?.Name ?? "Unknown User";
        }
    }
}
