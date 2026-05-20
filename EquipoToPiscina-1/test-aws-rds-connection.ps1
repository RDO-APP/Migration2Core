# Test AWS RDS Connection
Write-Host "Testing AWS RDS MySQL connection..." -ForegroundColor Yellow

$server = "equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com"
$port = 3306

Write-Host "Testing network connectivity to $server`:$port" -ForegroundColor Cyan

try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.ConnectAsync($server, $port).Wait(5000)
    
    if ($tcpClient.Connected) {
        Write-Host "✅ Network connection to AWS RDS: SUCCESS" -ForegroundColor Green
        $tcpClient.Close()
    } else {
        Write-Host "❌ Network connection to AWS RDS: FAILED (Timeout)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Network connection to AWS RDS: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 POSSIBLE ISSUES:" -ForegroundColor Yellow
Write-Host "1. AWS RDS instance is stopped (to save costs)" -ForegroundColor White
Write-Host "2. Security group blocking connections" -ForegroundColor White
Write-Host "3. Network/firewall restrictions" -ForegroundColor White
Write-Host "4. Database server is down" -ForegroundColor White

Write-Host "`n🔧 SOLUTIONS:" -ForegroundColor Yellow
Write-Host "1. Check AWS Console to start the RDS instance" -ForegroundColor White
Write-Host "2. Verify security group allows port 3306" -ForegroundColor White
Write-Host "3. Use a local MySQL database for testing" -ForegroundColor White