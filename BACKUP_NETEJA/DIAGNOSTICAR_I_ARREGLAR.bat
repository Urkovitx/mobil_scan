@echo off
echo ========================================
echo DIAGNOSTIC COMPLET - MOBIL_SCAN
echo ========================================
echo.

echo [DIAGNOSTIC 1] Verificant Docker...
docker --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker no esta instal·lat o no funciona
    pause
    exit /b 1
)
echo OK: Docker funciona
echo.

echo [DIAGNOSTIC 2] Contenidors actius...
docker ps
echo.

echo [DIAGNOSTIC 3] Tots els contenidors...
docker ps -a
echo.

echo [DIAGNOSTIC 4] Imatges disponibles...
docker images | findstr mobil_scan
echo.

echo [DIAGNOSTIC 5] Xarxes Docker...
docker network ls | findstr mobil_scan
echo.

echo ========================================
echo NETEJA COMPLETA I REINICI
echo ========================================
echo.
echo Vols fer una neteja completa i tornar a començar? (S/N)
set /p resposta=

if /i "%resposta%"=="S" (
    echo.
    echo Aturant tots els contenidors...
    docker stop backend frontend worker 2>nul
    
    echo Eliminant contenidors...
    docker rm backend frontend worker 2>nul
    
    echo Eliminant xarxa...
    docker network rm mobil_scan_network 2>nul
    
    echo.
    echo ========================================
    echo REINICIANT DES DE ZERO
    ========================================
    echo.
    
    echo Creant xarxa...
    docker network create mobil_scan_network
    
    echo.
    echo Tens les imatges descarregades? (S/N)
    set /p imatges=
    
    if /i "%imatges%"=="N" (
        echo.
        echo Descarregant imatges...
        docker pull urkovitx/mobil_scan-backend:latest
        docker pull urkovitx/mobil_scan-frontend:latest
        echo.
        echo Vols descarregar el Worker ara? (triga 10 min) (S/N)
        set /p worker=
        if /i "%worker%"=="S" (
            docker pull urkovitx/mobil_scan-worker:latest
        )
    )
    
    echo.
    echo Creant carpeta shared...
    if not exist "shared" mkdir shared
    
    echo.
    echo Executant Backend...
    docker run -d --name backend --network mobil_scan_network -p 8000:8000 urkovitx/mobil_scan-backend:latest
    
    echo Executant Frontend...
    docker run -d --name frontend --network mobil_scan_network -p 8501:8501 -v "%CD%\shared:/app/shared" urkovitx/mobil_scan-frontend:latest
    
    echo.
    echo Vols executar el Worker? (S/N)
    set /p execworker=
    if /i "%execworker%"=="S" (
        echo Executant Worker...
        docker run -d --name worker --network mobil_scan_network -v "%CD%\shared:/app/shared" urkovitx/mobil_scan-worker:latest
    )
    
    echo.
    echo ========================================
    echo VERIFICANT ESTAT
    echo ========================================
    timeout /t 3 /nobreak >nul
    docker ps
    
    echo.
    echo ========================================
    echo OBRINT NAVEGADOR
    echo ========================================
    start http://localhost:8501
    
    echo.
    echo Si no funciona, envia'm una captura de pantalla d'aquesta finestra.
)

echo.
pause
