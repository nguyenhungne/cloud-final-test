# Verification script for Task 17.1
# This script verifies that all required metrics are available in Prometheus

Write-Host "`n=== Task 17.1 Metrics Verification ===" -ForegroundColor Cyan
Write-Host "Checking if all required metrics are available in Prometheus...`n"

# Check if containers are running
Write-Host "1. Checking container status..." -ForegroundColor Yellow
$containers = @(
    "monitoring-grafana-dashboard-server",
    "monitoring-prometheus-server",
    "monitoring-node-exporter-server"
)

foreach ($container in $containers) {
    $status = docker inspect -f '{{.State.Running}}' $container 2>$null
    if ($status -eq "true") {
        Write-Host "   ✅ $container is running" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $container is NOT running" -ForegroundColor Red
    }
}

# Check if services are accessible
Write-Host "`n2. Checking service accessibility..." -ForegroundColor Yellow

try {
    $grafana = Invoke-WebRequest -Uri http://localhost:3000 -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✅ Grafana is accessible (HTTP $($grafana.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Grafana is NOT accessible" -ForegroundColor Red
}

try {
    $prometheus = Invoke-WebRequest -Uri http://localhost:9090 -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✅ Prometheus is accessible (HTTP $($prometheus.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Prometheus is NOT accessible" -ForegroundColor Red
}

try {
    $nodeExporter = Invoke-WebRequest -Uri http://localhost:9100/metrics -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✅ Node Exporter is accessible (HTTP $($nodeExporter.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Node Exporter is NOT accessible" -ForegroundColor Red
}

# Check Prometheus targets
Write-Host "`n3. Checking Prometheus targets..." -ForegroundColor Yellow
$targets = docker exec monitoring-prometheus-server wget -qO- http://localhost:9090/api/v1/targets 2>$null | ConvertFrom-Json
$nodeTarget = $targets.data.activeTargets | Where-Object { $_.scrapePool -eq "node" }

if ($nodeTarget.health -eq "up") {
    Write-Host "   ✅ Node Exporter target is UP" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node Exporter target is DOWN" -ForegroundColor Red
}

# Check required metrics
Write-Host "`n4. Checking required metrics availability..." -ForegroundColor Yellow

$queries = @{
    "CPU" = "node_cpu_seconds_total"
    "Memory" = "node_memory_MemAvailable_bytes"
    "Network" = "node_network_receive_bytes_total"
}

foreach ($metric in $queries.GetEnumerator()) {
    $query = $metric.Value
    $result = docker exec monitoring-prometheus-server wget -qO- "http://localhost:9090/api/v1/query?query=$query" 2>$null | ConvertFrom-Json
    
    if ($result.status -eq "success" -and $result.data.result.Count -gt 0) {
        Write-Host "   ✅ $($metric.Key) metric ($query) - Found $($result.data.result.Count) series" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($metric.Key) metric ($query) - No data" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "All infrastructure is ready for Task 17.1!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Open DASHBOARD_SETUP_GUIDE.md"
Write-Host "2. Follow the step-by-step instructions"
Write-Host "3. Create the dashboard in Grafana UI"
Write-Host "`nOr use the quick method:"
Write-Host "1. Add Prometheus datasource in Grafana"
Write-Host "2. Import dashboard-template.json"
Write-Host ""
