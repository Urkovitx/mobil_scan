@echo off
echo ========================================
echo EXECUTAR mobil_scan (Imatges Cloud)
echo ========================================

echo.
echo [1/3] Aturant contenidors locals si n'hi ha...
docker-compose down 2>nul

echo.
echo [2/3] Descarregant imatges des de Docker Hub...
echo (Això pot trigar 2-3 minuts la primera vegada)
docker pull urkovitx/mobil_scan-backend:latest
docker pull urkovitx/mobil_scan-frontend:latest
docker pull urkovitx/mobil_scan-worker:latest

echo.
echo [3/3] Iniciant contenidors...
docker-compose -f docker-compose.cloud.yml up -d

echo.
echo ========================================
echo ✅ APLICACIÓ EN EXECUCIÓ!
echo ========================================
echo.
echo Serveis disponibles:
echo   - Frontend: http://localhost:8501
echo   - API:      http://localhost:8000
echo   - Redis:    localhost:6379
echo.
echo Per veure els logs:
echo   docker-compose -f docker-compose.cloud.yml logs -f
echo.
echo Per aturar:
echo   docker-compose -f docker-compose.cloud.yml down
echo.
pause
