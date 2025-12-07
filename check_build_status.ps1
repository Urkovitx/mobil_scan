# PowerShell script to check Docker build status
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CHECKING DOCKER BUILD STATUS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking if Docker is building..." -ForegroundColor Yellow
Write-Host ""

# Check Docker processes
$dockerProcesses = Get-Process -Name "com.docker.*", "Docker*" -ErrorAction SilentlyContinue
if ($dockerProcesses) {
    Write-Host "✓ Docker Desktop is running" -ForegroundColor Green
    foreach ($proc in $dockerProcesses) {
        Write-Host "  - $($proc.Name): CPU $($proc.CPU.ToString('0.00'))%, Memory $([math]::Round($proc.WorkingSet64/1MB, 2)) MB" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ Docker Desktop is NOT running!" -ForegroundColor Red
}
Write-Host ""

Write-Host "2. Checking mobil_scan containers..." -ForegroundColor Yellow
Write-Host ""
docker ps -a --filter "name=mobil" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""

Write-Host "3. Checking mobil_scan images..." -ForegroundColor Yellow
Write-Host ""
docker images --filter "reference=mobil*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
Write-Host ""

Write-Host "4. Checking if build is in progress..." -ForegroundColor Yellow
Write-Host ""
$buildingContainers = docker ps -a --filter "status=created" --filter "name=mobil" --format "{{.Names}}"
if ($buildingContainers) {
    Write-Host "✓ Containers are being created:" -ForegroundColor Green
    Write-Host $buildingContainers
} else {
    Write-Host "✗ No containers being created" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "5. Checking Docker events (last 10)..." -ForegroundColor Yellow
Write-Host ""
docker events --since 5m --until 0s | Select-Object -Last 10
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSIS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Count containers
$containerCount = (docker ps -a --filter "name=mobil" --format "{{.Names}}" | Measure-Object).Count

if ($containerCount -eq 0) {
    Write-Host "STATUS: Build has NOT started or failed immediately" -ForegroundColor Red
    Write-Host ""
    Write-Host "RECOMMENDATION:" -ForegroundColor Yellow
    Write-Host "1. Press Ctrl+C to stop current command" -ForegroundColor White
    Write-Host "2. Run: docker-compose build --progress=plain" -ForegroundColor White
    Write-Host "   (This will show detailed build output)" -ForegroundColor Gray
} elseif ($containerCount -lt 5) {
    Write-Host "STATUS: Build is IN PROGRESS (partial)" -ForegroundColor Yellow
    Write-Host "Containers created: $containerCount / 5" -ForegroundColor White
    Write-Host ""
    Write-Host "RECOMMENDATION: Wait a few more minutes" -ForegroundColor Yellow
} else {
    Write-Host "STATUS: All containers created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEP: Check if they're running" -ForegroundColor Yellow
    Write-Host "Run: docker-compose ps" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
