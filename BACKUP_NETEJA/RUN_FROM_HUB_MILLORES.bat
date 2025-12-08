@echo off
echo ========================================
echo MOBIL SCAN - Docker Hub (AMB MILLORES)
echo ========================================
echo.
echo Aquest script utilitza imatges pre-construides
echo del Docker Hub - NO cal build local!
echo.
echo Millores incloses:
echo  - Worker: Preprocessament avancat (6 tecniques)
echo  - Worker: Confidence combinada (YOLO + decode)
echo  - Frontend: Pestanya AI Analysis amb Phi-3
echo.
echo ========================================
echo.

REM Verificar Docker
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no esta actiu!
    echo.
    echo Opcions:
    echo 1. Obre Docker Desktop
    echo 2. O des de WSL2: sudo service docker start
    echo.
    pause
    exit /b 1
)

echo [OK] Docker actiu
echo.

REM Aturar contenidors antics
echo [1/5] Aturant contenidors antics...
docker-compose -f docker-compose.hub-millores.yml down 2>nul

echo.
echo [2/5] Descarregant imatges actualitzades...
echo (Pot trigar 2-5 minuts segons la connexio)
echo.

REM Pull de totes les imatges
docker pull redis:7-alpine
docker pull postgres:15-alpine
docker pull ollama/ollama:latest
docker pull urkovitx/mobil-scan-backend:latest
docker pull urkovitx/mobil-scan-frontend:latest
docker pull urkovitx/mobil-scan-worker:latest

if errorlevel 1 (
    echo.
    echo [AVIS] Alguna imatge no s'ha pogut descarregar
    echo Provant amb les imatges locals...
    echo.
)

echo.
echo [OK] Imatges descarregades!
echo.

REM Crear directoris necessaris
echo [3/5] Creant directoris...
if not exist "shared\videos" mkdir shared\videos
if not exist "shared\frames" mkdir shared\frames
if not exist "shared\results" mkdir shared\results
if not exist "worker\models" mkdir worker\models

echo.
echo [4/5] Iniciant serveis...
docker-compose -f docker-compose.hub-millores.yml up -d

if errorlevel 1 (
    echo.
    echo [ERROR] Hi ha hagut un problema iniciant els serveis
    echo.
    echo Revisa els logs amb:
    echo docker-compose -f docker-compose.hub-millores.yml logs
    echo.
    pause
    exit /b 1
)

echo.
echo [5/5] Esperant que els serveis estiguin llestos...
timeout /t 15 /nobreak >nul

echo.
echo Verificant estat dels serveis...
docker-compose -f docker-compose.hub-millores.yml ps

echo.
echo ========================================
echo APLICACIO INICIADA CORRECTAMENT!
echo ========================================
echo.
echo Serveis disponibles:
echo.
echo   Frontend:  http://localhost:8501
echo   Backend:   http://localhost:8000
echo   LLM:       http://localhost:11434
echo   Database:  localhost:5432
echo   Redis:     localhost:6379
echo.
echo ========================================
echo MILLORES ACTIVES:
echo ========================================
echo.
echo Worker (Preprocessament):
echo  - CLAHE (millora contrast)
echo  - Otsu threshold (binaritzacio)
echo  - Adaptive threshold (local)
echo  - Denoising (elimina soroll)
echo  - Resize (optimitza mida)
echo  - Confidence combinada (YOLO + decode)
echo.
echo Frontend (Nova pestanya):
echo  - AI Analysis amb Phi-3
echo  - 4 preguntes rapides
echo  - Chat personalitzat
echo  - Historial converses
echo.
echo ========================================
echo.
echo IMPORTANT: Descarrega model Phi-3 (primera vegada)
echo.
echo Executa en una altra terminal:
echo   docker exec mobil_scan_llm ollama pull phi3
echo.
echo (Pot trigar 10-15 minuts, pero nomes cal fer-ho una vegada)
echo.
echo ========================================
echo.
echo Per veure logs en temps real:
echo   docker-compose -f docker-compose.hub-millores.yml logs -f
echo.
echo Per aturar l'aplicacio:
echo   docker-compose -f docker-compose.hub-millores.yml down
echo.
echo ========================================
echo.

REM Preguntar si vol obrir el navegador
set /p OPEN="Vols obrir el navegador ara? (S/N): "
if /i "%OPEN%"=="S" (
    start http://localhost:8501
    echo.
    echo Navegador obert!
    echo.
    echo Prova amb el teu video: VID_20251204_170312.mp4
    echo Espera millora de 25%% a 75-100%% codis llegibles!
)

echo.
echo ========================================
echo GAUDEIX DE LES MILLORES! 🚀
echo ========================================
echo.
pause
