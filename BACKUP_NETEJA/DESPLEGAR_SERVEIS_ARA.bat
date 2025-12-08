@echo off
echo ========================================
echo DESPLEGAR SERVEIS A CLOUD RUN
echo ========================================
echo.
echo Aquest script desplega els 3 serveis
echo utilitzant les imatges ja compilades.
echo.
pause

echo ========================================
echo PAS 1/3: DESPLEGANT BACKEND
echo ========================================
echo.

gcloud run deploy mobil-scan-backend ^
  --image gcr.io/mobil-scan-app/mobil-scan-backend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 2Gi ^
  --cpu 2 ^
  --port 8000 ^
  --max-instances 10 ^
  --min-instances 0 ^
  --project mobil-scan-app

if errorlevel 1 (
    echo [ERROR] Deploy del backend ha fallat!
    pause
    exit /b 1
)

echo.
echo [OK] Backend desplegat!
echo.

REM Obtenir URL del backend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set BACKEND_URL=%%i

echo Backend URL: %BACKEND_URL%
echo.

echo ========================================
echo PAS 2/3: DESPLEGANT FRONTEND
echo ========================================
echo.

gcloud run deploy mobil-scan-frontend ^
  --image gcr.io/mobil-scan-app/mobil-scan-frontend:latest ^
  --platform managed ^
  --region europe-west1 ^
  --allow-unauthenticated ^
  --memory 1Gi ^
  --cpu 1 ^
  --port 8501 ^
  --max-instances 10 ^
  --min-instances 0 ^
  --set-env-vars "API_URL=%BACKEND_URL%" ^
  --project mobil-scan-app

if errorlevel 1 (
    echo [ERROR] Deploy del frontend ha fallat!
    pause
    exit /b 1
)

echo.
echo [OK] Frontend desplegat!
echo.

REM Obtenir URL del frontend
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-frontend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set FRONTEND_URL=%%i

echo Frontend URL: %FRONTEND_URL%
echo.

echo ========================================
echo PAS 3/3: DESPLEGANT WORKER
echo ========================================
echo.

gcloud run deploy mobil-scan-worker ^
  --image gcr.io/mobil-scan-app/mobil-scan-worker:latest ^
  --platform managed ^
  --region europe-west1 ^
  --no-allow-unauthenticated ^
  --memory 4Gi ^
  --cpu 2 ^
  --max-instances 5 ^
  --min-instances 0 ^
  --project mobil-scan-app

if errorlevel 1 (
    echo [ERROR] Deploy del worker ha fallat!
    pause
    exit /b 1
)

echo.
echo [OK] Worker desplegat!
echo.

echo ========================================
echo DEPLOY COMPLETAT AMB EXIT!
echo ========================================
echo.
echo La teva aplicacio esta funcionant a:
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
    echo Navegador obert!
)

echo.
echo Per veure logs:
echo   gcloud run services logs read mobil-scan-frontend --project mobil-scan-app
echo.
echo Per veure serveis:
echo   gcloud run services list --project mobil-scan-app
echo.
pause
