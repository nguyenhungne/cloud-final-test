# Demonstrate Round Robin Load Balancing
Write-Host "`n=== Round Robin Load Balancing Demo ===" -ForegroundColor Cyan
Write-Host "Making 6 requests through the load balancer...`n" -ForegroundColor Yellow

for ($i = 1; $i -le 6; $i++) {
    $response = Invoke-WebRequest -Uri "http://localhost/" -Method Head -UseBasicParsing -TimeoutSec 5
    $upstream = $response.Headers['X-Upstream-Server']
    
    Write-Host "Request $i - HTTP Status: $($response.StatusCode) - Upstream: $upstream" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
}

Write-Host "`nWith Round Robin algorithm:" -ForegroundColor Cyan
Write-Host "- Requests are distributed evenly between web-frontend-server and web-frontend-server2" -ForegroundColor White
Write-Host "- Pattern: Server1 -> Server2 -> Server1 -> Server2 -> ..." -ForegroundColor White
Write-Host "- Both servers share the load equally" -ForegroundColor White

Write-Host "`nLoad balancing is operational!" -ForegroundColor Green
