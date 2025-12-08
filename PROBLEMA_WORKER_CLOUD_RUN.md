# ⚠️ Problema: Worker No Processa Videos a Cloud Run

## 🔍 Diagnòstic

### Símptoma
- Videos pujats queden en estat "PENDING"
- No es processen mai
- 0 deteccions
- Total Jobs: 5, Completed: 0

### Causa Arrel
**Cloud Run NO és adequat per al worker** perquè:

1. ✅ **Cloud Run és per serveis HTTP** (request → response)
2. ❌ **El worker necessita executar-se contínuament** (`while True` escoltant Redis)
3. ❌ **Cloud Run "dorm" quan no hi ha requests** (escala a 0)
4. ❌ **El worker mai rep "requests HTTP"**, només escolta Redis

### Arquitectura Actual (INCORRECTA)
```
Frontend (Cloud Run) ✅
    ↓ HTTP
Backend (Cloud Run) ✅
    ↓ Redis Queue
Worker (Cloud Run) ❌ ← PROBLEMA: Dorm sempre!
```

---

## ✅ Solucions

### Opció 1: Worker Local (RÀPID - Per Testar)

**Avantatges:**
- ✅ Funciona immediatament
- ✅ Fàcil de debugar
- ✅ No costa res

**Desavantatges:**
- ❌ Has de tenir el PC encès
- ❌ No és escalable
- ❌ No és professional

**Com fer-ho:**
```bash
# 1. Executa aquest script:
EXECUTAR_WORKER_LOCAL.bat

# 2. Deixa la finestra oberta
# 3. Puja un video a l'app web
# 4. Veuràs el processament en temps real
```

**Configuració necessària:**
- Necessites les URLs de Redis i PostgreSQL de Cloud Run
- Pots obtenir-les amb: `gcloud run services describe mobil-scan-backend`

---

### Opció 2: Cloud Run Jobs (RECOMANAT per Cloud)

**Avantatges:**
- ✅ Natiu de Google Cloud
- ✅ Escala automàticament
- ✅ Pagues només quan processa
- ✅ Integració fàcil

**Desavantatges:**
- ⚠️ Necessita modificar el codi del worker
- ⚠️ Latència inicial (cold start)

**Com funciona:**
```
Backend detecta nou video
    ↓
Crea Cloud Run Job
    ↓
Job processa video
    ↓
Job acaba i desapareix
```

**Implementació:**

1. **Modificar `worker/processor.py`:**
```python
# En lloc de while True, processar UN job i acabar
def process_single_job():
    redis_client = redis.from_url(REDIS_URL)
    result = redis_client.brpop("video_queue", timeout=60)
    
    if result:
        queue_name, job_json = result
        job_data = json.loads(job_json)
        process_video(job_data)
    else:
        logger.info("No jobs in queue")

if __name__ == "__main__":
    process_single_job()  # Processa 1 job i acaba
```

2. **Modificar `backend/main.py`:**
```python
from google.cloud import run_v2

@app.post("/api/upload")
async def upload_video(...):
    # ... codi existent ...
    
    # En lloc de Redis, llança Cloud Run Job
    client = run_v2.JobsClient()
    job = run_v2.Job(
        name=f"projects/{PROJECT_ID}/locations/europe-west1/jobs/process-video-{job_id}",
        template=run_v2.ExecutionTemplate(
            template=run_v2.TaskTemplate(
                containers=[run_v2.Container(
                    image="gcr.io/mobil-scan-app/mobil-scan-worker:latest",
                    env=[
                        {"name": "JOB_ID", "value": job_id},
                        {"name": "VIDEO_PATH", "value": video_path}
                    ]
                )]
            )
        )
    )
    
    client.run_job(job=job)
```

---

### Opció 3: Compute Engine VM (PROFESSIONAL)

**Avantatges:**
- ✅ Sempre actiu
- ✅ Màxim control
- ✅ Millor rendiment
- ✅ Solució professional

**Desavantatges:**
- ❌ Cost fix (~30€/mes)
- ❌ Més complex de configurar
- ❌ Necessites gestionar la VM

**Com fer-ho:**

1. **Crear VM:**
```bash
gcloud compute instances create mobil-scan-worker \
  --zone=europe-west1-b \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=50GB \
  --tags=worker
```

2. **Instal·lar Docker:**
```bash
# SSH a la VM
gcloud compute ssh mobil-scan-worker --zone=europe-west1-b

# Instal·lar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Executar worker
docker run -d --restart=always \
  -e REDIS_URL=redis://... \
  -e DATABASE_URL=postgresql://... \
  gcr.io/mobil-scan-app/mobil-scan-worker:latest
```

3. **Configurar autostart:**
```bash
# El worker es reiniciarà automàticament si falla
```

---

### Opció 4: Google Kubernetes Engine (ENTERPRISE)

**Avantatges:**
- ✅ Màxima escalabilitat
- ✅ Alta disponibilitat
- ✅ Orquestració automàtica
- ✅ Solució enterprise

**Desavantatges:**
- ❌ Més car (~100€/mes)
- ❌ Molt complex
- ❌ Overkill per aquest projecte

**No recomanat** per aquest cas d'ús.

---

## 🎯 Recomanació

### Per Desenvolupament/Testing:
**Opció 1: Worker Local**
- Ràpid i fàcil
- Executa `EXECUTAR_WORKER_LOCAL.bat`

### Per Producció (Baix Cost):
**Opció 2: Cloud Run Jobs**
- Pagues només quan processa
- ~5-10€/mes
- Natiu de Google Cloud

### Per Producció (Professional):
**Opció 3: Compute Engine VM**
- Sempre disponible
- ~30€/mes
- Millor rendiment

---

## 📊 Comparació de Costos

| Solució | Cost Mensual | Disponibilitat | Complexitat |
|---------|--------------|----------------|-------------|
| **Local** | 0€ | Quan PC encès | Baixa |
| **Cloud Run Jobs** | 5-10€ | On-demand | Mitjana |
| **Compute Engine** | 30€ | 24/7 | Mitjana |
| **GKE** | 100€+ | 24/7 | Alta |

---

## 🚀 Pròxims Passos

### Ara Mateix (Testing):
```bash
# 1. Executa el worker localment:
EXECUTAR_WORKER_LOCAL.bat

# 2. Puja un video a l'app
# 3. Veuràs el processament en temps real
```

### Per Producció:
1. Decideix quina opció vols (2 o 3)
2. T'ajudo a implementar-la
3. Despleguem i testem

---

## 🆘 Troubleshooting

### Error: "Cannot connect to Redis"
```bash
# Necessites les URLs correctes de Cloud Run
gcloud run services describe mobil-scan-backend \
  --region europe-west1 \
  --format="value(spec.template.spec.containers[0].env)"
```

### Error: "Model not found"
```bash
# Descarrega el model YOLO:
# Posa'l a: worker/models/best_barcode_model.pt
```

### Videos queden en PENDING
```bash
# Verifica que el worker està executant-se:
# - Veuràs logs a la consola
# - "👂 Listening for jobs on 'video_queue'..."
```

---

**Conclusió:** Cloud Run NO és adequat per workers continus. Necessites una de les solucions alternatives.
