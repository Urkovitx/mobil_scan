@echo off
echo ========================================
echo SETUP GITHUB ACTIONS - PROFESSIONAL BUILD
echo ========================================
echo.

echo [1/5] Verificant Git...
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Git no està instal·lat!
    echo.
    echo Descarrega'l de: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)
echo ✓ Git instal·lat
echo.

echo [2/5] Verificant si és un repo Git...
if not exist ".git" (
    echo ⚠️ No és un repo Git. Inicialitzant...
    git init
    echo ✓ Repo Git inicialitzat
) else (
    echo ✓ Ja és un repo Git
)
echo.

echo [3/5] Verificant fitxers...
if not exist ".github\workflows\docker-build.yml" (
    echo ❌ Workflow file no trobat!
    echo Assegura't que existeix: .github\workflows\docker-build.yml
    pause
    exit /b 1
)
echo ✓ Workflow file trobat
echo.

echo [4/5] Afegint fitxers a Git...
git add .
git status
echo.

echo [5/5] IMPORTANT: Configurar secrets a GitHub
echo ========================================
echo.
echo Abans de fer push, has de configurar els secrets:
echo.
echo 1. Crear token a Docker Hub:
echo    https://hub.docker.com/settings/security
echo    - Click "New Access Token"
echo    - Name: github-actions
echo    - Permissions: Read, Write, Delete
echo    - COPIAR EL TOKEN!
echo.
echo 2. Afegir secrets al repo GitHub:
echo    Settings → Secrets and variables → Actions
echo    - DOCKER_USERNAME: urkovitx
echo    - DOCKER_PASSWORD: [EL TOKEN]
echo.
echo ========================================
echo.

set /p ready="Has configurat els secrets? (s/n): "
if /i "%ready%"=="s" (
    echo.
    echo Fent commit...
    git commit -m "Add GitHub Actions for professional Docker builds"
    echo.
    echo ========================================
    echo PUSH A GITHUB
    echo ========================================
    echo.
    echo Si el repo ja existeix a GitHub:
    echo   git push
    echo.
    echo Si és un repo nou:
    echo   git remote add origin https://github.com/urkovitx/mobil_scan.git
    echo   git branch -M main
    echo   git push -u origin main
    echo.
    echo Després:
    echo   1. Anar a: https://github.com/urkovitx/mobil_scan/actions
    echo   2. Veure el build en temps real
    echo   3. Esperar 15-20 minuts
    echo   4. Les imatges estaran a Docker Hub!
    echo.
    echo ========================================
) else (
    echo.
    echo ⚠️ Configura els secrets primer!
    echo.
    echo Segueix les instruccions a: GITHUB_ACTIONS_SETUP.md
    echo.
)

pause
