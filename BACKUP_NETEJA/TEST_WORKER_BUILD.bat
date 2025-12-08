@echo off
echo ========================================
echo TESTING WORKER BUILD - YOLOv8 + zxing-cpp
echo ========================================
echo.

echo [1/5] Stopping existing containers...
docker-compose down
echo.

echo [2/5] Building worker image...
docker-compose build worker > build_log.txt 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ BUILD FAILED! Check build_log.txt
    type build_log.txt
    exit /b 1
)
echo ✅ Build completed successfully
echo.

echo [3/5] Checking if image was created...
docker images mobil_scan-worker
echo.

echo [4/5] Starting services...
docker-compose up -d
echo.

echo [5/5] Checking worker logs...
timeout /t 5 /nobreak > nul
docker logs mobil_scan_worker
echo.

echo ========================================
echo TEST COMPLETED
echo ========================================
echo.
echo Check build_log.txt for detailed build output
echo Check worker logs above for runtime status
pause
