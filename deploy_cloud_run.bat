@echo off
echo ========================================
echo DEPLOY A GOOGLE CLOUD RUN
echo ========================================
echo.
echo Aquest script desplega l'aplicacio
echo a Google Cloud Run (sense Docker Desktop!)
echo.
echo Requisits:
echo  - Compte Google Cloud creat
echo  - Google Cloud CLI instal·lat
echo  - Sessio iniciada (gcloud auth login)
echo.
echo ========================================
echo.
pause

REM Verificar que gcloud esta instal·lat
where gcloud >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Google Cloud CLI no esta instal·lat!
    echo.
    echo Descarrega'l de:
    echo https://cloud.google.com/sdk/docs/install
    echo.
    pause
    exit /b 1
)

echo [OK] Google Cloud CLI detectat
echo.

REM Obtenir projecte actual
for /f "tokens=*" %%i in ('gcloud config get-value project 2^>nul') do set PROJECT_ID=%%i

if "%PROJECT_ID%"=="" (
    echo [ERROR] No hi ha cap projecte configurat!
    echo.
    echo Executa:
    echo   gcloud config set project mobil-scan
    echo.
    pause
    exit /b 1
)

echo [OK] Projecte: %PROJECT_ID%
echo.

echo ========================================
echo PAS 1/4: COMPILANT IMATGES AL NUVOL
echo ========================================
echo.
echo Aixo trigara 15-20 minuts...
echo Les imatges es compilen als servidors de Google.
echo.

gcloud builds submit --config=cloudbuild.yaml

if errorlevel 1 (
    echo.
    echo [ERROR] La compilacio ha fallat!
    echo.
    echo Possibles causes:
    echo  - APIs no activades
    echo  - Quota excedida
    echo  - Error al codi
    echo.
    echo Revisa els logs a:
    echo https://console.cloud.google.com/cloud-build/builds
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Imatges compilades correctament!
echo.

echo ========================================
echo PAS 2/4: DESPLEGANT BACKEND
echo ========================================
echo.

gcloud run deploy mobil-scan-backend ^
  --image gcr.io/%PROJECT_ID%/mobil-scan-backend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 2Gi ^
  --cpu 2 ^
  --port 8000 ^
  --max-instances 10 ^
  --min-instances 0

if errorlevel 1 (
    echo [ERROR] Deploy del backend ha fallat!
    pause
    exit /b 1
)

echo [OK] Backend desplegat!
echo.

REM Obtenir URL del backend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)" 2^>nul') do set BACKEND_URL=%%i

echo Backend URL: %BACKEND_URL%
echo.

echo ========================================
echo PAS 3/4: DESPLEGANT FRONTEND
echo ========================================
echo.

gcloud run deploy mobil-scan-frontend ^
  --image gcr.io/%PROJECT_ID%/mobil-scan-frontend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 1Gi ^
  --cpu 1 ^
  --port 8501 ^
  --max-instances 10 ^
  --min-instances 0 ^
  --set-env-vars "API_URL=%BACKEND_URL%"

if errorlevel 1 (
    echo [ERROR] Deploy del frontend ha fallat!
    pause
    exit /b 1
)

echo [OK] Frontend desplegat!
echo.

REM Obtenir URL del frontend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-frontend --region europe-west1 --format="value(status.url)" 2^>nul') do set FRONTEND_URL=%%i

echo Frontend URL: %FRONTEND_URL%
echo.

echo ========================================
echo PAS 4/4: DESPLEGANT WORKER
echo ========================================
echo.

gcloud run deploy mobil-scan-worker ^
  --image gcr.io/%PROJECT_ID%/mobil-scan-worker:latest ^
  --platform managed ^
  --region europe-west1 ^
  --no-allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --max-instances 5 ^
  --min-instances 0

if errorlevel 1 (
    echo [ERROR] Deploy del worker ha fallat!
    pause
    exit /b 1
)

echo [OK] Worker desplegat!
echo.

echo ========================================
echo DEPLOY COMPLETAT AMB EXIT!
echo ========================================
echo.
echo Serveis desplegats:
echo.
echo   Frontend:  %FRONTEND_URL%
echo   Backend:   %BACKEND_URL%
echo   Worker:    (executa en background)
echo.
echo ========================================
echo PROXIMS PASSOS
echo ========================================
echo.
echo 1. Configura base de dades (Cloud SQL):
echo    gcloud sql instances create mobil-scan-db
echo.
echo 2. Configura Redis (Memorystore):
echo    gcloud redis instances create mobil-scan-redis
echo.
echo 3. Actualitza variables d'entorn amb URLs reals
echo.
echo Veure: DEPLOY_GOOGLE_CLOUD_RUN.md
echo.
echo ========================================
echo.

set /p OPEN="Vols obrir el frontend al navegador? (S/N): "
if /i "%OPEN%"=="S" (
    start %FRONTEND_URL%
    echo.
    echo Navegador obert!
)

echo.
pause
