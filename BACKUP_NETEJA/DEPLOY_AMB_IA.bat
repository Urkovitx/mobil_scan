@echo off
echo ========================================
echo DEPLOY APLICACIO AMB IA A CLOUD RUN
echo ========================================
echo.

echo [INFO] Aquest script desplegara l'aplicacio amb Gemini AI integrat
echo.

:check_gemini
echo [IMPORTANT] Necessites una API Key de Gemini!
echo.
echo Si encara no la tens:
echo 1. Ves a: https://makersuite.google.com/app/apikey
echo 2. Crea una API Key
echo 3. Copia-la
echo.

set /p GEMINI_KEY="Introdueix la teva GEMINI_API_KEY (o prem Enter per ometre): "

if "%GEMINI_KEY%"=="" (
    echo.
    echo [WARNING] No has introduit cap API Key
    echo L'aplicacio es desplegara pero la IA no funcionara
    echo.
    set /p CONTINUE="Vols continuar igualment? (S/N): "
    if /i not "%CONTINUE%"=="S" (
        echo.
        echo [CANCEL] Desplegament cancel·lat
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo PAS 1: BUILD IMATGES AL NUVOL
echo ========================================
echo.

echo [1/3] Compilant imatges amb Google Cloud Build...
gcloud builds submit --config=cloudbuild.yaml

if errorlevel 1 (
    echo.
    echo [ERROR] Build fallit!
    echo Revisa els logs a: https://console.cloud.google.com/cloud-build
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Imatges compilades correctament!
echo.

echo ========================================
echo PAS 2: DESPLEGAR SERVEIS
echo ========================================
echo.

echo [2/3] Desplegant Backend amb IA...

if not "%GEMINI_KEY%"=="" (
    gcloud run deploy mobil-scan-backend ^
      --image gcr.io/mobil-scan-app/mobil-scan-backend:latest ^
      --platform managed ^
      --region europe-west1 ^
      --allow-unauthenticated ^
      --memory 2Gi ^
      --cpu 2 ^
      --port 8000 ^
      --set-env-vars "GEMINI_API_KEY=%GEMINI_KEY%,REDIS_URL=redis://redis:6379,DATABASE_URL=postgresql://mobilscan:mobilscan123@db/mobilscan_db"
) else (
    gcloud run deploy mobil-scan-backend ^
      --image gcr.io/mobil-scan-app/mobil-scan-backend:latest ^
      --platform managed ^
      --region europe-west1 ^
      --allow-unauthenticated ^
      --memory 2Gi ^
      --cpu 2 ^
      --port 8000
)

if errorlevel 1 (
    echo.
    echo [ERROR] Deploy del backend fallit!
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Backend desplegat!
echo.

echo [3/3] Desplegant Frontend...

for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)"') do set BACKEND_URL=%%i

gcloud run deploy mobil-scan-frontend ^
  --image gcr.io/mobil-scan-app/mobil-scan-frontend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 1Gi ^
  --cpu 1 ^
  --port 8501 ^
  --set-env-vars "API_URL=%BACKEND_URL%"

if errorlevel 1 (
    echo.
    echo [ERROR] Deploy del frontend fallit!
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Frontend desplegat!
echo.

echo ========================================
echo PAS 3: OBTENIR URLS
echo ========================================
echo.

for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-frontend --region europe-west1 --format="value(status.url)"') do set FRONTEND_URL=%%i

echo.
echo ========================================
echo DEPLOY COMPLETAT AMB EXIT!
echo ========================================
echo.
echo Frontend URL: %FRONTEND_URL%
echo Backend URL:  %BACKEND_URL%
echo.

if not "%GEMINI_KEY%"=="" (
    echo [INFO] IA Gemini: ACTIVADA ✅
) else (
    echo [WARNING] IA Gemini: NO CONFIGURADA ⚠️
    echo Per activar-la, executa:
    echo gcloud run services update mobil-scan-backend --set-env-vars "GEMINI_API_KEY=LA_TEVA_CLAU"
)

echo.
echo Obre l'aplicacio: %FRONTEND_URL%
echo.
echo ========================================
pause
