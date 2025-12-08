# 🚀 Guia d'Execució Local - Pas a Pas

## ✅ Prerequisits

1. **Docker Desktop** instal·lat i executant-se
2. **Python 3.9+** instal·lat
3. **Git** instal·lat

---

## 📋 Passos per Executar Localment

### Pas 1: Iniciar Serveis Docker (Redis + PostgreSQL)

```bash
# Obre un terminal a la carpeta del projecte
cd "c:/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"

# Inicia Redis i PostgreSQL
docker-compose up -d redis db

# Verifica que estan executant-se
docker ps
```

**Hauries de veure:**
- `mobil_scan_redis` - Running
- `mobil_scan_db` - Running

---

### Pas 2: Executar el Worker

```bash
# Executa el script
EXECUTAR_WORKER_LOCAL.bat
```

**Què fa aquest script:**
1. ✅ Configura variables d'entorn
2. ✅ Verifica que Docker està executant-se
3. ✅ Crea un entorn virtual Python
4. ✅ Instal·la dependències necessàries
5. ✅ Verifica connexió a Redis
6. ✅ Inicia el worker

**IMPORTANT:** Deixa aquesta finestra oberta! El worker ha d'estar sempre executant-se.

---

### Pas 3: Executar Backend (API)

**Obre un SEGON terminal:**

```bash
cd "c:/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan/backend"

# Crea entorn virtual (si no existeix)
python -m venv venv
call venv\Scripts\activate

# Instal·la dependències
pip install -r requirements.txt

# Configura variables d'entorn
set REDIS_URL=redis://localhost:6379/0
set DATABASE_URL=postgresql://mobilscan:mobilscan123@localhost:5432/mobilscan_db
set GEMINI_API_KEY=your_gemini_api_key_here

# Executa el backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

**Backend disponible a:** http://localhost:8000

---

### Pas 4: Executar Frontend (Streamlit)

**Obre un TERCER terminal:**

```bash
cd "c:/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan/frontend"

# Crea entorn virtual (si no existeix)
python -m venv venv
call venv\Scripts\activate

# Instal·la dependències
pip install -r requirements.txt

# Configura variable d'entorn
set API_URL=http://localhost:8000

# Executa el frontend
streamlit run app.py
```

**Frontend disponible a:** http://localhost:8501

---

## 🎯 Verificació

### 1. Verifica que tot està executant-se:

**Terminal 1:** Worker escoltant Redis
```
========================================
WORKER EN EXECUCIÓ
========================================

El worker està escoltant jobs de Redis.
```

**Terminal 2:** Backend API
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

**Terminal 3:** Frontend Streamlit
```
You can now view your Streamlit app in your browser.
Local URL: http://localhost:8501
```

### 2. Prova l'aplicació:

1. Obre el navegador: http://localhost:8501
2. Puja un video
3. Veuràs el processament en temps real al Terminal 1 (Worker)
4. Els resultats apareixeran a la interfície web

---

## 🛑 Aturar Tot

### Opció 1: Aturar individualment

1. **Worker:** Prem `Ctrl+C` al Terminal 1
2. **Backend:** Prem `Ctrl+C` al Terminal 2
3. **Frontend:** Prem `Ctrl+C` al Terminal 3
4. **Docker:** `docker-compose down`

### Opció 2: Aturar tot d'un cop

```bash
# Atura tots els contenidors Docker
docker-compose down

# Mata tots els processos Python (opcional)
taskkill /F /IM python.exe
```

---

## 🆘 Troubleshooting

### Error: "Docker no està executant-se"

**Solució:**
1. Obre Docker Desktop
2. Espera que estigui completament iniciat
3. Torna a executar el script

### Error: "No es pot connectar a Redis"

**Solució:**
```bash
# Verifica que Redis està executant-se
docker ps | findstr redis

# Si no està, inicia'l
docker-compose up -d redis
```

### Error: "ModuleNotFoundError: No module named 'redis'"

**Solució:**
```bash
# Assegura't que estàs a l'entorn virtual
cd worker
call venv\Scripts\activate

# Instal·la les dependències
pip install redis sqlalchemy psycopg2 pillow loguru opencv-python numpy
```

### Error: "Port 8000 already in use"

**Solució:**
```bash
# Troba el procés que usa el port
netstat -ano | findstr :8000

# Mata el procés (substitueix PID pel número que apareix)
taskkill /F /PID <PID>
```

---

## 📊 Arquitectura Local

```
┌─────────────────────────────────────────────┐
│         NAVEGADOR (http://localhost:8501)   │
│                                             │
│              Frontend (Streamlit)           │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         Backend API (FastAPI)               │
│         http://localhost:8000               │
│                                             │
│  - Gestiona uploads                         │
│  - Crea jobs a Redis                        │
│  - Consulta resultats de DB                 │
│  - Endpoint IA (Gemini)                     │
└─────────┬───────────────┬───────────────────┘
          │               │
          ▼               ▼
┌─────────────────┐  ┌──────────────────────┐
│  Redis          │  │  PostgreSQL          │
│  (localhost)    │  │  (localhost)         │
│                 │  │                      │
│  - Cua de jobs  │  │  - Videos            │
│                 │  │  - Deteccions        │
└────────┬────────┘  │  - Resultats         │
         │           └──────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│         Worker (Python)                     │
│                                             │
│  - Escolta Redis                            │
│  - Processa videos                          │
│  - Detecta codis                            │
│  - Guarda resultats a DB                    │
└─────────────────────────────────────────────┘
```

---

## ✅ Checklist Ràpid

- [ ] Docker Desktop executant-se
- [ ] `docker-compose up -d redis db` executat
- [ ] Terminal 1: Worker executant-se
- [ ] Terminal 2: Backend executant-se
- [ ] Terminal 3: Frontend executant-se
- [ ] Navegador obert a http://localhost:8501
- [ ] Video pujat i processant-se

**Si tots els punts estan marcats, l'aplicació està funcionant correctament! 🎉**

---

## 🚀 Pròxim Pas: Producció

Quan estiguis llest per desplegar a producció:
1. Llegeix `IMPLEMENTACIO_CLOUD_RUN_JOBS.md`
2. Configura Cloud Run Jobs
3. Desplega amb `ACTUALITZAR_APLICACIO.bat`

**Cost producció:** ~5-10€/mes amb Google Cloud Run
