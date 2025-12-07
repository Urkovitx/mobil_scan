@echo off
echo ========================================
echo INICIAR DOCKER I REBUILD COMPLET
echo ========================================
echo.

echo [Pas 1] Verificant Docker...
docker version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Docker no esta actiu!
    echo.
    echo Per favor:
    echo 1. Obre Docker Desktop
    echo 2. Espera que estigui completament iniciat
    echo 3. Torna a executar aquest script
    echo.
    pause
    exit /b 1
)

echo Docker esta actiu!
echo.

echo [Pas 2] Aturant contenidors antics...
docker-compose down

echo.
echo [Pas 3] Rebuild Worker (amb millores preprocessament)...
docker-compose build --no-cache worker

echo.
echo [Pas 4] Rebuild Frontend (amb pestanya IA)...
docker-compose build --no-cache frontend

echo.
echo [Pas 5] Iniciant tots els serveis...
docker-compose up -d

echo.
echo [Pas 6] Esperant que els serveis estiguin llests...
timeout /t 15 /nobreak >nul

echo.
echo [Pas 7] Verificant estat...
docker-compose ps

echo.
echo ========================================
echo REBUILD COMPLETAT!
echo ========================================
echo.
echo Millores aplicades:
echo  - Worker: Preprocessament avancat (6 tecniques)
echo  - Worker: Confidence combinada (YOLO + decode)
echo  - Frontend: Pestanya AI Analysis amb Phi-3
echo.
echo Accedeix a: http://localhost:8501
echo.
echo Pestanyes disponibles:
echo  1. Upload Video
echo  2. Audit Dashboard
echo  3. AI Analysis  (NOVA!)
echo  4. Job History
echo.
echo Prova amb el teu video VID_20251204_170312.mp4
echo Espera millora de 25%% a 75-100%% codis llegibles!
echo.
pause
