@echo off
echo ========================================
echo TEST EXHAUSTIU - Refactor YOLOv8
echo ========================================
echo.

echo [1/10] Aturant contenidors existents...
docker-compose down
echo.

echo [2/10] Netejant imatges antigues del worker...
docker rmi mobil_scan-worker 2>nul
echo.

echo [3/10] Building worker amb noves dependencies...
docker-compose build --no-cache worker
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build del worker ha fallat!
    pause
    exit /b 1
)
echo Build completat correctament!
echo.

echo [4/10] Iniciant tots els serveis...
docker-compose up -d
echo.

echo [5/10] Esperant que els serveis s'iniciïn (15 segons)...
timeout /t 15 /nobreak >nul
echo.

echo [6/10] Verificant estat dels contenidors...
docker-compose ps
echo.

echo [7/10] Verificant logs del worker...
echo ----------------------------------------
docker-compose logs worker --tail=30
echo ----------------------------------------
echo.

echo [8/10] Verificant logs de Redis...
echo ----------------------------------------
docker-compose logs redis --tail=10
echo ----------------------------------------
echo.

echo [9/10] Verificant logs de la base de dades...
echo ----------------------------------------
docker-compose logs db --tail=10
echo ----------------------------------------
echo.

echo [10/10] Verificant logs del backend...
echo ----------------------------------------
docker-compose logs api --tail=10
echo ----------------------------------------
echo.

echo ========================================
echo RESUM DEL TEST
echo ========================================
echo.
echo Contenidors actius:
docker ps --format "table {{.Names}}\t{{.Status}}"
echo.

echo ========================================
echo ENDPOINTS DISPONIBLES
echo ========================================
echo Frontend: http://localhost:8501
echo Backend API: http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo Redis: localhost:6379
echo PostgreSQL: localhost:5432
echo.

echo ========================================
echo PROXIMS PASSOS
echo ========================================
echo 1. Accedeix al frontend: http://localhost:8501
echo 2. Puja un video de prova
echo 3. Verifica els logs: docker-compose logs worker -f
echo 4. Comprova resultats a: shared/results/
echo.

pause
