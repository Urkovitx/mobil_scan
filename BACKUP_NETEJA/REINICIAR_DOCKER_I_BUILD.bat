@echo off
echo ========================================
echo REINICIAR DOCKER I BUILD
echo ========================================
echo.
echo Aquest script farà:
echo 1. Tancar Docker Desktop completament
echo 2. Esperar 10 segons
echo 3. Iniciar Docker Desktop
echo 4. Esperar que estigui llest
echo 5. Executar el build
echo.
pause

echo.
echo ========================================
echo 1. TANCANT DOCKER DESKTOP...
echo ========================================
taskkill /F /IM "Docker Desktop.exe" 2>nul
timeout /t 5 /nobreak >nul
echo ✅ Docker Desktop tancat

echo.
echo ========================================
echo 2. ESPERANT 10 SEGONS...
echo ========================================
timeout /t 10 /nobreak
echo ✅ Espera completada

echo.
echo ========================================
echo 3. INICIANT DOCKER DESKTOP...
echo ========================================
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
echo ✅ Docker Desktop iniciat

echo.
echo ========================================
echo 4. ESPERANT QUE DOCKER ESTIGUI LLEST...
echo ========================================
echo Això pot trigar 30-60 segons...
echo.

:wait_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if errorlevel 1 (
    echo Esperant Docker...
    goto wait_docker
)

echo ✅ Docker està llest!

echo.
echo ========================================
echo 5. EXECUTANT BUILD...
echo ========================================
echo.
pause

REM Ara executa el build
docker build -f backend/Dockerfile -t urkovitx/mobil-scan-backend:latest .
if errorlevel 1 (
    echo ERROR: Build de backend ha fallat!
    pause
    exit /b 1
)
echo ✅ Backend build completat!

docker push urkovitx/mobil-scan-backend:latest
if errorlevel 1 (
    echo ERROR: Push de backend ha fallat!
    pause
    exit /b 1
)
echo ✅ Backend push completat!

docker build -f frontend/Dockerfile -t urkovitx/mobil-scan-frontend:latest .
if errorlevel 1 (
    echo ERROR: Build de frontend ha fallat!
    pause
    exit /b 1
)
echo ✅ Frontend build completat!

docker push urkovitx/mobil-scan-frontend:latest
if errorlevel 1 (
    echo ERROR: Push de frontend ha fallat!
    pause
    exit /b 1
)
echo ✅ Frontend push completat!

echo.
echo ========================================
echo ✅ TOT COMPLETAT!
echo ========================================
echo.
echo Imatges creades i pujades:
echo ✅ urkovitx/mobil-scan-backend:latest
echo ✅ urkovitx/mobil-scan-frontend:latest
echo.
echo Ara pots executar:
echo   run_from_dockerhub.bat
echo.
pause
