@echo off
echo ========================================
echo BUILD SEQUENTIAL - Mobil Scan
echo ========================================
echo.
echo Aquest script fa build dels contenidors UN PER UN
echo per evitar problemes de recursos de Docker.
echo.
echo Temps estimat: 30-40 minuts
echo.
pause

echo.
echo [1/5] Netejant Docker...
docker-compose down
docker system prune -f

echo.
echo [2/5] Building WORKER (el mes pesat)...
echo Temps estimat: 15-20 minuts
docker-compose build worker
if %errorlevel% neq 0 (
    echo ERROR: Worker build failed!
    pause
    exit /b 1
)

echo.
echo [3/5] Building API...
echo Temps estimat: 5-10 minuts
docker-compose build api
if %errorlevel% neq 0 (
    echo ERROR: API build failed!
    pause
    exit /b 1
)

echo.
echo [4/5] Building FRONTEND...
echo Temps estimat: 5-10 minuts
docker-compose build frontend
if %errorlevel% neq 0 (
    echo ERROR: Frontend build failed!
    pause
    exit /b 1
)

echo.
echo [5/5] Arrencant tots els serveis...
docker-compose up

echo.
echo ========================================
echo BUILD COMPLETAT!
echo ========================================
pause
