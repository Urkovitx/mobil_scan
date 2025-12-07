@echo off
echo ========================================
echo   BUILD RAPID - DOCKER DESKTOP
echo ========================================
echo.
echo Docker Desktop detectat: OK
echo.

echo [1/3] Netejant contenidors (forcat)...
docker rm -f mobil_scan_worker mobil_scan_api mobil_scan_frontend mobil_scan_redis mobil_scan_db 2>nul
echo OK
echo.

echo [2/3] Build RAPID del worker (5-10 min)...
echo Utilitzant Dockerfile.minimal...
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .
if errorlevel 1 (
    echo.
    echo ERROR en el build
    echo.
    echo Prova aixo:
    echo 1. Tanca Docker Desktop
    echo 2. Torna a obrir Docker Desktop
    echo 3. Espera 1 minut
    echo 4. Torna a executar aquest script
    echo.
    pause
    exit /b 1
)
echo.

echo [3/3] Iniciant serveis...
docker-compose up -d
echo.

echo ========================================
echo Verificant...
timeout /t 5 /nobreak >nul
docker-compose ps
echo.

echo Provant zxing-cpp...
docker-compose exec -T worker python -c "import zxingcpp; print('zxing-cpp version:', zxingcpp.__version__)" 2>nul
if errorlevel 1 (
    echo Esperant que el worker s'iniciï...
    timeout /t 10 /nobreak >nul
    docker-compose exec -T worker python -c "import zxingcpp; print('zxing-cpp version:', zxingcpp.__version__)"
)
echo.

echo ========================================
echo   COMPLETAT!
echo ========================================
echo.
echo Aplicacio: http://localhost:8501
echo API: http://localhost:8000
echo.
echo Logs: docker-compose logs -f worker
echo Aturar: docker-compose down
echo.

start http://localhost:8501

pause
