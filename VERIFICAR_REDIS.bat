@echo off
echo ========================================
echo VERIFICAR REDIS
echo ========================================
echo.

echo [1/5] Verificant Docker...
docker --version
if errorlevel 1 (
    echo ❌ Docker no esta instal·lat o no funciona
    pause
    exit /b 1
)
echo ✅ Docker OK
echo.

echo [2/5] Verificant contenidors Docker...
docker ps -a
echo.

echo [3/5] Verificant contenidor Redis...
docker inspect redis >nul 2>&1
if errorlevel 1 (
    echo ❌ Contenidor 'redis' no existeix
    echo.
    echo Creant contenidor Redis...
    docker run -d -p 6379:6379 --name redis redis:7-alpine
    echo ✅ Redis creat
) else (
    echo ✅ Contenidor 'redis' existeix
)
echo.

echo [4/5] Verificant estat de Redis...
docker ps --filter "name=redis" --format "{{.Status}}"
echo.

echo [5/5] Intentant connectar a Redis...
docker exec redis redis-cli ping
if errorlevel 1 (
    echo ❌ Redis no respon
    echo.
    echo Intentant iniciar Redis...
    docker start redis
    timeout /t 2 >nul
    docker exec redis redis-cli ping
) else (
    echo ✅ Redis funciona correctament!
)

echo.
echo ========================================
echo RESUM
echo ========================================
echo.
echo Si Redis funciona, pots executar:
echo   EXECUTAR_WORKER_SENSE_DOCKER.bat
echo.
pause
