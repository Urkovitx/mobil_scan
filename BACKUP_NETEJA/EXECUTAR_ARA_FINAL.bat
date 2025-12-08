@echo off
echo ========================================
echo BUILD I DEPLOY FINAL
echo ========================================
echo.
echo Aquest script far├á:
echo 1. Verificar que Docker funciona
echo 2. Build de backend (amb requirements optimitzats)
echo 3. Push de backend a Docker Hub (sobreescriur├á l'antic)
echo 4. Build de frontend (amb requirements optimitzats)
echo 5. Push de frontend a Docker Hub (sobreescriur├á l'antic)
echo 6. Executar l'aplicaci├│ completa
echo.
echo Les imatges antigues seran sobreescrites autom├áticament!
echo.
pause

echo.
echo ========================================
echo 1. VERIFICANT DOCKER...
echo ========================================
docker info >nul 2>&1
if errorlevel 1 (
    echo ÔØî Docker no est├á funcionant!
    echo Obre Docker Desktop i torna a executar aquest script.
    pause
    exit /b 1
)
echo ÔťÖ Docker est├á funcionant!

echo.
echo ========================================
echo 2. BUILD BACKEND (optimitzat)
echo ========================================
docker build -f backend/Dockerfile -t urkovitx/mobil-scan-backend:latest .
if errorlevel 1 (
    echo ERROR: Build de backend ha fallat!
    pause
    exit /b 1
)
echo ÔťÖ Backend build completat!

echo.
echo ========================================
echo 3. PUSH BACKEND
echo ========================================
docker push urkovitx/mobil-scan-backend:latest
if errorlevel 1 (
    echo ERROR: Push de backend ha fallat!
    pause
    exit /b 1
)
echo ÔťÖ Backend push completat! (sobreescrit al Docker Hub)

echo.
echo ========================================
echo 4. BUILD FRONTEND (optimitzat)
echo ========================================
docker build -f frontend/Dockerfile -t urkovitx/mobil-scan-frontend:latest .
if errorlevel 1 (
    echo ERROR: Build de frontend ha fallat!
    pause
    exit /b 1
)
echo ÔťÖ Frontend build completat!

echo.
echo ========================================
echo 5. PUSH FRONTEND
echo ========================================
docker push urkovitx/mobil-scan-frontend:latest
if errorlevel 1 (
    echo ERROR: Push de frontend ha fallat!
    pause
    exit /b 1
)
echo ÔťÖ Frontend push completat! (sobreescrit al Docker Hub)

echo.
echo ========================================
echo 6. EXECUTANT APLICACI├ô
echo ========================================
echo.
echo Baixant imatges actualitzades del Docker Hub...
docker-compose -f docker-compose.hub.yml pull
echo.
echo Iniciant aplicaci├│...
docker-compose -f docker-compose.hub.yml up -d

echo.
echo ========================================
echo ÔťÖ TOT COMPLETAT!
echo ========================================
echo.
echo L'aplicaci├│ est├á funcionant a:
echo   http://localhost:3000
echo.
echo Imatges actualitzades al Docker Hub:
echo   ÔťÖ urkovitx/mobil-scan-backend:latest
echo   ÔťÖ urkovitx/mobil-scan-frontend:latest
echo   ÔťÖ urkovitx/mobil-scan-worker:latest
echo.
echo Per veure els logs:
echo   docker-compose -f docker-compose.hub.yml logs -f
echo.
echo Per aturar:
echo   docker-compose -f docker-compose.hub.yml down
echo.
pause
