@echo off
echo ========================================
echo EXECUTAR MOBIL_SCAN - Solucio Simple
echo ========================================
echo.

echo [1/4] Login a Docker Hub...
echo.
echo Introdueix les teves credencials de Docker Hub:
docker login
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Login fallit!
    echo Verifica username i password.
    pause
    exit /b 1
)

echo.
echo [2/4] Descarregant imatges des de Docker Hub...
echo.
echo Descarregant Backend...
docker pull urkovitx/mobil_scan-backend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut descarregar Backend
    pause
    exit /b 1
)

echo.
echo Descarregant Frontend...
docker pull urkovitx/mobil_scan-frontend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut descarregar Frontend
    pause
    exit /b 1
)

echo.
echo Descarregant Worker...
docker pull urkovitx/mobil_scan-worker:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut descarregar Worker
    pause
    exit /b 1
)

echo.
echo [3/4] Netejant contenidors antics...
docker stop backend frontend worker 2>nul
docker rm backend frontend worker 2>nul

echo.
echo [4/4] Creant xarxa i executant contenidors...
echo.

REM Crear xarxa si no existeix
docker network create mobil_scan_network 2>nul

REM Crear carpeta shared si no existeix
if not exist "shared" mkdir shared

echo Executant Backend...
docker run -d --name backend --network mobil_scan_network -p 8000:8000 urkovitx/mobil_scan-backend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut executar Backend
    pause
    exit /b 1
)

echo Executant Worker...
docker run -d --name worker --network mobil_scan_network -v "%CD%\shared:/app/shared" urkovitx/mobil_scan-worker:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut executar Worker
    pause
    exit /b 1
)

echo Executant Frontend...
docker run -d --name frontend --network mobil_scan_network -p 8501:8501 -v "%CD%\shared:/app/shared" urkovitx/mobil_scan-frontend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No s'ha pogut executar Frontend
    pause
    exit /b 1
)

echo.
echo ========================================
echo MOBIL_SCAN EXECUTANT-SE!
echo ========================================
echo.
echo Frontend: http://localhost:8501
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
echo Esperant que els serveis estiguin llestos...
timeout /t 5 /nobreak >nul

echo.
echo Verificant estat dels contenidors...
docker ps --filter "name=backend" --filter "name=frontend" --filter "name=worker" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo ========================================
echo Obrint navegador...
echo ========================================
start http://localhost:8501

echo.
echo Per veure els logs:
echo   docker logs -f frontend
echo   docker logs -f backend
echo   docker logs -f worker
echo.
echo Per aturar:
echo   docker stop backend frontend worker
echo.
pause
