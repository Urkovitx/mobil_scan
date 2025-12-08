@echo off
echo ========================================
echo DOCKER CLOUD BUILD - mobil_scan
echo ========================================

echo.
echo [1/5] Verificant login a Docker Hub...
docker login
if %errorlevel% neq 0 (
    echo ERROR: Login failed! Verifica les teves credencials.
    pause
    exit /b 1
)

echo.
echo [2/5] Activant builder cloud...
docker buildx use cloud-builder
if %errorlevel% neq 0 (
    echo WARNING: Builder cloud no trobat. Creant-lo...
    docker buildx create --driver cloud urkovitx/urkovitx-docker-cloud --name cloud-builder
    docker buildx use cloud-builder
)

echo.
echo [3/5] Building BACKEND al núvol...
echo (Això pot trigar 3-5 minuts)
docker buildx build --no-cache --platform linux/amd64 -t urkovitx/mobil_scan-backend:latest -f backend/Dockerfile --push .
if %errorlevel% neq 0 (
    echo ERROR: Backend build failed!
    pause
    exit /b 1
)
echo ✅ Backend completat!

echo.
echo [4/5] Building FRONTEND al núvol...
echo (Això pot trigar 3-5 minuts)
docker buildx build --no-cache --platform linux/amd64 -t urkovitx/mobil_scan-frontend:latest -f frontend/Dockerfile --push .
if %errorlevel% neq 0 (
    echo ERROR: Frontend build failed!
    pause
    exit /b 1
)
echo ✅ Frontend completat!

echo.
echo [5/5] Building WORKER al núvol...
echo (Això pot trigar 5-8 minuts - PaddlePaddle)
docker buildx build --no-cache --platform linux/amd64 -t urkovitx/mobil_scan-worker:latest -f worker/Dockerfile --push .
if %errorlevel% neq 0 (
    echo ERROR: Worker build failed!
    pause
    exit /b 1
)
echo ✅ Worker completat!

echo.
echo ========================================
echo ✅ BUILD COMPLETAT AL NÚVOL!
echo ========================================
echo.
echo Les imatges estan disponibles a Docker Hub:
echo   - urkovitx/mobil_scan-backend:latest
echo   - urkovitx/mobil_scan-frontend:latest
echo   - urkovitx/mobil_scan-worker:latest
echo.
echo Per executar localment:
echo   docker-compose -f docker-compose.cloud.yml up
echo.
echo Per veure les imatges a Docker Hub:
echo   https://hub.docker.com/u/urkovitx
echo.
pause
