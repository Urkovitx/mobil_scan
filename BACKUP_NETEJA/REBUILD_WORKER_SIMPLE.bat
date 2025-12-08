@echo off
REM ============================================================================
REM Rebuild Worker - Versió Simple (només Python bindings)
REM ============================================================================
REM Aquest script utilitza Dockerfile.simple que evita la compilació C++
REM i utilitza només els Python bindings de zxing-cpp v2.2.0+
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║     REBUILD WORKER - VERSIÓ SIMPLE (Python bindings)              ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ℹ️  Aquesta versió evita la compilació C++ i utilitza només
echo    els Python bindings de zxing-cpp (versió 2.2.0+)
echo.
echo    Això és suficient per al funcionament complet del worker.
echo.

REM Verificar Docker
echo [1/5] Verificant Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker no està en execució
    pause
    exit /b 1
)
echo ✅ Docker està actiu
echo.

REM Aturar worker
echo [2/5] Aturant worker existent...
docker-compose stop worker 2>nul
docker-compose rm -f worker 2>nul
echo ✅ Worker aturat
echo.

REM Eliminar imatge antiga
echo [3/5] Eliminant imatge antiga...
docker rmi mobil_scan-worker 2>nul
echo ✅ Imatge eliminada
echo.

REM Build amb Dockerfile simple
echo [4/5] Reconstruint worker (versió simple)...
echo    ⏱️  Temps estimat: 3-5 minuts
echo    📦 Instal·lant zxing-cpp Python bindings v2.2.0+
echo.

docker build --no-cache --pull -f worker/Dockerfile.simple -t mobil_scan-worker .

if errorlevel 1 (
    echo.
    echo ❌ Error durant el build
    echo.
    echo Prova:
    echo   1. Verifica connexió a Internet
    echo   2. Reinicia Docker Desktop
    echo   3. Executa: docker system prune -f
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Build completat correctament
echo.

REM Iniciar worker
echo [5/5] Iniciant worker...
docker-compose up -d worker

if errorlevel 1 (
    echo ❌ Error iniciant worker
    pause
    exit /b 1
)

echo ✅ Worker iniciat
echo.

REM Esperar que el worker estigui llest
echo Esperant que el worker estigui llest...
timeout /t 10 /nobreak >nul

REM Verificacions
echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    VERIFICACIONS                                   ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

echo 📦 Verificant zxing-cpp Python bindings...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>nul

if errorlevel 1 (
    echo ⚠️  No s'ha pogut verificar zxing-cpp
) else (
    echo.
    echo 🧪 Test ràpid de zxing-cpp...
    docker-compose exec -T worker python -c "import zxingcpp; import numpy as np; img = np.zeros((100, 100), dtype=np.uint8); results = zxingcpp.read_barcodes(img); print('✅ zxing-cpp funciona correctament')" 2>nul
)

echo.
echo 📊 Estat del worker...
docker-compose ps worker

echo.
echo 📋 Logs del worker (últimes 10 línies)...
docker-compose logs --tail=10 worker

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Worker reconstruït correctament amb zxing-cpp v2.2.0+ (Python)
echo.
echo ℹ️  Aquesta versió utilitza els Python bindings de zxing-cpp,
echo    que són suficients per a la detecció de barcodes.
echo.
echo 🌐 Pròxims passos:
echo    - Obre http://localhost:8501 per provar l'aplicació
echo    - Puja un vídeo amb barcodes
echo    - Verifica que les deteccions funcionen
echo.

pause
