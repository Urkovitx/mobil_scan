@echo off
echo ========================================
echo REBUILD COMPLET - Worker + Frontend + IA
echo ========================================
echo.
echo IMPORTANT: Aquest script utilitza docker-compose.llm.yml
echo que inclou el servei Ollama per a la IA.
echo.

echo [1/6] Aturant contenidors...
docker-compose -f docker-compose.llm.yml down

echo.
echo [2/6] Netejant imatges antigues...
docker image prune -f

echo.
echo [3/6] Rebuild Worker (amb millores preprocessament)...
docker-compose -f docker-compose.llm.yml build --no-cache worker

echo.
echo [4/6] Rebuild Frontend (amb pestanya IA)...
docker-compose -f docker-compose.llm.yml build --no-cache frontend

echo.
echo [5/6] Iniciant tots els serveis (inclou Ollama)...
docker-compose -f docker-compose.llm.yml up -d

echo.
echo [6/6] Verificant estat...
timeout /t 15 /nobreak >nul
docker-compose -f docker-compose.llm.yml ps

echo.
echo ========================================
echo REBUILD COMPLETAT!
echo ========================================
echo.
echo Millores aplicades:
echo  - Worker: Preprocessament avancat (6 tecniques)
echo  - Worker: Confidence combinada (YOLO + decode)
echo  - Frontend: Pestanya AI Analysis amb Phi-3
echo  - LLM: Servei Ollama actiu
echo.
echo IMPORTANT: Descarrega el model Phi-3 ara:
echo   docker exec mobil_scan_llm ollama pull phi3
echo.
echo Accedeix a: http://localhost:8501
echo.
echo Pestanyes disponibles:
echo  1. Upload Video
echo  2. Audit Dashboard
echo  3. AI Analysis  (NOVA amb Phi-3!)
echo  4. Job History
echo.
echo Serveis actius:
echo  - Frontend:  http://localhost:8501
echo  - Backend:   http://localhost:8000
echo  - Ollama:    http://localhost:11434
echo  - Database:  localhost:5432
echo  - Redis:     localhost:6379
echo.
pause
