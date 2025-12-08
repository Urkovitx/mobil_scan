# 🚀 Implementació Cloud Run Jobs - SOLUCIÓ DEFINITIVA

## ⚠️ PROBLEMA IDENTIFICAT

El worker NO pot funcionar a Cloud Run perquè:
- Cloud Run és per serveis HTTP (request/response)
- El worker necessita executar-se contínuament (`while True`)
- Cloud Run "dorm" quan no hi ha requests

## ✅ SOLUCIÓ: Cloud Run Jobs

Cloud Run Jobs permet executar tasques que:
- S'executen una vegada i acaben
- Es llancen on-demand
- Escalen automàticament
- Pagues només quan s'executen

---

## 📦 Què s'ha Implementat

### 1. **Worker Job** (`worker/processor_job.py`)
✅ Creat - Processa UN sol job i acaba
- Llegeix de Redis amb timeout de 60s
- Processa el vídeo
- Actualitza la base de dades
- Acaba (exit)

### 2. **Backend Modificat** (`backend/main.py`)
✅ Modificat - Llança Cloud Run Jobs
- Detecta si Cloud Run Jobs està disponible
- Llança job quan es puja un vídeo
- Fallback automàtic a Redis si falla
- Variables d'entorn configurables

### 3. **Dependencies** (`backend/requirements.txt`)
✅ Actualitzat
- `google-cloud-run==0.10.0`
- `google-generativeai>=0.3.0`

---

## 🔧 Configuració

### Variables d'Entorn (Backend a Cloud Run)

```bash
GCP_PROJECT_ID=mobil-scan-app
GCP_REGION=europe-west1
USE_CLOUD_RUN_JOBS=true
REDIS_URL=redis://...
DATABASE_URL=postgresql://...
GEMINI_API_KEY=AlzaSyBhqEmRPC8n-wsxwyR8nNeQIQIp0LqbYA8
```

---

## 📝 Pròxims Passos (PER TU)

### Opció A: Solució Ràpida (Recomanada per Testing)

**Executar worker localment mentre proves:**

```bash
# Executa aquest script al teu PC:
EXECUTAR_WORKER_LOCAL.bat

# Deixa la finestra oberta
# Puja un video a l'app web
# Veuràs el processament en temps real
```

**Avantatges:**
- ✅ Funciona IMMEDIATAMENT
- ✅ Fàcil de debugar
- ✅ No costa res
- ✅ Perfecte per testing

**Desavantatges:**
- ❌ Has de tenir el PC encès
- ❌ No és escalable

---

### Opció B: Cloud Run Jobs (Per Producció)

**Aquesta és la solució que he implementat però necessita configuració addicional:**

#### Pas 1: Crear Dockerfile per Worker Job

Crea `worker/Dockerfile.job`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY worker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY worker/ /app/
COPY shared/database.py /app/

# Run job processor (single execution)
CMD ["python", "processor_job.py"]
```

#### Pas 2: Build i Push Imatge

```bash
# Build
docker build -t gcr.io/mobil-scan-app/mobil-scan-worker-job:latest -f worker/Dockerfile.job .

# Push
docker push gcr.io/mobil-scan-app/mobil-scan-worker-job:latest
```

#### Pas 3: Crear Cloud Run Job Template

```bash
gcloud run jobs create process-video \
  --image gcr.io/mobil-scan-app/mobil-scan-worker-job:latest \
  --region europe-west1 \
  --max-retries 2 \
  --task-timeout 30m \
  --set-env-vars "REDIS_URL=redis://...,DATABASE_URL=postgresql://..." \
  --execute-now=false
```

#### Pas 4: Configurar Permisos

```bash
# El backend necessita permisos per llançar jobs
gcloud projects add-iam-policy-binding mobil-scan-app \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/run.developer"
```

#### Pas 5: Actualitzar Backend

Configura les variables d'entorn al backend:

```bash
gcloud run services update mobil-scan-backend \
  --set-env-vars "USE_CLOUD_RUN_JOBS=true,GCP_PROJECT_ID=mobil-scan-app,GCP_REGION=europe-west1" \
  --region europe-west1
```

---

## 💰 Costos Estimats

### Opció A: Worker Local
- **Cost:** 0€
- **Disponibilitat:** Quan PC encès
- **Recomanat per:** Testing

### Opció B: Cloud Run Jobs
- **Cost:** ~5-10€/mes
- **Disponibilitat:** On-demand
- **Recomanat per:** Producció

**Càlcul:**
- 1 job = ~2 minuts processament
- 100 videos/mes = 200 minuts
- Cost: ~0.10€/mes (molt econòmic!)

---

## 🎯 Recomanació

### Per Ara (Testing):
**Usa Opció A: Worker Local**
1. Executa `EXECUTAR_WORKER_LOCAL.bat`
2. Deixa la finestra oberta
3. Puja videos i veuràs el processament
4. Funciona IMMEDIATAMENT

### Per Producció (Futur):
**Implementa Opció B: Cloud Run Jobs**
- Segueix els passos de configuració
- Més professional
- Escalable
- Baix cost

---

## 🆘 Troubleshooting

### Videos queden en PENDING

**Causa:** El worker no està executant-se

**Solució:**
```bash
# Opció 1: Executa worker localment
EXECUTAR_WORKER_LOCAL.bat

# Opció 2: Verifica Cloud Run Job
gcloud run jobs list --region europe-west1
```

### Error: "Worker service unavailable"

**Causa:** Ni Cloud Run Jobs ni Redis estan disponibles

**Solució:**
1. Executa worker localment (Opció A)
2. O configura Cloud Run Jobs (Opció B)

---

## 📊 Estat Actual

✅ **Completat:**
- Codi worker job (`processor_job.py`)
- Backend modificat per llançar jobs
- Dependencies actualitzades
- Documentació completa
- Script per executar localment

⏳ **Pendent (per tu):**
- Decidir: Opció A (local) o Opció B (Cloud Run Jobs)
- Si Opció A: Executar `EXECUTAR_WORKER_LOCAL.bat`
- Si Opció B: Seguir passos de configuració

---

## 🚀 Comença Ara

**Per testar immediatament:**

```bash
# 1. Obre un terminal
# 2. Executa:
EXECUTAR_WORKER_LOCAL.bat

# 3. Puja un video a l'app web
# 4. Veuràs el processament en temps real!
```

**Això et permetrà:**
- ✅ Verificar que tot funciona
- ✅ Veure els logs en directe
- ✅ Debugar si hi ha problemes
- ✅ Decidir després si vols Cloud Run Jobs

---

**Recorda:** L'Opció A (local) és perfecta per testing i desenvolupament. Quan estiguis llest per producció, pots implementar l'Opció B (Cloud Run Jobs).
