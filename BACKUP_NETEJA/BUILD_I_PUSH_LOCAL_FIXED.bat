@echo off
echo ========================================
echo BUILD I PUSH LOCAL - Backend + Frontend
echo ========================================
echo.
echo Aquest script farà:
echo 1. Build de backend localment (des del directori arrel)
echo 2. Push de backend a Docker Hub
echo 3. Build de frontend localment (des del directori arrel)
echo 4. Push de frontend a Docker Hub
echo.
echo Temps estimat: 5-10 minuts
echo.
pause

echo.
echo ========================================
echo 1/4: BUILD BACKEND
echo ========================================
docker build -f backend/Dockerfile -t urkovitx/mobil-scan-backend:latest .
if errorlevel 1 (
    echo ERROR: Build de backend ha fallat!
    pause
    exit /b 1
)
echo ✅ Backend build completat!

echo.
echo ========================================
echo 2/4: PUSH BACKEND
echo ========================================
docker push urkovitx/mobil-scan-backend:latest
if errorlevel 1 (
    echo ERROR: Push de backend ha fallat!
    echo Assegura't que has fet: docker login
    pause
    exit /b 1
)
echo ✅ Backend push completat!

echo.
echo ========================================
echo 3/4: BUILD FRONTEND
echo ========================================
docker build -f frontend/Dockerfile -t urkovitx/mobil-scan-frontend:latest .
if errorlevel 1 (
    echo ERROR: Build de frontend ha fallat!
    pause
    exit /b 1
)
echo ✅ Frontend build completat!

echo.
echo ========================================
echo 4/4: PUSH FRONTEND
echo ========================================
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
echo O manualment:
echo   docker-compose -f docker-compose.hub.yml up -d
echo.
pause
