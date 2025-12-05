@echo off
echo ========================================
echo EXECUTAR TOT - Backend + Frontend + Worker
echo ========================================
echo.

echo [1/4] Aturant contenidors existents...
docker stop backend frontend worker redis 2>nul
docker rm backend frontend worker redis 2>nul
echo.

echo [2/4] Creant xarxa Docker...
docker network create mobil_scan_network 2>nul
echo.

echo [3/4] Iniciant Redis...
docker run -d ^
  --name redis ^
  --network mobil_scan_network ^
  -p 6379:6379 ^
  redis:alpine
echo ✓ Redis iniciat!
echo.

echo [4/4] Iniciant serveis...
echo.

echo   [4.1] Backend (FastAPI)...
docker run -d ^
  --name backend ^
  --network mobil_scan_network ^
  -p 8000:8000 ^
  -e REDIS_HOST=redis ^
  -e REDIS_PORT=6379 ^
  urkovitx/mobil_scan-backend:latest
echo   ✓ Backend iniciat a http://localhost:8000
echo.

echo   [4.2] Frontend (Streamlit)...
docker run -d ^
  --name frontend ^
  --network mobil_scan_network ^
  -p 8501:8501 ^
  -e API_URL=http://backend:8000 ^
  urkovitx/mobil_scan-frontend:latest
echo   ✓ Frontend iniciat a http://localhost:8501
echo.

echo   [4.3] Worker (Celery + PaddlePaddle)...
docker run -d ^
  --name worker ^
  --network mobil_scan_network ^
  -e REDIS_HOST=redis ^
  -e REDIS_PORT=6379 ^
  urkovitx/mobil_scan-worker:latest
echo   ✓ Worker iniciat!
echo.

echo ========================================
echo ✓ TOT INICIAT CORRECTAMENT!
echo ========================================
echo.
echo Serveis disponibles:
echo   - Frontend: http://localhost:8501
echo   - Backend API: http://localhost:8000
echo   - Redis: localhost:6379
echo.
echo Per veure logs:
echo   docker logs -f backend
echo   docker logs -f frontend
echo   docker logs -f worker
echo.
echo Per aturar tot:
echo   docker stop backend frontend worker redis
echo.

start http://localhost:8501

pause
