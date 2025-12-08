@echo off
echo ========================================
echo EXECUTAR WORKER AMB DYNAMSOFT PRO
echo ========================================
echo.
echo Aquest script executa el worker amb
echo Dynamsoft Barcode Reader (PROFESSIONAL)
echo.
echo IMPORTANT: Deixa aquesta finestra oberta!
echo.
pause

echo.
echo [1/4] Activant entorn Conda...
call C:\Users\ferra\anaconda3\Scripts\activate.bat
call conda activate py313

echo.
echo [2/4] Configurant variables d'entorn...
set REDIS_URL=redis://localhost:6379/0
set DATABASE_URL=sqlite:///./worker_local.db
set VIDEOS_FOLDER=../shared/videos
set FRAMES_FOLDER=../shared/frames
set RESULTS_FOLDER=../shared/results
set MODEL_PATH=./models/best_barcode_model.pt
set DYNAMSOFT_LICENSE=t0087YQEAAAo+62EJwjM/Ii+Bb6cm32Kz/IbSOfahkv3f1xUKOznl1gmVl9l/JhhxzFiQAi0iH9QNJTVsUKnrBdQrUFRfrwPtBzN+NLmbxnszJxU38xXaKEmc

echo.
echo [3/4] Instal·lant Dynamsoft i dependencies...
cd worker
pip install --quiet dynamsoft_barcode_reader_bundle ultralytics supervision opencv-python numpy redis sqlalchemy pillow loguru psycopg2-binary

echo.
echo [4/4] Verificant base de dades...
python -c "from sqlalchemy import create_engine; engine = create_engine('sqlite:///./worker_local.db'); print('Base de dades OK')" 2>nul || echo Base de dades es creara automaticament

echo.
echo ========================================
echo WORKER DYNAMSOFT EN EXECUCIO!
echo ========================================
echo.
echo Entorn: Conda py313
echo Base de dades: SQLite local
echo Redis: localhost:6379
echo Barcode Reader: DYNAMSOFT PROFESSIONAL
echo License: Trial (configurada)
echo.
echo El worker esta escoltant jobs...
echo Per aturar: Prem Ctrl+C
echo.

python processor_dynamsoft.py

pause
