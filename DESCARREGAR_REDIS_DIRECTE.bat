@echo off
echo ========================================
echo DESCARREGAR REDIS DIRECTAMENT
echo ========================================
echo.
echo Aquesta opcio evita Chocolatey i McAfee!
echo.

echo [1/4] Descarregant Redis...
echo.
echo Obrint navegador per descarregar Redis...
echo.
start https://github.com/microsoftarchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.msi

echo.
echo ========================================
echo INSTRUCCIONS
echo ========================================
echo.
echo 1. El navegador s'ha obert amb la descarrega de Redis
echo.
echo 2. Si McAfee el bloqueja:
echo    - Clica "Restaurar" o "Permetre"
echo    - O desactiva McAfee temporalment
echo.
echo 3. Descarrega el fitxer: Redis-x64-3.0.504.msi
echo.
echo 4. Executa el fitxer descarregat
echo.
echo 5. Durant la instal·lacio:
echo    - Clica "Next"
echo    - Accepta la llicencia
echo    - IMPORTANT: Marca "Add Redis to PATH"
echo    - Clica "Install"
echo.
echo 6. Despres de la instal·lacio:
echo    - Obre un terminal nou
echo    - Executa: redis-server
echo.
echo 7. Verifica que funciona (altra terminal):
echo    - Executa: redis-cli ping
echo    - Hauries de veure: PONG
echo.
echo 8. Executa el worker:
echo    - EXECUTAR_WORKER_SENSE_DOCKER.bat
echo.
echo ========================================
echo.
echo Vols veure la guia completa? (S/N)
set /p guia="Resposta: "

if /i "%guia%"=="S" (
    start SOLUCIO_TALLAFOCS_MCAFEE.md
)

echo.
echo ========================================
echo ALTERNATIVA: WSL2
echo ========================================
echo.
echo Si no vols desactivar McAfee, pots usar WSL2:
echo.
echo 1. Obre WSL2 (Ubuntu)
echo    wsl
echo.
echo 2. Instal·la Redis
echo    sudo apt update
echo    sudo apt install redis-server -y
echo.
echo 3. Inicia Redis
echo    sudo service redis-server start
echo.
echo 4. Verifica
echo    redis-cli ping
echo.
echo ========================================
echo.
pause
