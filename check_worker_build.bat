@echo off
echo ========================================
echo MONITORITZAR BUILD WORKER
echo ========================================
echo.
echo Comprovant estat del build...
echo.

docker images | findstr "mobil_scan-worker"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ WORKER BUILD COMPLETAT!
    echo.
    echo Imatge disponible: urkovitx/mobil_scan-worker:latest
    echo.
    echo Ara pots:
    echo   1. Executar tot: .\run_all_local.bat
    echo   2. Pujar a Docker Hub: docker push urkovitx/mobil_scan-worker:latest
    echo.
) else (
    echo.
    echo ⏳ Build encara en progrés...
    echo.
    echo Per veure el progrés en temps real:
    echo   docker ps -a
    echo.
    echo Temps estimat: 30-40 minuts
    echo.
)

echo ========================================
echo CONTENIDORS ACTIUS:
echo ========================================
docker ps -a

echo.
echo ========================================
echo ÚS DE RECURSOS:
echo ========================================
docker stats --no-stream

pause
