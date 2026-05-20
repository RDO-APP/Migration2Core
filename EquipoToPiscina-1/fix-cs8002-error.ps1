# FIX CS8002 ERROR - Top-level statements conflict
# Quick fix for compilation error

Write-Host "FIXING CS8002 ERROR..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current Directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Clean build artifacts that might be causing issues
Write-Host "STEP 1: CLEANING BUILD ARTIFACTS" -ForegroundColor Magenta
Write-Host "Removing bin and obj directories..."

if (Test-Path "bin") {
    Remove-Item "bin" -Recurse -Force
    Write-Host "Removed bin directory" -ForegroundColor Green
}

if (Test-Path "obj") {
    Remove-Item "obj" -Recurse -Force
    Write-Host "Removed obj directory" -ForegroundColor Green
}

Write-Host ""

# Check for duplicate Program.cs or Main method files
Write-Host "STEP 2: CHECKING FOR DUPLICATE PROGRAM FILES" -ForegroundColor Magenta

$programFiles = Get-ChildItem -Recurse -Name "Program.cs" -ErrorAction SilentlyContinue
if ($programFiles.Count -gt 1) {
    Write-Host "WARNING: Multiple Program.cs files found:" -ForegroundColor Red
    foreach ($file in $programFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
} else {
    Write-Host "Only one Program.cs found: OK" -ForegroundColor Green
}

Write-Host ""

# Check for any temporary .cs files that might have top-level statements
Write-Host "STEP 3: CHECKING FOR TEMPORARY CS FILES" -ForegroundColor Magenta

$tempFiles = Get-ChildItem -Name "*.cs" | Where-Object { $_ -match "temp|test|ef-test" }
if ($tempFiles.Count -gt 0) {
    Write-Host "Found temporary .cs files that might cause conflicts:" -ForegroundColor Yellow
    foreach ($file in $tempFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
        $remove = Read-Host "Remove $file? (y/n)"
        if ($remove -eq "y" -or $remove -eq "Y") {
            Remove-Item $file -Force
            Write-Host "Removed $file" -ForegroundColor Green
        }
    }
} else {
    Write-Host "No temporary .cs files found: OK" -ForegroundColor Green
}

Write-Host ""

# Try to build and see if error persists
Write-Host "STEP 4: TESTING COMPILATION" -ForegroundColor Magenta
Write-Host "Attempting to build project..."

try {
    $buildResult = dotnet build --configuration Release --verbosity minimal 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "BUILD SUCCESS: CS8002 error resolved!" -ForegroundColor Green
    } else {
        Write-Host "BUILD FAILED: Error still persists" -ForegroundColor Red
        Write-Host "Build output:" -ForegroundColor Yellow
        Write-Host $buildResult -ForegroundColor Yellow
        
        # Check if it's still CS8002
        if ($buildResult -match "CS8002") {
            Write-Host ""
            Write-Host "CS8002 ERROR STILL PRESENT" -ForegroundColor Red
            Write-Host "This error means multiple files have top-level statements" -ForegroundColor Red
            Write-Host ""
            Write-Host "MANUAL SOLUTION:" -ForegroundColor Yellow
            Write-Host "1. Check if there are any test files in the project" -ForegroundColor Yellow
            Write-Host "2. Look for any .cs files with 'var', 'using' statements at the top level" -ForegroundColor Yellow
            Write-Host "3. Only Program.cs should have top-level statements" -ForegroundColor Yellow
            Write-Host "4. All other .cs files should be in namespaces" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "BUILD ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Alternative solution - convert Program.cs to traditional Main method
Write-Host "STEP 5: ALTERNATIVE SOLUTION" -ForegroundColor Magenta
Write-Host "If error persists, we can convert Program.cs to traditional Main method"

$convertToMain = Read-Host "Convert Program.cs to traditional Main method? (y/n)"
if ($convertToMain -eq "y" -or $convertToMain -eq "Y") {
    Write-Host "Converting Program.cs to traditional Main method..." -ForegroundColor Yellow
    
    # Backup current Program.cs
    Copy-Item "Program.cs" "Program.cs.backup"
    
    # Create traditional Main method version
    $traditionalProgram = @'
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Services.Interfaces;
using RdoApp.Core.Services.Implementations;

namespace RdoApp.Core
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Adicionar serviços ao container
            builder.Services.AddControllersWithViews();

            // Entity Framework - MySQL
            var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback para AWS RDS
                connectionString = "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;";
            }

            builder.Services.AddDbContext<RdoContext>(options =>
                options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

            // Configurar logging
            builder.Logging.ClearProviders();
            builder.Logging.AddConsole();
            builder.Logging.AddDebug();

            // Serviços customizados
            builder.Services.AddScoped<ITarefaService, TarefaService>();
            builder.Services.AddScoped<IAuthService, AuthService>();
            builder.Services.AddScoped<ILaudoService, LaudoService>();
            builder.Services.AddScoped<IRdoService, RdoService>();

            // Configurar Authentication
            builder.Services.AddAuthentication("Cookies")
                .AddCookie("Cookies", options =>
                {
                    options.LoginPath = "/Auth/Login";
                    options.LogoutPath = "/Auth/Logout";
                    options.AccessDeniedPath = "/Auth/AccessDenied";
                    options.ExpireTimeSpan = TimeSpan.FromHours(8);
                    options.SlidingExpiration = true;
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
            app.UseStaticFiles();
            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();

            // Configurar rotas
            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

            app.MapControllerRoute(
                name: "api",
                pattern: "api/{controller}/{action=Index}/{id?}");

            app.Run();
        }
    }
}
'@
    
    $traditionalProgram | Out-File -FilePath "Program.cs" -Encoding UTF8
    Write-Host "Program.cs converted to traditional Main method" -ForegroundColor Green
    
    # Test build again
    Write-Host "Testing build with traditional Main method..." -ForegroundColor Yellow
    $buildResult2 = dotnet build --configuration Release --verbosity minimal 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "BUILD SUCCESS with traditional Main method!" -ForegroundColor Green
    } else {
        Write-Host "BUILD STILL FAILED - Restoring original Program.cs" -ForegroundColor Red
        Copy-Item "Program.cs.backup" "Program.cs" -Force
        Write-Host "Original Program.cs restored" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "CS8002 ERROR FIX COMPLETED" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta

if ($LASTEXITCODE -eq 0) {
    Write-Host "STATUS: BUILD SUCCESSFUL" -ForegroundColor Green
    Write-Host "CS8002 error has been resolved" -ForegroundColor Green
} else {
    Write-Host "STATUS: BUILD STILL FAILING" -ForegroundColor Red
    Write-Host "Manual intervention may be required" -ForegroundColor Red
}

Write-Host ""
Write-Host "Fix completed at: $(Get-Date)" -ForegroundColor Cyan