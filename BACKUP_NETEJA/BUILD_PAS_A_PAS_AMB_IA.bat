@echo off
echo ========================================
echo BUILD PAS A PAS - Mes Fiable
echo ========================================
echo.
echo Aquest script compila un servei cada vegada
echo per evitar errors de memoria/IO de Docker.
echo.
echo Temps estimat: 30-40 minuts
echo ========================================
echo.
pause

echo.
echo [PREPARACIO] Netejant Docker...
docker system prune -af
if errorlevel 1 (
    echo.
    echo [ERROR] No s'ha pogut netejar Docker
    echo Assegura't que Docker Desktop esta actiu
    pause
    exit /b 1
)

echo.
echo [PREPARACIO] Aturant contenidors...
docker-compose -f docker-compose.llm.yml down

echo.
echo ========================================
echo PAS 1/3: Compilant WORKER
echo ========================================
echo.
echo Temps estimat: 10-15 minuts
echo.
docker-compose -f docker-compose.llm.yml build --no-cache worker

if errorlevel 1 (
    echo.
    echo ========================================
    echo [ERROR] Worker ha fallat!
    echo ========================================
    echo.
    echo Possibles solucions:
    echo 1. Reinicia Docker Desktop
    echo 2. Executa: docker system prune -af
    echo 3. Torna a executar aquest script
    echo.
    echo Veure: SOLUCIO_ERROR_IO_DOCKER.md
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] Worker compilat correctament!
echo ========================================
echo.
echo Esperant 10 segons abans de continuar...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo PAS 2/3: Compilant FRONTEND
echo ========================================
echo.
echo Temps estimat: 5-8 minuts
echo.
docker-compose -f docker-compose.llm.yml build --no-cache frontend

if errorlevel 1 (
    echo.
    echo ========================================
    echo [ERROR] Frontend ha fallat!
    echo ========================================
    echo.
    echo El Worker esta OK, pero el Frontend ha fallat.
    echo.
    echo Possibles solucions:
    echo 1. Reinicia Docker Desktop
    echo 2. Executa: docker system prune -af
    echo 3. Torna a executar aquest script
    echo.
    echo Veure: SOLUCIO_ERROR_IO_DOCKER.md
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] Frontend compilat correctament!
echo ========================================
echo.
echo Esperant 10 segons abans de continuar...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo PAS 3/3: Compilant BACKEND
echo ========================================
echo.
echo Temps estimat: 3-5 minuts
echo.
docker-compose -f docker-compose.llm.yml build --no-cache api

if errorlevel 1 (
    echo.
    echo ========================================
    echo [ERROR] Backend ha fallat!
    echo ========================================
    echo.
    echo Worker i Frontend estan OK, pero Backend ha fallat.
    echo.
    echo Possibles solucions:
    echo 1. Reinicia Docker Desktop
    echo 2. Executa: docker system prune -af
    echo 3. Torna a executar aquest script
    echo.
    echo Veure: SOLUCIO_ERROR_IO_DOCKER.md
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo [OK] Backend compilat correctament!
echo ========================================
echo.

echo.
echo ========================================
echo INICIANT TOTS ELS SERVEIS
echo ========================================
echo.
docker-compose -f docker-compose.llm.yml up -d

if errorlevel 1 (
    echo.
    echo [ERROR] No s'han pogut iniciar els serveis
    pause
    exit /b 1
)

echo.
echo Esperant que els serveis estiguin llestos...
timeout /t 20 /nobreak >nul

echo.
echo ========================================
echo VERIFICANT ESTAT
echo ========================================
echo.
docker-compose -f docker-compose.llm.yml ps

echo.
echo ========================================
echo BUILD COMPLETAT AMB EXIT!
echo ========================================
echo.
echo Tots els serveis compilats i iniciats:
echo  - Worker (amb preprocessament + zxing-cpp v2.2.0)
echo  - Frontend (amb pestanya AI Analysis)
echo  - Backend (API FastAPI)
echo  - LLM (Ollama)
echo  - Database (PostgreSQL)
echo  - Redis
echo.
echo ========================================
echo IMPORTANT: Descarrega el model Phi-3
echo ========================================
echo.
echo Executa aquesta comanda ARA:
echo.
echo   docker exec mobil_scan_llm ollama pull phi3
echo.
echo Aixo trigara 10-15 minuts pero nomes cal fer-ho UNA VEGADA.
echo.
echo ========================================
echo ACCEDEIX A L'APLICACIO
echo ========================================
echo.
echo Frontend:  http://localhost:8501
echo Backend:   http://localhost:8000
echo Ollama:    http://localhost:11434
echo.
echo Pestanyes disponibles:
echo  1. Upload Video
echo  2. Audit Dashboard
echo  3. AI Analysis  (NOVA amb Phi-3!)
echo  4. Job History
echo.
echo ========================================
echo.

set /p OPEN="Vols obrir el navegador ara? (S/N): "
if /i "%OPEN%"=="S" (
    start http://localhost:8501
    echo.
    echo Navegador obert!
)

echo.
set /p DOWNLOAD="Vols descarregar el model Phi-3 ara? (S/N): "
if /i "%DOWNLOAD%"=="S" (
    echo.
    echo Descarregant model Phi-3... (10-15 minuts)
    docker exec mobil_scan_llm ollama pull phi3
    echo.
    echo Model Phi-3 descarregat!
)

echo.
pause
