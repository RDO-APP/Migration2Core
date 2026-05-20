# RUN LEGACY PRODUCTION APPLICATION
# This script helps you run the working AngularJS + .NET Framework application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RUN LEGACY PRODUCTION APPLICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Visual Studio solution exists
$solutionPath = "RDO-Production-Gilberto\solution\rdoapp.sln"
if (-not (Test-Path $solutionPath)) {
    Write-Host "ERROR: Solution file not found at: $solutionPath" -ForegroundColor Red
    Write-Host "Please verify the legacy code is in the correct location." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found legacy solution: $solutionPath" -ForegroundColor Green
Write-Host ""

# Offer options
Write-Host "How would you like to run the legacy application?" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open in Visual Studio (RECOMMENDED)" -ForegroundColor White
Write-Host "   - Opens solution in Visual Studio" -ForegroundColor Gray
Write-Host "   - You can then press F5 to run" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Run with IIS Express (Command Line)" -ForegroundColor White
Write-Host "   - Runs directly without Visual Studio" -ForegroundColor Gray
Write-Host "   - Opens browser automatically" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Show instructions only" -ForegroundColor White
Write-Host "   - Display manual setup instructions" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Opening solution in Visual Studio..." -ForegroundColor Cyan
        Write-Host ""
        
        # Open solution in Visual Studio
        Start-Process $solutionPath
        
        Write-Host "NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Wait for Visual Studio to load" -ForegroundColor White
        Write-Host "2. Wait for NuGet package restore to complete" -ForegroundColor White
        Write-Host "3. Right-click 'rdoappProject' in Solution Explorer" -ForegroundColor White
        Write-Host "4. Select 'Set as Startup Project'" -ForegroundColor White
        Write-Host "5. Press F5 to run the application" -ForegroundColor White
        Write-Host ""
        Write-Host "The application will open in your browser automatically." -ForegroundColor Green
    }
    
    "2" {
        Write-Host ""
        Write-Host "Running with IIS Express..." -ForegroundColor Cyan
        Write-Host ""
        
        # Check if IIS Express exists
        $iisExpressPath = "C:\Program Files\IIS Express\iisexpress.exe"
        if (-not (Test-Path $iisExpressPath)) {
            $iisExpressPath = "C:\Program Files (x86)\IIS Express\iisexpress.exe"
        }
        
        if (-not (Test-Path $iisExpressPath)) {
            Write-Host "ERROR: IIS Express not found" -ForegroundColor Red
            Write-Host "Please install IIS Express or use Visual Studio (Option 1)" -ForegroundColor Yellow
            exit 1
        }
        
        # Navigate to project directory
        $projectPath = "RDO-Production-Gilberto\rdoappProject"
        if (-not (Test-Path $projectPath)) {
            Write-Host "ERROR: Project directory not found at: $projectPath" -ForegroundColor Red
            exit 1
        }
        
        $fullProjectPath = (Resolve-Path $projectPath).Path
        $port = 50000
        
        Write-Host "Starting IIS Express..." -ForegroundColor Green
        Write-Host "Project: $fullProjectPath" -ForegroundColor Gray
        Write-Host "Port: $port" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
        Write-Host ""
        
        # Start IIS Express
        Start-Process $iisExpressPath -ArgumentList "/path:`"$fullProjectPath`"", "/port:$port" -NoNewWindow
        
        # Wait a moment for server to start
        Start-Sleep -Seconds 3
        
        # Open browser
        $url = "http://localhost:$port/"
        Write-Host "Opening browser: $url" -ForegroundColor Green
        Start-Process $url
        
        Write-Host ""
        Write-Host "Server is running. Press Ctrl+C to stop." -ForegroundColor Yellow
        
        # Keep script running
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  MANUAL SETUP INSTRUCTIONS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "OPTION A: Visual Studio (Recommended)" -ForegroundColor Yellow
        Write-Host "1. Double-click: RDO-Production-Gilberto\solution\rdoapp.sln" -ForegroundColor White
        Write-Host "2. Wait for NuGet restore to complete" -ForegroundColor White
        Write-Host "3. Right-click 'rdoappProject' → Set as Startup Project" -ForegroundColor White
        Write-Host "4. Press F5 to run" -ForegroundColor White
        Write-Host ""
        
        Write-Host "OPTION B: IIS Express Command Line" -ForegroundColor Yellow
        Write-Host "1. Open PowerShell" -ForegroundColor White
        Write-Host "2. Run:" -ForegroundColor White
        Write-Host '   cd RDO-Production-Gilberto\rdoappProject' -ForegroundColor Gray
        Write-Host '   & "C:\Program Files\IIS Express\iisexpress.exe" /path:"$PWD" /port:50000' -ForegroundColor Gray
        Write-Host "3. Open browser: http://localhost:50000/" -ForegroundColor White
        Write-Host ""
        
        Write-Host "DATABASE CONNECTION:" -ForegroundColor Yellow
        Write-Host "Server: equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com" -ForegroundColor White
        Write-Host "Database: piscinas_rdoapp_homologa" -ForegroundColor White
        Write-Host "User: rdoadmin" -ForegroundColor White
        Write-Host "Password: rdoapp2018aws" -ForegroundColor White
        Write-Host ""
        
        Write-Host "For detailed instructions, see: RUN-LEGACY-PRODUCTION-CODE-GUIDE.md" -ForegroundColor Green
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid choice. Please run the script again and select 1, 2, or 3." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
