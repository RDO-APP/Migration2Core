using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using RdoApp.Core.Data;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Middleware;
using RdoApp.Core.Services;

var builder = WebApplication.CreateBuilder(args);

// ALB termina TLS; Kestrel na EC2 escuta só HTTP (ex.: :5081).
var cookieSecurePolicy = builder.Environment.IsStaging()
    ? CookieSecurePolicy.SameAsRequest
    : CookieSecurePolicy.Always;

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddScoped<RbacRouteService>();
builder.Services.AddScoped<LoginObraService>();
builder.Services.AddScoped<HistoricoLoginWriter>();
builder.Services.AddScoped<CardsQueryService>();
builder.Services.AddScoped<RdoListQueryService>();
builder.Services.AddScoped<RdoCadastroQueryService>();
builder.Services.AddScoped<RdoCadastroSaveService>();
builder.Services.AddScoped<ObrasQueryService>();
builder.Services.AddScoped<ShellContextService>();
builder.Services.AddScoped<RecuperarSenhaService>();

// Configure DbContext with MySQL (Pomelo)
builder.Services.AddDbContext<RdoDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseMySql(
        connectionString,
        ServerVersion.AutoDetect(connectionString),
        mySqlOptions =>
        {
            mySqlOptions.EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(5),
                errorNumbersToAdd: null);
        });
});

// Configure Session
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SecurePolicy = cookieSecurePolicy;
    options.Cookie.SameSite = SameSiteMode.Lax;
    options.Cookie.Path = "/";
});

// Configure Cookie Authentication (instead of Identity)
builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultSignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    })
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = cookieSecurePolicy;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.Path = "/";
        options.Events = new CookieAuthenticationEvents
        {
            // Cookie válido mas pipeline mandou para Login → evita loop Login ↔ ReturnUrl (P5a).
            OnRedirectToLogin = ctx =>
            {
                if (ctx.HttpContext.User?.Identity?.IsAuthenticated == true)
                {
                    HomologDiagnostics.SetRedirectMotivo(
                        ctx.HttpContext,
                        "autenticado-mas-rota-pediu-login; vai-Cards-ou-Escolher-sem-ReturnUrl");
                    ctx.Response.Redirect(
                        ObraSessionHelper.HasObraSelected(ctx.HttpContext)
                            ? "/Tarefa/Cards"
                            : "/Obra/Escolher");
                    return Task.CompletedTask;
                }

                HomologDiagnostics.SetRedirectMotivo(ctx.HttpContext, "nao-autenticado; vai-Login-com-ReturnUrl");
                ctx.Response.Redirect(ctx.RedirectUri);
                return Task.CompletedTask;
            },
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseForwardedHeaders();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}

// HSTS só fora de homolog (Staging atrás do ALB — evita browser preso em HTTPS errado).
if (!app.Environment.IsDevelopment() && !app.Environment.IsStaging())
{
    app.UseHsts();
}


// Staging/homolog: não redirecionar para HTTPS no Kestrel (evita loop/414 atrás do ALB).
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseStaticFiles();

var uploadsRoot = app.Configuration["FileStorage:UploadsRoot"];
if (string.IsNullOrWhiteSpace(uploadsRoot))
{
    var defaultUploads = Path.Combine(app.Environment.ContentRootPath, "Uploads");
    if (Directory.Exists(defaultUploads))
    {
        uploadsRoot = defaultUploads;
    }
}

if (!string.IsNullOrWhiteSpace(uploadsRoot) && Directory.Exists(uploadsRoot))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(uploadsRoot),
        RequestPath = "/Uploads",
    });
}

app.UseRouting();

app.UseSession(); // ✅ Enable session support
app.UseAuthentication();
app.UseAuthorization();
app.UseMiddleware<HomologDiagnosticsMiddleware>();

app.MapStaticAssets();

// EXACT COPY: Redirect root to login (not home)
app.MapGet("/", context =>
{
    context.Response.Redirect("/Account/Login");
    return Task.CompletedTask;
});

app.MapGet("/Chart", () => Results.Redirect("/Chart/Index"));
app.MapGet("/Dashboard", () => Results.Redirect("/Dashboard/Index"));
app.MapGet("/Rdo", () => Results.Redirect("/Rdo/Index"));
app.MapGet("/Tarefa/Paralizacoes", () => Results.Redirect("/Tarefa/Paralizacoes/Index"));
app.MapGet("/Efetivo", () => Results.Redirect("/Efetivo/Index"));
// Nao mapear /efetivo/index nem /rdo/cadastro aqui — colidem (case-insensitive) com rotas MVC /Efetivo/Index e /Rdo/Cadastro.

app.MapControllers();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}")
    .WithStaticAssets();


app.Run();
