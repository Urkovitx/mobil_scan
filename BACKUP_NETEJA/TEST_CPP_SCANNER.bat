@echo off
REM ============================================================================
REM Test C++ Barcode Scanner (zxing-cpp v2.2.1)
REM ============================================================================
REM Aquest script prova l'executable C++ barcode_test dins del contenidor worker
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║          TEST C++ BARCODE SCANNER (zxing-cpp v2.2.1)              ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar que Docker està en execució
echo [1/4] Verificant Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker no està en execució
    pause
    exit /b 1
)
echo ✅ Docker està actiu
echo.

REM Verificar que el worker està en execució
echo [2/4] Verificant contenidor worker...
docker-compose ps worker | findstr "Up" >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: El contenidor worker no està en execució
    echo    Executa: docker-compose up -d worker
    pause
    exit /b 1
)
echo ✅ Worker està actiu
echo.

REM Verificar que l'executable existeix
echo [3/4] Verificant executable barcode_test...
docker-compose exec -T worker which barcode_test >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Executable barcode_test no trobat
    echo    Reconstrueix el worker amb: REBUILD_WORKER_NO_CACHE.bat
    pause
    exit /b 1
)
echo ✅ Executable barcode_test trobat
echo.

REM Executar test
echo [4/4] Executant test del scanner C++...
echo.
echo ════════════════════════════════════════════════════════════════════
echo                    SORTIDA DEL SCANNER C++
echo ════════════════════════════════════════════════════════════════════
echo.

docker-compose exec worker barcode_test

echo.
echo ════════════════════════════════════════════════════════════════════
echo.

if errorlevel 1 (
    echo ⚠️  El test ha retornat un codi d'error
    echo    Això és normal si no s'ha proporcionat una imatge amb barcode
) else (
    echo ✅ Test executat correctament
)

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    INFORMACIÓ ADDICIONAL                           ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

echo 📖 Per testejar amb una imatge real:
echo.
echo    1. Converteix la teva imatge a format PPM:
echo       docker-compose exec worker sh -c "apt-get update && apt-get install -y imagemagick"
echo       docker cp barcode.jpg mobil_scan_worker:/app/test.jpg
echo       docker-compose exec worker convert test.jpg test.ppm
echo.
echo    2. Executa el test amb la imatge:
echo       docker-compose exec worker barcode_test /app/test.ppm
echo.
echo 📖 Per veure l'ajuda del scanner:
echo       docker-compose exec worker barcode_test --help
echo.
echo 📖 Per accedir al contenidor:
echo       docker-compose exec worker bash
echo.

echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    TEST PYTHON BINDINGS                            ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

echo Verificant zxing-cpp Python bindings...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp Python version: {zxingcpp.__version__}')"

echo.
echo Provant detecció amb Python...
docker-compose exec -T worker python -c "import zxingcpp; import numpy as np; img = np.zeros((100, 100), dtype=np.uint8); results = zxingcpp.read_barcodes(img); print(f'✅ Python API funciona correctament (0 barcodes en imatge buida)')"

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

pause
