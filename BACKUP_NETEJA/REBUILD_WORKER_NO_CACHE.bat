@echo off
REM ============================================================================
REM Rebuild Worker Container - NO CACHE
REM ============================================================================
REM Aquest script reconstrueix el contenidor worker des de zero
REM sense utilitzar cap capa de caché de Docker.
REM Això assegura que:
REM   - Es descarrega l'última versió de zxing-cpp (v2.2.1)
REM   - Es recompila tot el codi C++
REM   - Es reinstal·len totes les dependències Python
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║     REBUILD WORKER - NO CACHE (zxing-cpp v2.2.1)                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar que Docker està en execució
echo [1/5] Verificant Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker no està en execució
    echo    Inicia Docker Desktop i torna a intentar-ho
    pause
    exit /b 1
)
echo ✅ Docker està actiu
echo.

REM Aturar el contenidor worker si està en execució
echo [2/5] Aturant contenidor worker existent...
docker-compose stop worker 2>nul
docker-compose rm -f worker 2>nul
echo ✅ Contenidor worker aturat
echo.

REM Eliminar imatge antiga del worker
echo [3/5] Eliminant imatge antiga del worker...
docker rmi mobil_scan-worker 2>nul
docker rmi mobil_scan_worker 2>nul
echo ✅ Imatge antiga eliminada
echo.

REM Rebuild amb --no-cache i --pull
echo [4/5] Reconstruint worker des de zero...
echo    ⚠️  Això pot trigar diversos minuts
echo    📦 Descarregant zxing-cpp v2.2.1...
echo    🔨 Compilant component C++...
echo    🐍 Instal·lant dependències Python...
echo.

docker-compose build --no-cache --pull worker

if errorlevel 1 (
    echo.
    echo ❌ Error durant la reconstrucció del worker
    echo.
    echo Possibles causes:
    echo   - Problemes de connexió a Internet
    echo   - Error en la compilació de C++
    echo   - Dependències Python no disponibles
    echo.
    echo Revisa els logs anteriors per més detalls
    pause
    exit /b 1
)

echo.
echo ✅ Worker reconstruït correctament
echo.

REM Iniciar el worker
echo [5/5] Iniciant worker...
docker-compose up -d worker

if errorlevel 1 (
    echo ❌ Error iniciant el worker
    pause
    exit /b 1
)

echo ✅ Worker iniciat correctament
echo.

REM Mostrar informació del contenidor
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    INFORMACIÓ DEL WORKER                           ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

docker-compose ps worker

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    VERIFICACIÓ ZXING-CPP                           ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar versió de zxing-cpp Python
echo 📦 Verificant zxing-cpp Python bindings...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>nul

REM Verificar executable C++
echo 📦 Verificant executable C++ barcode_test...
docker-compose exec -T worker test-cpp-scanner

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Worker reconstruït i verificat correctament
echo.
echo Pròxims passos:
echo   - Executa TEST_CPP_SCANNER.bat per provar el scanner C++
echo   - Executa VERIFICAR_APLICACIO.bat per provar tot el sistema
echo.

pause
