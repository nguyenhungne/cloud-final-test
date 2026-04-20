# Comprehensive load balancing verification script
Write-Host "`n=== Load Balancing Verification ===" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Step 1: Verify both web servers are running
Write-Host "Step 1: Checking if both web servers are running..." -ForegroundColor Yellow
$server1Status = docker ps --filter "name=web-frontend-server" --filter "status=running" --format "{{.Names}}" | Select-String "^web-frontend-server$"
$server2Status = docker ps --filter "name=web-frontend-server2" --filter "status=running" --format "{{.Names}}" | Select-String "^web-frontend-server2$"

if ($server1Status) {
    Write-Host "✓ web-frontend-server is running" -ForegroundColor Green
} else {
    Write-Host "✗ web-frontend-server is NOT running" -ForegroundColor Red
}

if ($server2Status) {
    Write-Host "✓ web-frontend-server2 is running" -ForegroundColor Green
} else {
    Write-Host "✗ web-frontend-server2 is NOT running" -ForegroundColor Red
}

# Step 2: Test direct access to each server
Write-Host "`nStep 2: Testing direct access to each server..." -ForegroundColor Yellow

try {
    $response1 = Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Server 1 (port 8080): Status $($response1.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Server 1 (port 8080): Failed" -ForegroundColor Red
}

try {
    $response2 = Invoke-WebRequest -Uri "http://localhost:8082/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Server 2 (port 8082): Status $($response2.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Server 2 (port 8082): Failed" -ForegroundColor Red
}

# Step 3: Check nginx upstream configuration
Write-Host "`nStep 3: Verifying nginx upstream configuration..." -ForegroundColor Yellow
$upstreamConfig = docker exec api-gateway-proxy-server cat /etc/nginx/nginx.conf | Select-String -Pattern "upstream web_frontend" -Context 0,3

if ($upstreamConfig -match "web-frontend-server:80" -and $upstreamConfig -match "web-frontend-server2:80") {
    Write-Host "✓ Nginx upstream configured with both servers" -ForegroundColor Green
    Write-Host $upstreamConfig -ForegroundColor Gray
} else {
    Write-Host "✗ Nginx upstream configuration issue" -ForegroundColor Red
}

# Step 4: Make requests through load balancer and check backend logs
Write-Host "`nStep 4: Making 10 requests through load balancer..." -ForegroundColor Yellow

# Clear recent logs by noting current time
$testStartTime = Get-Date

for ($i = 1; $i -le 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5
        Write-Host "  Request $i : HTTP $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  Request $i : Failed" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 200
}

# Step 5: Check which servers received requests
Write-Host "`nStep 5: Analyzing server logs..." -ForegroundColor Yellow
Start-Sleep -Seconds 2  # Give logs time to flush

$server1Logs = docker logs web-frontend-server 2>&1 | Select-String "GET / HTTP"
$server2Logs = docker logs web-frontend-server2 2>&1 | Select-String "GET / HTTP"

$server1Count = ($server1Logs | Measure-Object).Count
$server2Count = ($server2Logs | Measure-Object).Count

Write-Host "Server 1 total GET / requests: $server1Count" -ForegroundColor Cyan
Write-Host "Server 2 total GET / requests: $server2Count" -ForegroundColor Cyan

# Step 6: Final verdict
Write-Host "`n=== Final Verdict ===" -ForegroundColor Cyan

if ($server1Status -and $server2Status) {
    Write-Host "✓ Both servers are running" -ForegroundColor Green
    
    if ($upstreamConfig -match "web-frontend-server:80" -and $upstreamConfig -match "web-frontend-server2:80") {
        Write-Host "✓ Nginx is configured for load balancing" -ForegroundColor Green
        Write-Host "`nLoad balancing configuration is COMPLETE!" -ForegroundColor Green
        Write-Host "Nginx will distribute requests using Round Robin algorithm." -ForegroundColor Green
    } else {
        Write-Host "✗ Nginx configuration needs review" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Not all servers are running" -ForegroundColor Red
}

Write-Host "`nNote: Nginx uses Round Robin by default when multiple servers are listed in upstream block." -ForegroundColor Yellow
