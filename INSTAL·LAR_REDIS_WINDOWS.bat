@echo off
echo ========================================
echo INSTAL·LAR REDIS A WINDOWS
echo ========================================
echo.
echo Aquesta opcio es MES FIABLE que Docker!
echo.
echo Opcions:
echo   1. Instal·lar amb Chocolatey (RECOMANAT)
echo   2. Descarregar manualment
echo   3. Cancel·lar
echo.
set /p opcio="Tria una opcio (1-3): "

if "%opcio%"=="1" goto chocolatey
if "%opcio%"=="2" goto manual
if "%opcio%"=="3" goto end

:chocolatey
echo.
echo ========================================
echo INSTAL·LANT AMB CHOCOLATEY
echo ========================================
echo.

echo [1/3] Verificant Chocolatey...
choco --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Chocolatey no esta instal·lat
    echo.
    echo Instal·lant Chocolatey...
    echo.
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if errorlevel 1 (
        echo ❌ Error instal·lant Chocolatey
        echo.
        echo Prova l'opcio 2 (manual)
        pause
        exit /b 1
    )
    
    echo ✅ Chocolatey instal·lat
) else (
    echo ✅ Chocolatey ja esta instal·lat
)
echo.

echo [2/3] Instal·lant Redis...
choco install redis-64 -y

if errorlevel 1 (
    echo ❌ Error instal·lant Redis
    pause
    exit /b 1
)

echo ✅ Redis instal·lat
echo.

echo [3/3] Iniciant Redis...
start "" redis-server

timeout /t 2 >nul

echo.
echo Verificant Redis...
redis-cli ping

if errorlevel 1 (
    echo ❌ Redis no respon
    echo.
    echo Intenta iniciar-lo manualment:
    echo   redis-server
) else (
    echo ✅ Redis funciona correctament!
)

echo.
echo ========================================
echo REDIS INSTAL·LAT!
echo ========================================
echo.
echo Per iniciar Redis en el futur:
echo   redis-server
echo.
echo Per verificar:
echo   redis-cli ping
echo.
echo Ara pots executar:
echo   EXECUTAR_WORKER_SENSE_DOCKER.bat
echo.
pause
goto end

:manual
echo.
echo ========================================
echo DESCARREGA MANUAL
echo ========================================
echo.
echo 1. Obre aquest enllaç al navegador:
echo    https://github.com/microsoftarchive/redis/releases
echo.
echo 2. Descarrega: Redis-x64-3.0.504.msi
echo.
echo 3. Instal·la Redis
echo.
echo 4. Obre un terminal i executa:
echo    redis-server
echo.
echo 5. Verifica que funciona:
echo    redis-cli ping
echo.
echo Vols obrir l'enllaç ara? (S/N)
set /p obrir="Resposta: "

if /i "%obrir%"=="S" (
    start https://github.com/microsoftarchive/redis/releases
)

echo.
pause
goto end

:end
exit /b 0
