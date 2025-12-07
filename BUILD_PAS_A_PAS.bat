@echo off
echo ========================================
echo   BUILD PAS A PAS (NO PETA)
echo ========================================
echo.
echo Aquest script fa el build en 8 passos
echo Cada pas es pot cachear si falla
echo.
pause

echo.
echo [Pas 1/8] Dependencies del sistema...
docker build --target base -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step1 . 2>&1 | findstr /V "^$"
if errorlevel 1 (
    echo ERROR al pas 1
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 2/8] Instal·lant numpy...
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step2 . 2>&1 | findstr "Step\|numpy\|Successfully"
if errorlevel 1 (
    echo ERROR al pas 2
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 3/8] Instal·lant opencv...
timeout /t 2 /nobreak >nul
echo (Això pot trigar 1-2 minuts)
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step3 . 2>&1 | findstr "Step\|opencv\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 3
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 4/8] Instal·lant zxing-cpp...
timeout /t 2 /nobreak >nul
echo (Això pot trigar 2-3 minuts - compilant C++)
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step4 . 2>&1 | findstr "Step\|zxing\|Building\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 4
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 5/8] Instal·lant Pillow...
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step5 . 2>&1 | findstr "Step\|Pillow\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 5
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 6/8] Instal·lant database i redis...
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step6 . 2>&1 | findstr "Step\|sqlalchemy\|redis\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 6
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 7/8] Instal·lant logging...
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker:step7 . 2>&1 | findstr "Step\|loguru\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 7
    pause
    exit /b 1
)
echo OK!
echo.

echo [Pas 8/8] Instal·lant YOLO i Supervision (el mes pesat)...
timeout /t 2 /nobreak >nul
echo (Això pot trigar 3-5 minuts)
docker build -f worker/Dockerfile.ultra-minimal -t mobil_scan-worker . 2>&1 | findstr "Step\|ultralytics\|supervision\|Successfully\|ERROR"
if errorlevel 1 (
    echo ERROR al pas 8
    pause
    exit /b 1
)
echo OK!
echo.

echo ========================================
echo   BUILD COMPLETAT!
echo ========================================
echo.
echo Ara iniciant serveis...
docker-compose up -d
echo.

timeout /t 5 /nobreak >nul
docker-compose ps
echo.

echo Verificant zxing-cpp...
docker-compose exec -T worker python -c "import zxingcpp; print('zxing-cpp version:', zxingcpp.__version__)"
echo.

echo ========================================
echo   TOT LLEST!
echo ========================================
echo.
echo Aplicacio: http://localhost:8501
echo.

start http://localhost:8501

pause
