@echo off
REM ============================================================================
REM Rebuild Worker Container - NO CACHE (amb retry logic)
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║     REBUILD WORKER - NO CACHE (amb retry)                          ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar Docker
echo [1/6] Verificant Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker no està en execució
    pause
    exit /b 1
)
echo ✅ Docker està actiu
echo.

REM Augmentar recursos de Docker (opcional)
echo [2/6] Configurant recursos...
echo ℹ️  Assegura't que Docker Desktop té:
echo    - Memòria: 4GB+ assignats
echo    - CPU: 2+ cores
echo    - Disc: 20GB+ lliures
echo.
pause

REM Neteja prèvia
echo [3/6] Neteja prèvia...
docker-compose stop worker 2>nul
docker-compose rm -f worker 2>nul
docker rmi mobil_scan-worker 2>nul
docker builder prune -f
echo ✅ Neteja completada
echo.

REM Primer intent de build
echo [4/6] Intent 1/3 de build...
echo ⚠️  Això pot trigar 10-15 minuts
echo.

docker-compose build --no-cache --pull worker

if errorlevel 1 (
    echo.
    echo ⚠️  Primer intent fallit. Esperant 10 segons...
    timeout /t 10 /nobreak >nul
    
    echo.
    echo [5/6] Intent 2/3 de build...
    docker-compose build --no-cache worker
    
    if errorlevel 1 (
        echo.
        echo ⚠️  Segon intent fallit. Esperant 10 segons...
        timeout /t 10 /nobreak >nul
        
        echo.
        echo [6/6] Intent 3/3 de build (últim)...
        docker-compose build worker
        
        if errorlevel 1 (
            echo.
            echo ❌ Build fallit després de 3 intents
            echo.
            echo Possibles solucions:
            echo   1. Verifica connexió a Internet
            echo   2. Augmenta memòria de Docker Desktop
            echo   3. Neteja Docker: docker system prune -a
            echo   4. Reinicia Docker Desktop
            echo   5. Prova build manual: cd worker/cpp_scanner ^&^& mkdir build ^&^& cd build ^&^& cmake .. ^&^& cmake --build .
            echo.
            pause
            exit /b 1
        )
    )
)

echo.
echo ✅ Build completat correctament
echo.

REM Iniciar worker
echo Iniciant worker...
docker-compose up -d worker

if errorlevel 1 (
    echo ❌ Error iniciant worker
    pause
    exit /b 1
)

echo ✅ Worker iniciat
echo.

REM Verificacions
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    VERIFICACIONS                                   ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

timeout /t 5 /nobreak >nul

echo 📦 Verificant zxing-cpp Python...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ Version: {zxingcpp.__version__}')" 2>nul

echo.
echo 📦 Verificant executable C++...
docker-compose exec -T worker which barcode_test 2>nul
if errorlevel 1 (
    echo ⚠️  Executable no trobat
) else (
    echo ✅ Executable disponible
)

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Worker reconstruït correctament
echo.
echo Pròxims passos:
echo   - Executa TEST_CPP_SCANNER.bat per provar el scanner
echo.

pause
