@echo off
echo ========================================
echo REBUILD FRONTEND - RAPID
echo ========================================
echo.

echo 1. Building frontend image...
docker build -t urkovitx/mobil-scan-frontend:latest -f frontend/Dockerfile .

if %errorlevel% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo.
echo 2. Pushing to Docker Hub...
docker push urkovitx/mobil-scan-frontend:latest

if %errorlevel% neq 0 (
    echo ❌ Push failed!
    pause
    exit /b 1
)

echo.
echo 3. Pulling latest image...
docker-compose -f docker-compose.hub.yml pull frontend

echo.
echo 4. Restarting frontend container...
docker-compose -f docker-compose.hub.yml up -d frontend

echo.
echo ========================================
echo ✅ FRONTEND REBUILT SUCCESSFULLY!
echo ========================================
echo.
echo Waiting 10 seconds for Streamlit to start...
timeout /t 10 /nobreak >nul

echo.
echo Testing frontend connection...
curl -I http://localhost:3000 2>nul

echo.
echo Frontend should be available at: http://localhost:3000
echo.
pause
