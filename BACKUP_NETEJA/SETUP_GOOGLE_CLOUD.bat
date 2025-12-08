@echo off
echo ========================================
echo CONFIGURACIO GOOGLE CLOUD RUN
echo ========================================
echo.
echo Estat actual:
echo   Compte: ferranpalacin@gmail.com
echo   Projecte: mobil-scan-app
echo.
echo ========================================
echo PAS 1: ACTIVAR FACTURACIO
echo ========================================
echo.
echo Google Cloud necessita una targeta per verificacio,
echo pero tens 300$ GRATIS per començar.
echo.
echo 1. Obre: https://console.cloud.google.com/billing
echo 2. Clica "Link a billing account"
echo 3. Selecciona el projecte "mobil-scan-app"
echo 4. Afegeix targeta (no et cobraran res)
echo.
echo Prem qualsevol tecla quan hagis acabat...
pause
echo.

echo ========================================
echo PAS 2: ACTIVAR APIS
echo ========================================
echo.
echo Activant Cloud Run, Cloud Build i Container Registry...
echo.

gcloud services enable run.googleapis.com cloudbuild.googleapis.com containerregistry.googleapis.com artifactregistry.googleapis.com --project=mobil-scan-app

if errorlevel 1 (
    echo.
    echo [ERROR] No s'han pogut activar les APIs
    echo.
    echo Verifica que has activat la facturacio a:
    echo https://console.cloud.google.com/billing
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] APIs activades correctament!
echo.

echo ========================================
echo PAS 3: CONFIGURAR REGIO
echo ========================================
echo.
echo Configurant regio a Europa (europe-west1)...
echo.

gcloud config set run/region europe-west1
gcloud config set compute/region europe-west1

echo.
echo [OK] Regio configurada!
echo.

echo ========================================
echo PAS 4: VERIFICAR CONFIGURACIO
echo ========================================
echo.

echo Projecte actual:
gcloud config get-value project

echo.
echo Regio actual:
gcloud config get-value run/region

echo.
echo Compte actiu:
gcloud config get-value account

echo.
echo ========================================
echo CONFIGURACIO COMPLETADA!
echo ========================================
echo.
echo Ara pots executar:
echo   deploy_cloud_run.bat
echo.
echo Per compilar i desplegar l'aplicacio al nuvol.
echo.
pause
