@echo off
echo ========================================
echo REBUILD BACKEND AMB PSYCOPG2
echo ========================================
echo.
echo Aquest script farà:
echo 1. Aturar els contenidors actuals
echo 2. Rebuild del backend amb psycopg2-binary afegit
echo 3. Push al Docker Hub
echo 4. Reiniciar l'aplicació
echo.
pause

echo.
echo ========================================
echo 1. ATURANT CONTENIDORS...
echo ========================================
docker-compose -f docker-compose.hub.yml down
echo ✅ Contenidors aturats

echo.
echo ========================================
echo 2. REBUILD BACKEND (amb psycopg2)
echo ========================================
docker build -f backend/Dockerfile -t urkovitx/mobil-scan-backend:latest .
if errorlevel 1 (
    echo ❌ ERROR: Build de backend ha fallat!
    pause
    exit /b 1
)
echo ✅ Backend build completat!

echo.
echo ========================================
echo 3. PUSH BACKEND
echo ========================================
docker push urkovitx/mobil-scan-backend:latest
if errorlevel 1 (
    echo ❌ ERROR: Push de backend ha fallat!
    pause
    exit /b 1
)
echo ✅ Backend push completat!

echo.
echo ========================================
echo 4. REINICIANT APLICACIÓ
echo ========================================
docker-compose -f docker-compose.hub.yml pull backend
docker-compose -f docker-compose.hub.yml up -d

echo.
echo Esperant 10 segons que els serveis s'iniciïn...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo ✅ COMPLETAT!
echo ========================================
echo.
echo Comprovant estat dels contenidors:
docker-compose -f docker-compose.hub.yml ps
echo.
echo L'aplicació hauria d'estar a:
echo   http://localhost:3000
echo.
echo Per veure els logs del backend:
echo   docker-compose -f docker-compose.hub.yml logs -f backend
echo.
pause
