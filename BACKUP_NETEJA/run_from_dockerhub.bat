@echo off
echo ========================================
echo Mobile Scan - Executar des de Docker Hub
echo ========================================
echo.
echo Aquest script executa l'aplicacio completa
echo usant les imatges del Docker Hub (NO cal build local!)
echo.

REM Verificar que Docker esta en marxa
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no esta en marxa!
    echo.
    echo Opcions:
    echo 1. Obre Docker Desktop
    echo 2. O executa: wsl -d docker-desktop
    echo.
    pause
    exit /b 1
)

echo [OK] Docker esta en marxa
echo.

REM Verificar que existeix el fitxer .env
if not exist .env (
    echo [AVIS] No existeix el fitxer .env
    echo Creant .env des de .env.example...
    copy .env.example .env
    echo.
    echo [IMPORTANT] Edita el fitxer .env i afegeix la teva GEMINI_API_KEY
    echo Despres torna a executar aquest script.
    echo.
    notepad .env
    pause
    exit /b 0
)

echo [OK] Fitxer .env trobat
echo.

REM Aturar contenidors anteriors si existeixen
echo Aturant contenidors anteriors...
docker-compose -f docker-compose.hub.yml down 2>nul
echo.

REM Descarregar les imatges del Docker Hub
echo ========================================
echo Descarregant imatges del Docker Hub...
echo ========================================
echo.
echo Aixo pot trigar uns minuts la primera vegada...
echo.

docker pull urkovitx/mobil-scan-backend:latest
docker pull urkovitx/mobil-scan-frontend:latest
docker pull urkovitx/mobil-scan-worker-test:ci
docker pull postgres:15-alpine
docker pull redis:7-alpine

echo.
echo [OK] Imatges descarregades!
echo.

REM Iniciar els serveis
echo ========================================
echo Iniciant serveis...
echo ========================================
echo.

docker-compose -f docker-compose.hub.yml up -d

if errorlevel 1 (
    echo.
    echo [ERROR] Hi ha hagut un problema iniciant els serveis
    echo.
    echo Revisa els logs amb:
    echo docker-compose -f docker-compose.hub.yml logs
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] Aplicacio iniciada correctament!
echo ========================================
echo.
echo Serveis disponibles:
echo.
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   Database:  localhost:5432
echo   Redis:     localhost:6379
echo.
echo Per veure els logs:
echo   docker-compose -f docker-compose.hub.yml logs -f
echo.
echo Per aturar l'aplicacio:
echo   docker-compose -f docker-compose.hub.yml down
echo.
echo Esperant que els serveis estiguin llestos...
timeout /t 10 /nobreak >nul
echo.

REM Verificar estat dels serveis
echo Estat dels serveis:
echo.
docker-compose -f docker-compose.hub.yml ps

echo.
echo ========================================
echo Obre el navegador a: http://localhost:3000
echo ========================================
echo.

REM Preguntar si vol obrir el navegador
set /p OPEN="Vols obrir el navegador ara? (S/N): "
if /i "%OPEN%"=="S" (
    start http://localhost:3000
)

echo.
pause
