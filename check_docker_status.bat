@echo off
echo ========================================
echo CHECKING MOBIL_SCAN DOCKER STATUS
echo ========================================
echo.

echo 1. Checking if containers exist...
echo.
docker ps -a --filter "name=mobil" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.

echo 2. Checking if images exist...
echo.
docker images --filter "reference=mobil*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo.

echo 3. Checking docker-compose status...
echo.
cd /d "%~dp0"
docker-compose ps
echo.

echo 4. Checking for build errors...
echo.
docker-compose logs --tail=20
echo.

echo ========================================
echo DIAGNOSIS
echo ========================================
echo.
echo If you see NO containers above, it means:
echo - Build is still in progress, OR
echo - Build failed, OR
echo - Containers were never created
echo.
echo To fix:
echo 1. Run: docker-compose up -d --build
echo 2. Wait 5-10 minutes for build
echo 3. Check Docker Desktop again
echo.
pause
