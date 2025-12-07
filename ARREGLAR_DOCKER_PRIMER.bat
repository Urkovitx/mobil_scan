@echo off
echo ========================================
echo   ARREGLAR DOCKER DESKTOP
echo ========================================
echo.
echo Docker Desktop esta mort (500 error)
echo Cal reiniciar-lo completament
echo.
echo PASSOS:
echo 1. Tanca Docker Desktop (icona barra tasques - Quit)
echo 2. Obre Task Manager (Ctrl+Shift+Esc)
echo 3. Mata aquests processos si existeixen:
echo    - Docker Desktop
echo    - com.docker.backend
echo    - com.docker.service
echo 4. Reobre Docker Desktop
echo 5. Espera que digui "Docker Desktop is running"
echo.
echo Despres torna a executar aquest script
echo.
pause

echo Verificant Docker...
docker ps >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ Docker encara no funciona
    echo    Segueix els passos de dalt
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Docker funciona!
echo.
echo Ara pots executar BUILD_PAS_A_PAS.bat
echo.
pause
