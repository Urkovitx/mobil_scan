@echo off
chcp 65001 >nul
echo ========================================
echo 🌐 OBTENIR URL DE L'APLICACIÓ
echo ========================================
echo.

echo Consultant serveis a Google Cloud Run...
echo.

gcloud run services list --project=mobil-scan-app

echo.
echo ========================================
echo.

REM Obtenir URLs específiques
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-frontend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set FRONTEND_URL=%%i
for /f "tokens=*" %%i in ('gcloud run services describe mobil-scan-backend --region europe-west1 --format="value(status.url)" --project mobil-scan-app 2^>nul') do set BACKEND_URL=%%i

if "%FRONTEND_URL%"=="" (
    echo ❌ Frontend no desplegat encara
    echo.
    echo Executa primer: DESPLEGAR_SERVEIS_ARA.bat
    echo.
    pause
    exit /b 1
)

echo ✅ URLs dels serveis:
echo.
echo   📱 Frontend (obre aquesta):
echo   %FRONTEND_URL%
echo.
echo   🔧 Backend (API):
echo   %BACKEND_URL%
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
echo Per compartir al mòbil:
echo   1. Copia la URL del frontend
echo   2. Envia-la per WhatsApp/email
echo   3. Obre-la al navegador del mòbil
echo.
pause
