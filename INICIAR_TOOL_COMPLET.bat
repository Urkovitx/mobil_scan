@echo off
echo ========================================
echo INICIAR TOOL COMPLET
echo ========================================
echo.
echo Aquesta eina iniciarà tots els serveis necessaris:
echo   1. Redis
echo   2. Worker
echo   3. Backend
echo   4. Frontend
echo.
echo IMPORTANT: S'obriran 4 terminals!
echo.
pause

echo.
echo [1/4] Iniciant Redis...
start "Redis Server" cmd /k "redis-server"
timeout /t 2 >nul

echo [2/4] Iniciant Worker...
start "Worker" cmd /k "EXECUTAR_WORKER_SENSE_DOCKER.bat"
timeout /t 5 >nul

echo [3/4] Iniciant Backend...
start "Backend API" cmd /k "cd backend && python main.py"
timeout /t 3 >nul

echo [4/4] Iniciant Frontend...
start "Frontend" cmd /k "cd frontend && streamlit run app.py"

echo.
echo ========================================
echo TOOL INICIADA!
echo ========================================
echo.
echo S'han obert 4 terminals:
echo   1. Redis Server (port 6379)
echo   2. Worker (processament de videos)
echo   3. Backend API (port 8000)
echo   4. Frontend (port 8501)
echo.
echo El navegador s'obrira automaticament amb la tool!
echo URL: http://localhost:8501
echo.
echo Per aturar tot: Tanca les 4 terminals
echo.
echo ========================================
pause
