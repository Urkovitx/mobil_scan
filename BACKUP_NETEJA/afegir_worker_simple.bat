@echo off
echo ========================================
echo AFEGIR WORKER A MOBIL_SCAN (Versio Simple)
echo ========================================
echo.

echo [1/2] Descarregant Worker des de Docker Hub...
docker pull urkovitx/mobil_scan-worker:latest
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: No s'ha pogut descarregar Worker
    echo Prova fer login manualment: docker login
    pause
    exit /b 1
)

echo.
echo [2/2] Executant Worker...
echo.

REM Aturar worker antic si existeix
docker stop worker 2>nul
docker rm worker 2>nul

REM Crear carpeta shared si no existeix
if not exist "shared" mkdir shared

REM Crear xarxa si no existeix
docker network create mobil_scan_network 2>nul

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
echo Per obrir el Frontend:
start http://localhost:8501
echo.
pause
