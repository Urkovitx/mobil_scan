@echo off
echo ========================================
echo   UTILITZAR DOCKER DESKTOP (FACIL)
echo ========================================
echo.
echo Aquest script utilitza Docker Desktop
echo NO necessita WSL2
echo.
pause

echo.
echo [1/5] Verificant Docker Desktop...
docker --version
if errorlevel 1 (
    echo.
    echo ERROR: Docker Desktop no esta en execucio
    echo.
    echo SOLUCIO:
    echo 1. Obre Docker Desktop
    echo 2. Espera que digui "Docker Desktop is running"
    echo 3. Torna a executar aquest script
    echo.
    pause
    exit /b 1
)

echo OK: Docker Desktop funciona!
echo.

echo [2/5] Aturant contenidors antics...
docker-compose down
echo.

echo [3/5] Construint worker (aixo pot trigar 5-10 minuts)...
echo Utilitzant Dockerfile.minimal per ser mes rapid...
docker-compose build --no-cache --pull worker
if errorlevel 1 (
    echo.
    echo ERROR en el build
    echo Revisa els errors de dalt
    pause
    exit /b 1
)
echo.

echo [4/5] Iniciant tots els serveis...
docker-compose up -d
echo.

echo [5/5] Verificant estat...
docker-compose ps
echo.

echo ========================================
echo   VERIFICACIO FINAL
echo ========================================
echo.

echo Provant zxing-cpp...
docker-compose exec worker python -c "import zxingcpp; print('zxing-cpp version:', zxingcpp.__version__)"
echo.

echo ========================================
echo   COMPLETAT!
echo ========================================
echo.
echo Aplicacio disponible a:
echo   Frontend: http://localhost:8501
echo   API: http://localhost:8000
echo.
echo Per veure logs:
echo   docker-compose logs -f worker
echo.
echo Per aturar:
echo   docker-compose down
echo.

echo Vols obrir l'aplicacio al navegador? (S/N)
set /p OPEN="Resposta: "
if /i "%OPEN%"=="S" (
    start http://localhost:8501
)

pause
