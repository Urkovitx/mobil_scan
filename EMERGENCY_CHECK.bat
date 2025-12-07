@echo off
echo ========================================
echo EMERGENCY STATUS CHECK
echo ========================================
echo.
echo Checking Docker status...
echo.

REM Check if Docker is running
docker info > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Desktop is NOT running!
    echo Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [OK] Docker Desktop is running
echo.

echo ========================================
echo MOBIL_SCAN CONTAINERS
echo ========================================
docker ps -a --filter "name=mobil" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul
if %errorlevel% neq 0 (
    echo No mobil_scan containers found yet.
    echo This means the build hasn't created containers yet.
) else (
    echo.
)

echo.
echo ========================================
echo MOBIL_SCAN IMAGES
echo ========================================
docker images --filter "reference=mobil*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>nul
if %errorlevel% neq 0 (
    echo No mobil_scan images found yet.
    echo This means the build is still in progress.
) else (
    echo.
)

echo.
echo ========================================
echo ALL RUNNING CONTAINERS
echo ========================================
docker ps --format "table {{.Names}}\t{{.Status}}"

echo.
echo ========================================
echo DOCKER STATS (CPU/Memory usage)
echo ========================================
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo.
echo ========================================
echo DIAGNOSIS
echo ========================================
echo.

REM Count mobil containers
for /f %%i in ('docker ps -a --filter "name=mobil" --format "{{.Names}}" 2^>nul ^| find /c /v ""') do set COUNT=%%i

if "%COUNT%"=="0" (
    echo [STATUS] NO containers created yet
    echo.
    echo This means ONE of these:
    echo 1. Build is still downloading base images
    echo 2. Build failed immediately
    echo 3. docker-compose up was never executed
    echo.
    echo RECOMMENDATION:
    echo - If you just started: WAIT 5 more minutes
    echo - If it's been 20+ minutes: Something is wrong
    echo.
) else (
    echo [STATUS] Found %COUNT% mobil_scan containers
    echo.
    if %COUNT% LSS 5 (
        echo Build is IN PROGRESS ^(partial^)
        echo Expected: 5 containers total
        echo Current: %COUNT% containers
        echo.
        echo RECOMMENDATION: Wait a few more minutes
    ) else (
        echo All 5 containers created!
        echo.
        echo RECOMMENDATION: Check if they're running
        echo Run: docker-compose ps
    )
)

echo.
echo ========================================
echo NEXT STEPS
echo ========================================
echo.
echo To see live build progress:
echo   docker-compose logs --tail=50
echo.
echo To check container status:
echo   docker-compose ps
echo.
echo To restart build from scratch:
echo   docker-compose down
echo   docker-compose up --build
echo.
echo ========================================
pause
