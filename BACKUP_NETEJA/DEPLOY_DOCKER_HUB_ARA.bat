@echo off
echo ========================================
echo DEPLOY A DOCKER HUB - ARA MATEIX
echo ========================================
echo.

echo [IMPORTANT] Necessito el teu Docker Hub token.
echo.
echo On trobar-lo:
echo 1. Anar a hub.docker.com
echo 2. Account Settings ^> Security
echo 3. New Access Token
echo.

set /p DOCKER_USERNAME="Introdueix el teu usuari Docker Hub: "
set /p DOCKER_TOKEN="Introdueix el teu token Docker Hub: "

echo.
echo ========================================
echo FENT LOGIN A DOCKER HUB
echo ========================================
echo.

echo %DOCKER_TOKEN% | docker login -u %DOCKER_USERNAME% --password-stdin

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Login fallit. Verifica usuari i token.
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD I PUSH - BACKEND
echo ========================================
echo.

cd backend
docker build -t %DOCKER_USERNAME%/mobil-scan-backend:latest .
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build backend fallit
    cd ..
    pause
    exit /b 1
)

docker push %DOCKER_USERNAME%/mobil-scan-backend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Push backend fallit
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ========================================
echo BUILD I PUSH - FRONTEND
echo ========================================
echo.

cd frontend
docker build -t %DOCKER_USERNAME%/mobil-scan-frontend:latest .
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build frontend fallit
    cd ..
    pause
    exit /b 1
)

docker push %DOCKER_USERNAME%/mobil-scan-frontend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Push frontend fallit
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ========================================
echo BUILD I PUSH - WORKER
echo ========================================
echo.
echo ATENCIO: Worker triga molt (PaddlePaddle es gran)
echo Vols fer build del Worker ara? (S/N)
set /p build_worker=

if /i "%build_worker%"=="S" (
    cd worker
    docker build -t %DOCKER_USERNAME%/mobil-scan-worker:latest .
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Build worker fallit
        cd ..
        pause
        exit /b 1
    )
    
    docker push %DOCKER_USERNAME%/mobil-scan-worker:latest
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Push worker fallit
        cd ..
        pause
        exit /b 1
    )
    cd ..
)

echo.
echo ========================================
echo DESPLEGANT AL NUVOL
echo ========================================
echo.

echo Creant xarxa...
docker network create mobil_scan_network 2>nul

echo.
echo Executant Backend...
docker run -d --name backend --network mobil_scan_network -p 8000:8000 %DOCKER_USERNAME%/mobil-scan-backend:latest

echo.
echo Executant Frontend...
docker run -d --name frontend --network mobil_scan_network -p 8501:8501 %DOCKER_USERNAME%/mobil-scan-frontend:latest

if /i "%build_worker%"=="S" (
    echo.
    echo Executant Worker...
    docker run -d --name worker --network mobil_scan_network %DOCKER_USERNAME%/mobil-scan-worker:latest
)

echo.
echo ========================================
echo VERIFICANT ESTAT
echo ========================================
echo.

timeout /t 5 /nobreak >nul
docker ps

echo.
echo ========================================
echo OBERT NAVEGADOR
echo ========================================
echo.

start http://localhost:8501

echo.
echo ========================================
echo DESPLEGAMENT COMPLET!
echo ========================================
echo.
echo Frontend: http://localhost:8501
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
echo Les imatges estan a Docker Hub:
echo - %DOCKER_USERNAME%/mobil-scan-backend:latest
echo - %DOCKER_USERNAME%/mobil-scan-frontend:latest
if /i "%build_worker%"=="S" (
    echo - %DOCKER_USERNAME%/mobil-scan-worker:latest
)
echo.
pause
