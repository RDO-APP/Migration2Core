using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.StaticFiles;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Services.Interfaces;
using RdoApp.Core.Services.Implementations;
using RdoApp.Core.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Adicionar serviços ao container
builder.Services.AddControllersWithViews();

// Add Blazor Server services for TaskCard component
builder.Services.AddServerSideBlazor(options =>
{
    // Enable detailed errors in development
    options.DetailedErrors = builder.Environment.IsDevelopment();
    
    // Increase circuit timeout for debugging
    options.DisconnectedCircuitRetentionPeriod = TimeSpan.FromMinutes(3);
    
    // Log circuit activity
    options.JSInteropDefaultCallTimeout = TimeSpan.FromMinutes(1);
});

// Add Razor Pages for Blazor components
builder.Services.AddRazorPages();

// Add HttpClient for API calls
builder.Services.AddHttpClient();

// Add HttpContextAccessor for NavigationService
builder.Services.AddHttpContextAccessor();

// Entity Framework - MySQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrEmpty(connectionString))
{
    // Fallback para AWS RDS
    connectionString = "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;";
}

builder.Services.AddDbContext<RdoContext>(options =>
    options.UseMySql(connectionString, ServerVersion.Create(new Version(8, 0, 30), Pomelo.EntityFrameworkCore.MySql.Infrastructure.ServerType.MySql)));

// Configurar logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Serviços customizados - Day 6 Semana 2
builder.Services.AddScoped<ITarefaService, TarefaService>();
// NEW: Task Cards Gilberto Implementation - Etapa Service
builder.Services.AddScoped<IEtapaService, EtapaService>();
// Day 8 - Authentication Service
builder.Services.AddScoped<IAuthService, AuthService>();
// Step 4 - Laudo Service (Critical for Day 9)
builder.Services.AddScoped<ILaudoService, LaudoService>();
// Step 5 - RDO Service (Core Business Logic)
builder.Services.AddScoped<IRdoService, RdoService>();
// IMPROVEMENT 2: Service Injection Pattern - Obra Service
builder.Services.AddScoped<IObraService, ObraService>();
// RDO Soul Restoration Services - Professional Dark Theme & Action Toolbar
builder.Services.AddScoped<IActionButtonService, ActionButtonService>();
builder.Services.AddScoped<INavigationService, NavigationService>();
builder.Services.AddScoped<IThemeConfigurationService, ThemeConfigurationService>();
// builder.Services.AddScoped<IColaboradorService, ColaboradorService>();

// Configurar Session - Required for ObraController
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// Configurar Authentication - FORCE AccountController paths
builder.Services.AddAuthentication("Cookies")
    .AddCookie("Cookies", options =>
    {
        options.LoginPath = "/Account/Login";  // FORCE new Razor login
        options.LogoutPath = "/Account/Logout"; 
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        options.Cookie.Name = "RdoApp.Auth"; // Custom cookie name to avoid conflicts
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    });

builder.Services.AddAuthorization();

// Configurar Swagger para desenvolvimento
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();
}

var app = builder.Build();

// Configurar pipeline de requisições
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
else
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// CRITICAL: Static files MUST be FIRST in pipeline - before any custom logic
var provider = new FileExtensionContentTypeProvider();
// Ensure fontello.css and font files are served with correct MIME types
provider.Mappings[".css"] = "text/css";
provider.Mappings[".woff"] = "font/woff";
provider.Mappings[".woff2"] = "font/woff2";
provider.Mappings[".ttf"] = "font/ttf";
provider.Mappings[".eot"] = "application/vnd.ms-fontobject";

app.UseStaticFiles(new StaticFileOptions
{
    ContentTypeProvider = provider,
    OnPrepareResponse = ctx =>
    {
        // Development: Disable caching for CSS/JS to prevent 404 cache issues
        if (app.Environment.IsDevelopment())
        {
            var path = ctx.Context.Request.Path.Value?.ToLower();
            if (path?.Contains("/css/") == true || 
                path?.Contains("/js/") == true ||
                path?.Contains("/_content/") == true)
            {
                ctx.Context.Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
                ctx.Context.Response.Headers["Pragma"] = "no-cache";
                ctx.Context.Response.Headers["Expires"] = "0";
            }
        }
    }
});

app.UseRouting();

// Session middleware - Must be after UseRouting
app.UseSession();

// Authentication middleware - Must be after UseRouting
app.UseAuthentication();
app.UseAuthorization();

// CRITICAL FIX: Add Antiforgery middleware for MVC forms with @Html.AntiForgeryToken()
// Must be AFTER UseAuthorization, BEFORE endpoint mapping
app.UseAntiforgery();

// Map endpoints - Controllers FIRST, then Blazor
app.MapControllers();

// Map Blazor Hub for TaskCard component (AFTER controllers to avoid conflicts)
app.MapBlazorHub();

// Map Razor Pages for Blazor components
app.MapRazorPages();

// CLEAN ROUTING: Single default route for MVC
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=RedirectToBlazorLogin}/{id?}");

app.Run();
