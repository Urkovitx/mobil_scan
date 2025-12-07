@echo off
echo ========================================
echo AFEGIR WORKER A MOBIL_SCAN
echo ========================================
echo.
echo Ja tens Backend i Frontend executant-se.
echo Ara afegirem el Worker.
echo.

echo [1/3] Login a Docker Hub...
echo.
docker login
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Login fallit!
    pause
    exit /b 1
)

echo.
echo [2/3] Descarregant Worker...
docker pull urkovitx/mobil_scan-worker:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut descarregar Worker
    pause
    exit /b 1
)

echo.
echo [3/3] Executant Worker...
echo.

REM Aturar worker antic si existeix
docker stop worker 2>nul
docker rm worker 2>nul

REM Crear carpeta shared si no existeix
if not exist "shared" mkdir shared

REM Executar Worker
docker run -d --name worker --network mobil_scan_network -v "%CD%\shared:/app/shared" urkovitx/mobil_scan-worker:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut executar Worker
    pause
    exit /b 1
)

echo.
echo ========================================
echo WORKER AFEGIT CORRECTAMENT!
echo ========================================
echo.
echo Verificant estat dels contenidors...
docker ps --filter "name=backend" --filter "name=frontend" --filter "name=worker" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo ========================================
echo MOBIL_SCAN COMPLET!
echo ========================================
echo.
echo Frontend: http://localhost:8501
echo Backend:  http://localhost:8000
echo Worker:   Executant-se en background
echo.
echo Per veure logs del Worker:
echo   docker logs -f worker
echo.
pause
