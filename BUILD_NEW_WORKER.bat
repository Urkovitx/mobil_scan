@echo off
echo ========================================
echo BUILD NEW WORKER - YOLOv8 + zxing-cpp
echo ========================================
echo.

echo IMPORTANT: Make sure you have placed your trained model at:
echo   worker/models/best_barcode_model.pt
echo.
echo If you don't have the model yet, the worker will use default yolov8n.pt
echo.
pause

echo.
echo 1. Building worker image...
docker build -t urkovitx/mobil-scan-worker:latest -f worker/Dockerfile .

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo.
echo ✅ Build successful!
echo.
echo 2. Pushing to Docker Hub...
docker push urkovitx/mobil-scan-worker:latest

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Push failed! Make sure you're logged in to Docker Hub:
    echo    docker login
    pause
    exit /b 1
)

echo.
echo ✅ Push successful!
echo.
echo 3. Restarting worker container...
docker-compose -f docker-compose.hub.yml pull worker
docker-compose -f docker-compose.hub.yml up -d worker

echo.
echo ========================================
echo ✅ WORKER UPDATED SUCCESSFULLY!
echo ========================================
echo.
echo Check logs with:
echo   docker logs mobilscan-worker
echo.
echo You should see:
echo   ✅ YOLOv8 model loaded from: /app/models/best_barcode_model.pt
echo   ✅ Supervision annotators initialized
echo   📦 YOLO available: True
echo   📦 zxing-cpp available: True
echo.
pause
