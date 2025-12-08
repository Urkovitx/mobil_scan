@echo off
echo ========================================
echo CONFIGURAR CI/CD: GitHub + Google Cloud
echo ========================================
echo.

echo Aquest script configurara:
echo 1. Connexio GitHub amb Cloud Build
echo 2. Trigger automatic per cada push
echo 3. Secrets (API Keys) a Google Cloud
echo 4. Permisos necessaris
echo.

pause

echo.
echo [1/4] Creant secret per Gemini API Key...
echo AlzaSyBhqEmRPC8n-wsxwyR8nNeQIQIp0LqbYA8 | gcloud secrets create GEMINI_API_KEY --data-file=- --project mobil-scan-app 2>nul
if errorlevel 1 (
    echo Secret ja existeix, actualitzant...
    echo AlzaSyBhqEmRPC8n-wsxwyR8nNeQIQIp0LqbYA8 | gcloud secrets versions add GEMINI_API_KEY --data-file=- --project mobil-scan-app
)

echo.
echo [2/4] Configurant permisos Cloud Build...
gcloud projects add-iam-policy-binding mobil-scan-app --member="serviceAccount:$(gcloud projects describe mobil-scan-app --format='value(projectNumber)')@cloudbuild.gserviceaccount.com" --role="roles/run.admin" --quiet

echo.
echo [3/4] Donant acces als secrets...
for /f "tokens=*" %%i in ('gcloud projects describe mobil-scan-app --format^="value(projectNumber)"') do set PROJECT_NUMBER=%%i
gcloud secrets add-iam-policy-binding GEMINI_API_KEY --member="serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com" --role="roles/secretmanager.secretAccessor" --project mobil-scan-app --quiet

echo.
echo [4/4] Instruccions finals...
echo.
echo ========================================
echo CONFIGURACIO COMPLETADA!
echo ========================================
echo.
echo Ara has de fer manualment (a la consola web):
echo.
echo 1. Ves a: https://console.cloud.google.com/cloud-build/triggers
echo 2. Clica "Connect Repository"
echo 3. Selecciona "GitHub"
echo 4. Autoritza Google Cloud
echo 5. Selecciona el teu repositori
echo 6. Clica "Create Trigger"
echo    - Nom: deploy-on-push
echo    - Event: Push to branch
echo    - Branch: ^master$
echo    - Configuration: cloudbuild.yaml
echo 7. Clica "Create"
echo.
echo Despres, cada 'git push' desplegara automaticament!
echo.
pause
