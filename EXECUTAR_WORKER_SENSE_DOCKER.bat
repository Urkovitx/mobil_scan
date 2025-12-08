@echo off
echo ========================================
echo EXECUTAR WORKER SENSE DOCKER
echo ========================================
echo.
echo Aquest script executa el worker al teu PC
echo SENSE necessitar Docker Desktop!
echo.
echo IMPORTANT: Deixa aquesta finestra oberta!
echo.
pause

echo.
echo [1/3] Configurant variables d'entorn...
REM Usa serveis Cloud (NO locals)
set REDIS_URL=redis://localhost:6379/0
set DATABASE_URL=sqlite:///./worker_local.db
set VIDEOS_FOLDER=../shared/videos
set FRAMES_FOLDER=../shared/frames
set RESULTS_FOLDER=../shared/results
set MODEL_PATH=./models/best_barcode_model.pt

echo.
echo [2/3] Instal·lant depend├¿ncies Python...
cd worker

REM Crea entorn virtual si no existeix
if not exist "venv" (
    echo Creant entorn virtual...
    python -m venv venv
)

call venv\Scripts\activate

echo Instal·lant paquets necessaris...
pip install --quiet --upgrade pip
pip install --quiet redis==5.0.1 sqlalchemy==2.0.25 pillow==10.2.0 loguru==0.7.2 opencv-python==4.8.1.78 numpy==1.24.3

echo.
echo [3/3] Creant base de dades local...
python -c "from sqlalchemy import create_engine; engine = create_engine('sqlite:///./worker_local.db'); print('✓ Base de dades creada')"

echo.
echo ========================================
echo WORKER EN EXECUCIÓ (SENSE DOCKER!)
echo ========================================
echo.
echo NOTA: Aquest worker usa SQLite local.
echo Per connectar a serveis Cloud, edita les URLs a dalt.
echo.
echo El worker està escoltant jobs.
echo Per aturar: Prem Ctrl+C
echo.

python processor.py

pause
