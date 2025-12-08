@echo off
echo ========================================
echo INICIAR DOCKER I EXECUTAR MOBIL SCAN
echo ========================================
echo.

REM Verificar si Docker Desktop esta executant-se
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker ja esta actiu!
    goto :run_app
)

echo [INFO] Docker no esta actiu. Iniciant Docker Desktop...
echo.

REM Iniciar Docker Desktop
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo [WAIT] Esperant que Docker Desktop s'iniciï...
echo        Això pot trigar 30-60 segons...
echo.

REM Esperar fins que Docker estigui llest (max 2 minuts)
set /a count=0
:wait_loop
timeout /t 5 /nobreak >nul
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo [OK] Docker esta actiu!
    goto :run_app
)

set /a count+=1
if %count% lss 24 (
    echo [WAIT] Encara esperant... (%count%/24)
    goto :wait_loop
)

echo.
echo [ERROR] Docker no s'ha iniciat despres de 2 minuts
echo.
echo Solucions:
echo 1. Obre Docker Desktop manualment
echo 2. Espera que aparegui la icona a la barra de tasques
echo 3. Torna a executar aquest script
echo.
pause
exit /b 1

:run_app
echo.
echo ========================================
echo EXECUTANT MOBIL SCAN DESDE DOCKER HUB
echo ========================================
echo.

REM Executar l'aplicacio
call RUN_FROM_HUB_MILLORES.bat

exit /b 0
