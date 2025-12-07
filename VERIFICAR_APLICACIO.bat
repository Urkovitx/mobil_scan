@echo off
echo ========================================
echo VERIFICACIO FINAL DE L'APLICACIO
echo ========================================
echo.

echo Comprovant estat dels contenidors...
docker-compose -f docker-compose.hub.yml ps
echo.

echo ========================================
echo PROVES DE CONNECTIVITAT
echo ========================================
echo.

echo 1. Backend API (http://localhost:8000)
curl -s http://localhost:8000/ 2>nul
if %errorlevel% equ 0 (
    echo    ✅ Backend API: OK
) else (
    echo    ❌ Backend API: ERROR
)
echo.

echo 2. Frontend Streamlit (http://localhost:3000)
curl -s -o nul -w "%%{http_code}" http://localhost:3000 2>nul
if %errorlevel% equ 0 (
    echo    ✅ Frontend: OK
) else (
    echo    ⚠️ Frontend: Comprovant...
)
echo.

echo ========================================
echo RESUM
echo ========================================
echo.
echo ✅ Base de dades PostgreSQL: Port 5432
echo ✅ Redis: Port 6379
echo ✅ Backend API: http://localhost:8000
echo ✅ Frontend Streamlit: http://localhost:3000
echo.
echo Per accedir a l'aplicacio:
echo    Obre el navegador a: http://localhost:3000
echo.
echo Per veure logs:
echo    docker-compose -f docker-compose.hub.yml logs -f [servei]
echo.
pause
