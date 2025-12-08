@echo off
echo ========================================
echo DEPLOY A DOCKER HUB - VERSIO FACIL
echo ========================================
echo.

echo [1/8] Fent login a Docker Hub...
echo.
echo IMPORTANT: Necessites el teu Docker Hub token
echo Obtenir-lo a: hub.docker.com ^> Account Settings ^> Security ^> New Access Token
echo.
set /p DOCKER_USERNAME="Usuari Docker Hub: "
set /p DOCKER_TOKEN="Token Docker Hub: "
echo.
echo %DOCKER_TOKEN% | docker login -u %DOCKER_USERNAME% --password-stdin

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Login fallit
    echo Verifica que el token es correcte
    pause
    exit /b 1
)

echo ✅ Login correcte!
echo.

echo [2/8] Build Backend (triga 5-7 min)...
cd backend
docker build -t %DOCKER_USERNAME%/mobil-scan-backend:latest .
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build backend fallit
    cd ..
    pause
    exit /b 1
)
echo ✅ Backend build OK!
cd ..
echo.

echo [3/8] Push Backend al nuvol (triga 2 min)...
docker push %DOCKER_USERNAME%/mobil-scan-backend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Push backend fallit
    pause
    exit /b 1
)
echo ✅ Backend al nuvol!
echo.

echo [4/8] Build Frontend (triga 5-7 min)...
cd frontend
docker build -t %DOCKER_USERNAME%/mobil-scan-frontend:latest .
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build frontend fallit
    cd ..
    pause
    exit /b 1
)
echo ✅ Frontend build OK!
cd ..
echo.

echo [5/8] Push Frontend al nuvol (triga 2 min)...
docker push %DOCKER_USERNAME%/mobil-scan-frontend:latest
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Push frontend fallit
    pause
    exit /b 1
)
echo ✅ Frontend al nuvol!
echo.

echo [6/8] Creant xarxa...
docker network create mobil_scan_network 2>nul
echo ✅ Xarxa creada!
echo.

echo [7/8] Executant contenidors...
docker stop backend frontend 2>nul
docker rm backend frontend 2>nul

docker run -d --name backend --network mobil_scan_network -p 8000:8000 %DOCKER_USERNAME%/mobil-scan-backend:latest
docker run -d --name frontend --network mobil_scan_network -p 8501:8501 %DOCKER_USERNAME%/mobil-scan-frontend:latest

echo ✅ Contenidors executant-se!
echo.

echo [8/8] Verificant estat...
timeout /t 3 /nobreak >nul
docker ps
echo.

echo ========================================
echo DESPLEGAMENT COMPLET!
echo ========================================
echo.
echo Frontend: http://localhost:8501
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
echo Imatges a Docker Hub:
echo - %DOCKER_USERNAME%/mobil-scan-backend:latest
echo - %DOCKER_USERNAME%/mobil-scan-frontend:latest
echo.

echo Obrint navegador...
start http://localhost:8501

echo.
pause
