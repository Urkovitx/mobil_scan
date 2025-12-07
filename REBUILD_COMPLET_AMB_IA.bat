@echo off
echo ========================================
echo REBUILD COMPLET - Worker + Frontend + IA
echo ========================================
echo.

echo [1/5] Aturant contenidors...
docker-compose down

echo.
echo [2/5] Rebuild Worker (amb millores preprocessament)...
docker-compose build --no-cache worker

echo.
echo [3/5] Rebuild Frontend (amb pestanya IA)...
docker-compose build --no-cache frontend

echo.
echo [4/5] Iniciant tots els serveis...
docker-compose up -d

echo.
echo [5/5] Verificant estat...
timeout /t 10 /nobreak >nul
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
pause
