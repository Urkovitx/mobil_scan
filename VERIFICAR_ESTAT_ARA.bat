@echo off
echo ========================================
echo   VERIFICACIO ESTAT ACTUAL
echo ========================================
echo.

echo [1] Contenidors en execucio:
docker ps
echo.

echo [2] Tots els contenidors (inclosos aturats):
docker ps -a
echo.

echo [3] Imatges creades:
docker images | findstr mobil
echo.

echo [4] Processos Docker:
docker stats --no-stream
echo.

echo ========================================
echo   ANALISI
echo ========================================
echo.

echo Si veus contenidors amb STATUS "Up", tot funciona!
echo Si veus "Exited" o "Restarting", hi ha un problema.
echo.

pause
