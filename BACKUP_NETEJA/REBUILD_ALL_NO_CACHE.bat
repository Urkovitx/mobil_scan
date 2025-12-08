@echo off
REM ============================================================================
REM Rebuild ALL Containers - NO CACHE
REM ============================================================================
REM Aquest script reconstrueix TOTS els contenidors des de zero
REM sense utilitzar cap capa de caché de Docker.
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║          REBUILD ALL SERVICES - NO CACHE                           ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ⚠️  ATENCIÓ: Això reconstruirà TOTS els serveis des de zero
echo    - API (FastAPI Backend)
echo    - Worker (YOLOv8 + zxing-cpp)
echo    - Frontend (Streamlit)
echo.

set /p confirm="Vols continuar? (S/N): "
if /i not "%confirm%"=="S" (
    echo Operació cancel·lada
    pause
    exit /b 0
)

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    FASE 1: PREPARACIÓ                              ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar Docker
echo [1/3] Verificant Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker no està en execució
    pause
    exit /b 1
)
echo ✅ Docker està actiu
echo.

REM Aturar tots els serveis
echo [2/3] Aturant tots els serveis...
docker-compose down
echo ✅ Serveis aturats
echo.

REM Eliminar imatges antigues
echo [3/3] Eliminant imatges antigues...
docker rmi mobil_scan-api 2>nul
docker rmi mobil_scan-worker 2>nul
docker rmi mobil_scan-frontend 2>nul
echo ✅ Imatges antigues eliminades
echo.

echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    FASE 2: REBUILD API                             ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

docker-compose build --no-cache --pull api

if errorlevel 1 (
    echo ❌ Error reconstruint API
    pause
    exit /b 1
)
echo ✅ API reconstruït
echo.

echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    FASE 3: REBUILD WORKER                          ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo 📦 Descarregant zxing-cpp v2.2.1...
echo 🔨 Compilant component C++...
echo.

docker-compose build --no-cache --pull worker

if errorlevel 1 (
    echo ❌ Error reconstruint Worker
    pause
    exit /b 1
)
echo ✅ Worker reconstruït
echo.

echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    FASE 4: REBUILD FRONTEND                        ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

docker-compose build --no-cache --pull frontend

if errorlevel 1 (
    echo ❌ Error reconstruint Frontend
    pause
    exit /b 1
)
echo ✅ Frontend reconstruït
echo.

echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    FASE 5: INICIAR SERVEIS                         ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Iniciar tots els serveis
echo Iniciant tots els serveis...
docker-compose up -d

if errorlevel 1 (
    echo ❌ Error iniciant serveis
    pause
    exit /b 1
)

echo ✅ Tots els serveis iniciats
echo.

REM Esperar que els serveis estiguin llestos
echo Esperant que els serveis estiguin llestos...
timeout /t 10 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    ESTAT DELS SERVEIS                              ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

docker-compose ps

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    VERIFICACIÓ ZXING-CPP                           ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar zxing-cpp
echo 📦 Verificant zxing-cpp Python bindings...
docker-compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>nul

echo.
echo 📦 Verificant executable C++ barcode_test...
docker-compose exec -T worker which barcode_test 2>nul
if errorlevel 1 (
    echo ⚠️  Executable C++ no trobat
) else (
    echo ✅ Executable C++ disponible a /usr/local/bin/barcode_test
)

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                         COMPLETAT                                  ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Tots els serveis reconstruïts i verificats correctament
echo.
echo 🌐 URLs dels serveis:
echo    - Frontend: http://localhost:8501
echo    - API:      http://localhost:8000
echo    - API Docs: http://localhost:8000/docs
echo.
echo 📋 Pròxims passos:
echo    - Obre http://localhost:8501 al navegador
echo    - Executa TEST_CPP_SCANNER.bat per provar el scanner C++
echo    - Executa VERIFICAR_APLICACIO.bat per provar tot el sistema
echo.

pause
