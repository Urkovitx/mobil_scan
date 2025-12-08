@echo off
echo ========================================
echo GIT PUSH - WORKER TEST FILES
echo ========================================
echo.

echo [1/4] Afegint fitxers nous...
git add worker/requirements-worker-test.txt
git add .github/workflows/build-worker-test.yml
echo ✅ Fitxers afegits
echo.

echo [2/4] Eliminant fitxer incorrecte...
git rm .github/workflows/Dockerfile.test.yml 2>nul
echo ✅ Fitxer eliminat
echo.

echo [3/4] Fent commit...
git commit -m "Add worker test build: requirements + workflow fix"
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️ No hi ha canvis per fer commit (potser ja està fet)
)
echo.

echo [4/4] Fent push a GitHub...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ ERROR: Push fallit
    echo.
    echo Possibles causes:
    echo 1. No tens permisos (verifica token/SSH)
    echo 2. La branca es diu 'master' no 'main'
    echo 3. Necessites fer pull primer
    echo.
    echo Prova manualment:
    echo   git push origin master
    echo   o
    echo   git pull origin main
    echo   git push origin main
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ PUSH COMPLETAT!
echo ========================================
echo.
echo Ara pots anar a GitHub i executar el workflow:
echo https://github.com/Urkovitx/mobil_scan/actions/workflows/build-worker-test.yml
echo.
echo Fes clic a "Run workflow" per començar el build!
echo.
pause
