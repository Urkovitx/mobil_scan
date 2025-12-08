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
echo [1/3] Configurant variables d'entorn...
set REDIS_URL=redis://redis-xxxxx.cloud.google.com:6379/0
set DATABASE_URL=postgresql://mobilscan:mobilscan123@db-xxxxx.cloud.google.com:5432/mobilscan_db
set VIDEOS_FOLDER=./shared/videos
set FRAMES_FOLDER=./shared/frames
set RESULTS_FOLDER=./shared/results
set MODEL_PATH=./worker/models/best_barcode_model.pt

echo.
echo [2/3] Activant entorn Python...
cd worker
python -m venv venv
call venv\Scripts\activate

echo.
echo [3/3] Instal·lant dependències...
pip install -r requirements.txt

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
