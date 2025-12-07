@echo off
echo ========================================
echo CHECKING MOBIL_SCAN STATUS NOW
echo ========================================
echo.

echo 1. Checking containers...
echo.
docker ps -a --filter "name=mobil"
echo.

echo 2. Checking images...
echo.
docker images | findstr mobil
echo.

echo 3. Checking if build is running...
echo.
docker ps --filter "status=created"
echo.

echo 4. Quick status check...
echo.
cd mobil_scan
docker-compose ps
echo.

echo ========================================
echo DONE
echo ========================================
pause
