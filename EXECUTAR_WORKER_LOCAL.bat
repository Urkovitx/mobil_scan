@echo off
echo ========================================
echo EXECUTAR WORKER LOCALMENT
echo ========================================
echo.
echo Aquest script executa el worker al teu PC
echo per processar els videos pujats a Cloud Run.
echo.
echo IMPORTANT: Deixa aquesta finestra oberta!
echo.
pause

echo.
echo [1/4] Configurant variables d'entorn...
REM Configuració per entorn LOCAL (Docker local)
set REDIS_URL=redis://localhost:6379/0
set DATABASE_URL=postgresql://mobilscan:mobilscan123@localhost:5432/mobilscan_db
set VIDEOS_FOLDER=../shared/videos
set FRAMES_FOLDER=../shared/frames
set RESULTS_FOLDER=../shared/results
set MODEL_PATH=./models/best_barcode_model.pt

echo.
echo [2/4] Verificant que Docker està executant-se...
docker ps >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Docker no està executant-se!
    echo.
    echo Per favor:
    echo 1. Inicia Docker Desktop
    echo 2. Executa: docker-compose up -d redis db
    echo 3. Torna a executar aquest script
    echo.
    pause
    exit /b 1
)

echo.
echo [3/4] Instal·lant dependències Python...
cd worker
if not exist "venv" (
    echo Creant entorn virtual...
    python -m venv venv
)

call venv\Scripts\activate

echo Instal·lant paquets necessaris...
pip install --quiet redis==5.0.1 sqlalchemy==2.0.25 psycopg2==2.9.9 pillow==10.2.0 loguru==0.7.2 opencv-python==4.8.1.78 numpy==1.24.3

echo.
echo [4/4] Verificant connexió a Redis i PostgreSQL...
python -c "import redis; r = redis.from_url('redis://localhost:6379/0'); r.ping(); print('✓ Redis OK')" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: No es pot connectar a Redis!
    echo.
    echo Executa primer: docker-compose up -d redis db
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo WORKER EN EXECUCIÓ
echo ========================================
echo.
echo El worker està escoltant jobs de Redis.
echo Puja un video a l'aplicació web per veure'l processar.
echo.
echo Per aturar: Prem Ctrl+C
echo.

python processor.py

pause
