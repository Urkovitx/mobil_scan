@echo off
REM ============================================================================
REM Rebuild Worker - Versió Minimal (només runtime, sense build tools)
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║     REBUILD WORKER - VERSIÓ MINIMAL (només runtime)               ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ℹ️  Aquesta versió instal·la només runtime dependencies
echo    i utilitza wheels pre-compilats de zxing-cpp
echo.
echo    Build més ràpid i sense errors de compilació.
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
docker system prune -f >nul 2>&1
echo ✅ Imatge eliminada
echo.

REM Build amb Dockerfile minimal
echo [4/5] Reconstruint worker (versió minimal)...
echo    ⏱️  Temps estimat: 2-3 minuts
echo    📦 Utilitzant wheels pre-compilats
echo.

docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

if errorlevel 1 (
    echo.
    echo ❌ Error durant el build
    echo.
    echo Si el problema persisteix:
    echo   1. Reinicia Docker Desktop completament
    echo   2. Augmenta memòria a 6GB (Settings → Resources)
    echo   3. Verifica espai en disc (mínim 20GB lliures)
    echo   4. Prova: docker system prune -a --volumes
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

REM Esperar
echo Esperant que el worker estigui llest...
timeout /t 10 /nobreak >nul

REM Verificacions
echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    VERIFICACIONS                                   ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

echo 📦 Verificant zxing-cpp...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>nul

if errorlevel 1 (
    echo ⚠️  Esperant que el worker inicialitzi...
    timeout /t 5 /nobreak >nul
    docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>nul
)

echo.
echo 🧪 Test funcional...
docker-compose exec -T worker python -c "import zxingcpp; import numpy as np; img = np.zeros((100, 100), dtype=np.uint8); results = zxingcpp.read_barcodes(img); print('✅ zxing-cpp funciona correctament')" 2>nul

echo.
echo 📊 Estat del worker...
docker-compose ps worker

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Worker reconstruït correctament amb zxing-cpp v2.2.0+
echo.
echo 🌐 Prova l'aplicació:
echo    http://localhost:8501
echo.

pause
