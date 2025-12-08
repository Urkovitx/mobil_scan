@echo off
echo ========================================
echo COMPROVANT ESTAT DE DOCKER
echo ========================================
echo.

echo Comprovant si Docker Desktop està executant-se...
docker info >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ DOCKER NO ESTÀ FUNCIONANT!
    echo.
    echo Opcions:
    echo 1. Obre Docker Desktop manualment
    echo 2. Espera 30-60 segons que s'iniciï
    echo 3. Torna a executar aquest script per verificar
    echo.
    echo O executa: REINICIAR_DOCKER_I_BUILD.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Docker està funcionant correctament!
echo.
echo Informació de Docker:
docker info | findstr "Server Version"
docker info | findstr "Total Memory"
docker info | findstr "CPUs"
echo.
echo ========================================
echo POTS EXECUTAR EL BUILD ARA!
echo ========================================
echo.
echo Executa: BUILD_I_PUSH_LOCAL_FIXED.bat
echo.
pause
