@echo off
echo ========================================
echo TESTING WORKER BUILD
echo ========================================
echo.

echo Building worker image...
docker build -t mobil-scan-worker-test:latest -f worker/Dockerfile . > build_output.txt 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build FAILED!
    echo Check build_output.txt for details
    type build_output.txt
    pause
    exit /b 1
)

echo.
echo ✅ Build SUCCESSFUL!
echo.

echo Checking image size...
docker images mobil-scan-worker-test:latest

echo.
echo Testing container startup...
docker run --rm mobil-scan-worker-test:latest python -c "import ultralytics; import supervision; import zxingcpp; print('✅ All imports successful')"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Import test FAILED!
    pause
    exit /b 1
)

echo.
echo ✅ All tests PASSED!
pause
