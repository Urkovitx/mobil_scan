@echo off
echo ========================================
echo MOBIL SCAN - Versio Base (FUNCIONAL)
echo ========================================
echo.
echo Aquest script utilitza el docker-compose
echo original que SI funciona ara mateix.
echo.
echo Nota: Les millores amb IA es poden afegir
echo despres quan GitHub Actions funcioni.
echo.
echo ========================================
echo.

REM Verificar Docker
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no esta actiu!
    echo.
    echo Executa: INICIAR_DOCKER_I_EXECUTAR.bat
    echo.
    pause
    exit /b 1
)

echo [OK] Docker actiu
echo.

REM Aturar contenidors antics
echo [1/4] Aturant contenidors antics...
docker-compose down 2>nul

echo.
echo [2/4] Creant directoris...
if not exist "shared\videos" mkdir shared\videos
if not exist "shared\frames" mkdir shared\frames
if not exist "shared\results" mkdir shared\results
if not exist "worker\models" mkdir worker\models

echo.
echo [3/4] Iniciant serveis...
docker-compose up -d

if errorlevel 1 (
    echo.
    echo [ERROR] Hi ha hagut un problema iniciant els serveis
    echo.
    echo Revisa els logs amb:
    echo docker-compose logs
    echo.
    pause
    exit /b 1
)

echo.
echo [4/4] Esperant que els serveis estiguin llestos...
timeout /t 15 /nobreak >nul

echo.
echo Verificant estat dels serveis...
docker-compose ps

echo.
echo ========================================
echo APLICACIO INICIADA CORRECTAMENT!
echo ========================================
echo.
echo Serveis disponibles:
echo.
echo   Frontend:  http://localhost:8501
echo   Backend:   http://localhost:8000
echo   Database:  localhost:5432
echo   Redis:     localhost:6379
echo.
echo ========================================
echo NOTA IMPORTANT:
echo ========================================
echo.
echo Aquesta es la versio BASE sense les millores.
echo Per afegir les millores amb IA:
echo.
echo 1. Arregla GitHub Actions (veure logs)
echo 2. O compila localment amb:
echo    REBUILD_COMPLET_AMB_IA.bat
echo.
echo ========================================
echo.

REM Preguntar si vol obrir el navegador
set /p OPEN="Vols obrir el navegador ara? (S/N): "
if /i "%OPEN%"=="S" (
    start http://localhost:8501
    echo.
    echo Navegador obert!
)

echo.
pause
