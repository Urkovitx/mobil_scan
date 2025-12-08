@echo off
echo ========================================
echo   MOBILE SCANNER + LLM (Ollama + Phi-3)
echo ========================================
echo.

echo [Pas 1/6] Verificant Docker Desktop...
docker ps >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ Docker Desktop no funciona!
    echo.
    echo SOLUCIO:
    echo 1. Tanca Docker Desktop (icona - Quit)
    echo 2. Obre Task Manager (Ctrl+Shift+Esc)
    echo 3. Mata processos Docker
    echo 4. Reobre Docker Desktop
    echo 5. Espera "Docker Desktop is running"
    echo 6. Torna a executar aquest script
    echo.
    pause
    exit /b 1
)
echo ✅ Docker funciona!
echo.

echo [Pas 2/6] Aturant serveis antics...
docker-compose down >nul 2>&1
docker-compose -f docker-compose.llm.yml down >nul 2>&1
echo ✅ Serveis aturats
echo.

echo [Pas 3/6] Iniciant serveis base (Redis + PostgreSQL)...
docker-compose -f docker-compose.llm.yml up -d redis db
timeout /t 10 /nobreak >nul
echo ✅ Serveis base iniciats
echo.

echo [Pas 4/6] Iniciant Ollama LLM...
echo (Això pot trigar 2-3 minuts la primera vegada)
docker-compose -f docker-compose.llm.yml up -d llm
timeout /t 30 /nobreak >nul
echo ✅ Ollama iniciat
echo.

echo [Pas 5/6] Descarregant model Phi-3...
echo (Primera vegada: 5-10 minuts per descarregar 2.3GB)
echo (Següents vegades: instantani, ja està descarregat)
docker-compose -f docker-compose.llm.yml up llm_init
echo ✅ Model Phi-3 llest
echo.

echo [Pas 6/6] Iniciant aplicació (API + Worker + Frontend)...
docker-compose -f docker-compose.llm.yml up -d api worker frontend
timeout /t 10 /nobreak >nul
echo ✅ Aplicació iniciada
echo.

echo ========================================
echo   VERIFICANT ESTAT
echo ========================================
echo.

docker-compose -f docker-compose.llm.yml ps
echo.

echo ========================================
echo   VERIFICANT LLM
echo ========================================
echo.

echo Comprovant si Ollama respon...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Ollama encara no està llest, espera 30 segons més
    timeout /t 30 /nobreak >nul
) else (
    echo ✅ Ollama funcionant!
)
echo.

echo ========================================
echo   VERIFICANT BASE DE DADES
echo ========================================
echo.

echo Comprovant productes...
docker-compose -f docker-compose.llm.yml exec -T db psql -U mobilscan -d mobilscan_db -c "SELECT COUNT(*) as total_products FROM products;" 2>nul
if errorlevel 1 (
    echo ⚠️ Base de dades encara inicialitzant...
) else (
    echo ✅ Base de dades amb productes!
)
echo.

echo ========================================
echo   TOT LLEST!
echo ========================================
echo.
echo 🌐 Aplicació: http://localhost:8501
echo 🔌 API: http://localhost:8000
echo 🧠 Ollama: http://localhost:11434
echo 💾 PostgreSQL: localhost:5432
echo.
echo COMANDES ÚTILS:
echo   Ver logs:     docker-compose -f docker-compose.llm.yml logs -f
echo   Ver worker:   docker-compose -f docker-compose.llm.yml logs -f worker
echo   Ver LLM:      docker-compose -f docker-compose.llm.yml logs -f llm
echo   Aturar:       docker-compose -f docker-compose.llm.yml down
echo   Reiniciar:    docker-compose -f docker-compose.llm.yml restart
echo.
echo TEST RÀPID LLM:
echo   docker-compose -f docker-compose.llm.yml exec worker python /app/llm_client.py
echo.

start http://localhost:8501

pause
