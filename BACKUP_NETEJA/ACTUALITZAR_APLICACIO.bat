@echo off
chcp 65001 >nul
echo ========================================
echo 🔄 ACTUALITZAR APLICACIÓ
echo ========================================
echo.
echo Aquest script:
echo   1. Rebuildarà les imatges al núvol
echo   2. Redesplegarà els serveis
echo   3. Mostrarà les URLs actualitzades
echo.
echo Temps estimat: 15-20 minuts
echo.
pause

echo.
echo ========================================
echo PAS 1/2: REBUILD AL NÚVOL
echo ========================================
echo.
echo Pujant codi i compilant imatges...
echo (Això trigarà 15-20 minuts)
echo.

gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app

if errorlevel 1 (
    echo.
    echo ❌ ERROR: El build ha fallat!
    echo.
    echo Revisa els logs a:
    echo https://console.cloud.google.com/cloud-build/builds?project=mobil-scan-app
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Build completat!
echo.

echo ========================================
echo PAS 2/2: REDESPLEGAR SERVEIS
echo ========================================
echo.

REM Obtenir URL del backend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set BACKEND_URL=%%i

if "%BACKEND_URL%"=="" (
    echo ⚠️  Backend no trobat, desplegant per primera vegada...
    set BACKEND_URL=https://mobil-scan-backend-placeholder.run.app
)

echo Desplegant Backend...
gcloud run deploy mobil-scan-backend ^
  --image gcr.io/mobil-scan-app/mobil-scan-backend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 2Gi ^
  --cpu 2 ^
  --port 8000 ^
  --project mobil-scan-app ^
  --quiet

if errorlevel 1 (
    echo ❌ Error desplegant backend
    pause
    exit /b 1
)

echo ✅ Backend desplegat!
echo.

REM Actualitzar URL del backend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set BACKEND_URL=%%i

echo Desplegant Frontend...
gcloud run deploy mobil-scan-frontend ^
  --image gcr.io/mobil-scan-app/mobil-scan-frontend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 1Gi ^
  --cpu 1 ^
  --port 8501 ^
  --set-env-vars "API_URL=%BACKEND_URL%" ^
  --project mobil-scan-app ^
  --quiet

if errorlevel 1 (
    echo ❌ Error desplegant frontend
    pause
    exit /b 1
)

echo ✅ Frontend desplegat!
echo.

echo Desplegant Worker...
gcloud run deploy mobil-scan-worker ^
  --image gcr.io/mobil-scan-app/mobil-scan-worker:latest ^
  --platform managed ^
  --region europe-west1 ^
  --no-allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --project mobil-scan-app ^
  --quiet

if errorlevel 1 (
    echo ❌ Error desplegant worker
    pause
    exit /b 1
)

echo ✅ Worker desplegat!
echo.

REM Obtenir URL del frontend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-frontend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set FRONTEND_URL=%%i

echo ========================================
echo ✅ ACTUALITZACIÓ COMPLETADA!
echo ========================================
echo.
echo La teva aplicació està actualitzada:
echo.
echo   Frontend:  %FRONTEND_URL%
echo   Backend:   %BACKEND_URL%
echo   Worker:    (executa en background)
echo.
echo ========================================
echo.

set /p OPEN="Vols obrir el frontend al navegador? (S/N): "
if /i "%OPEN%"=="S" (
    start %FRONTEND_URL%
    echo.
    echo ✅ Navegador obert!
)

echo.
echo Per veure logs:
echo   gcloud run services logs read mobil-scan-frontend --project mobil-scan-app
echo.
pause
