@echo off
echo Checking worker status...
echo.

echo === Docker PS ===
docker ps -a | findstr worker
echo.

echo === Worker Logs ===
docker logs mobil_scan_worker > worker_logs.txt 2>&1
type worker_logs.txt
echo.

echo Logs saved to worker_logs.txt
pause
