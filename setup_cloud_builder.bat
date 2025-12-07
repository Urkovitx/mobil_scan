@echo off
echo ========================================
echo CONFIGURACIÓ DOCKER CLOUD BUILDER
echo ========================================

echo.
echo [1/3] Login a Docker Hub...
echo (Introdueix el teu username i password)
docker login
if %errorlevel% neq 0 (
    echo ERROR: Login failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Creant builder cloud...
docker buildx create --driver cloud urkovitx/urkovitx-docker-cloud --name cloud-builder
if %errorlevel% neq 0 (
    echo WARNING: Potser el builder ja existeix. Provant activar-lo...
)

echo.
echo [3/3] Activant builder cloud...
docker buildx use cloud-builder
if %errorlevel% neq 0 (
    echo ERROR: No s'ha pogut activar el builder cloud!
    echo.
    echo Prova manualment:
    echo   docker buildx create --driver cloud --name cloud-builder
    echo   docker buildx use cloud-builder
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ CONFIGURACIÓ COMPLETADA!
echo ========================================
echo.
echo Verificant builders disponibles:
docker buildx ls

echo.
echo Ara pots fer build al núvol amb:
echo   .\build_cloud.bat
echo.
pause
