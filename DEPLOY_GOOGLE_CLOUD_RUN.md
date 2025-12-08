# 🚀 Deploy a Google Cloud Run - Guia Completa

## ✅ Per Què Google Cloud Run?

- ✅ **No necessites Docker Desktop** - Compila al núvol
- ✅ **Escala automàticament** - De 0 a N instàncies
- ✅ **Pagues només pel que uses** - Quan no hi ha tràfic, 0€
- ✅ **HTTPS automàtic** - Certificats SSL gratis
- ✅ **Més ràpid** - Infraestructura de Google
- ✅ **Més fiable** - No depèn del teu PC

## 📋 Requisits

1. Compte de Google (Gmail)
2. Targeta de crèdit (per verificació, però hi ha **300$ gratis**)
3. Git instal·lat
4. El teu projecte (que ja tens)

## 🎯 Passos Ràpids (30 minuts)

### Pas 1: Crear Compte Google Cloud

1. Ves a: https://console.cloud.google.com/
2. Clica "Try for free" o "Prova gratis"
3. Inicia sessió amb el teu Gmail
4. Accepta els termes
5. Afegeix targeta (no et cobraran, tens **300$ gratis**)

### Pas 2: Crear Projecte

```bash
# A la consola de Google Cloud:
1. Clica "Select a project" (dalt a l'esquerra)
2. Clica "New Project"
3. Nom: "mobil-scan"
4. Clica "Create"
```

### Pas 3: Activar APIs Necessàries

```bash
# A la consola de Google Cloud:
1. Ves a "APIs & Services" > "Enable APIs and Services"
2. Cerca i activa:
   - Cloud Run API
   - Cloud Build API
   - Container Registry API
   - Cloud SQL Admin API (per PostgreSQL)
```

### Pas 4: Instal·lar Google Cloud CLI

**Windows:**
```bash
# Descarrega l'instal·lador:
https://cloud.google.com/sdk/docs/install

# O amb PowerShell:
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
```

**Després de la instal·lació:**
```bash
# Inicia sessió
gcloud auth login

# Configura el projecte
gcloud config set project mobil-scan

# Configura la regió (Europa)
gcloud config set run/region europe-west1
```

### Pas 5: Preparar el Projecte

El teu projecte **ja està preparat** amb Dockerfiles. Només cal ajustar una cosa:

```bash
# Crea aquest fitxer a l'arrel del projecte
```

Crea: `cloudbuild.yaml`

```yaml
steps:
  # Build Backend
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/mobil-scan-backend:$SHORT_SHA'
      - '-f'
      - 'backend/Dockerfile'
      - '.'
    timeout: 1200s

  # Build Frontend
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/mobil-scan-frontend:$SHORT_SHA'
      - '-f'
      - 'frontend/Dockerfile'
      - '.'
    timeout: 1200s

  # Build Worker
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/mobil-scan-worker:$SHORT_SHA'
      - '-f'
      - 'worker/Dockerfile'
      - '.'
    timeout: 1800s

  # Push images
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/mobil-scan-backend:$SHORT_SHA']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/mobil-scan-frontend:$SHORT_SHA']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/mobil-scan-worker:$SHORT_SHA']

images:
  - 'gcr.io/$PROJECT_ID/mobil-scan-backend:$SHORT_SHA'
  - 'gcr.io/$PROJECT_ID/mobil-scan-frontend:$SHORT_SHA'
  - 'gcr.io/$PROJECT_ID/mobil-scan-worker:$SHORT_SHA'

timeout: 3600s

options:
  machineType: 'E2_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
```

### Pas 6: Deploy amb UN SOL COMANDO

```bash
# Des de l'arrel del projecte
gcloud builds submit --config=cloudbuild.yaml
```

**Això:**
- ✅ Puja el codi a Google Cloud
- ✅ Compila les 3 imatges (backend, frontend, worker)
- ✅ Les guarda al Container Registry
- ✅ Tot al núvol, sense Docker Desktop

**Temps:** 15-20 minuts (primera vegada)

### Pas 7: Crear Serveis Cloud Run

#### 7.1 Backend (API)

```bash
gcloud run deploy mobil-scan-backend \
  --image gcr.io/mobil-scan/mobil-scan-backend:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --port 8000 \
  --set-env-vars "REDIS_URL=redis://redis:6379,DATABASE_URL=postgresql://user:pass@host/db"
```

#### 7.2 Frontend (Streamlit)

```bash
gcloud run deploy mobil-scan-frontend \
  --image gcr.io/mobil-scan/mobil-scan-frontend:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --port 8501 \
  --set-env-vars "API_URL=https://mobil-scan-backend-xxx.run.app"
```

#### 7.3 Worker

```bash
gcloud run deploy mobil-scan-worker \
  --image gcr.io/mobil-scan/mobil-scan-worker:latest \
  --platform managed \
  --region europe-west1 \
  --no-allow-unauthenticated \
  --memory 4Gi \
  --cpu 2 \
  --set-env-vars "REDIS_URL=redis://redis:6379,DATABASE_URL=postgresql://user:pass@host/db"
```

### Pas 8: Crear Base de Dades (Cloud SQL)

```bash
# Crear instància PostgreSQL
gcloud sql instances create mobil-scan-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=europe-west1

# Crear base de dades
gcloud sql databases create mobilscan_db \
  --instance=mobil-scan-db

# Crear usuari
gcloud sql users create mobilscan \
  --instance=mobil-scan-db \
  --password=CANVIA_AQUESTA_CONTRASENYA
```

### Pas 9: Crear Redis (Memorystore)

```bash
gcloud redis instances create mobil-scan-redis \
  --size=1 \
  --region=europe-west1 \
  --redis-version=redis_7_0
```

## 🎉 Resultat Final

Després d'aquests passos tindràs:

```
Frontend:  https://mobil-scan-frontend-xxx.run.app
Backend:   https://mobil-scan-backend-xxx.run.app
Worker:    (executa en background)
Database:  Cloud SQL PostgreSQL
Redis:     Memorystore
```

**Tot funcionant al núvol, sense Docker Desktop!**

## 💰 Costos Estimats

### Nivell Gratuït (300$ crèdit):
- **Cloud Run:** ~5-10€/mes (amb poc tràfic)
- **Cloud SQL:** ~10€/mes (db-f1-micro)
- **Memorystore:** ~25€/mes (1GB)
- **Storage:** ~1€/mes

**Total:** ~40€/mes (cobert pels 300$ gratis durant 7-8 mesos)

### Optimització de Costos:

```bash
# Escala a 0 quan no s'usa
gcloud run services update mobil-scan-frontend \
  --min-instances 0 \
  --max-instances 10

# Utilitza instàncies més petites
--memory 512Mi --cpu 1
```

## 🚀 Script Automàtic de Deploy

Crea: `deploy_cloud_run.bat`

```batch
@echo off
echo ========================================
echo DEPLOY A GOOGLE CLOUD RUN
echo ========================================
echo.

echo [1/3] Compilant imatges al nuvol...
gcloud builds submit --config=cloudbuild.yaml

echo.
echo [2/3] Desplegant serveis...
call gcloud run deploy mobil-scan-backend --image gcr.io/mobil-scan/mobil-scan-backend:latest --platform managed --region europe-west1 --allow-unauthenticated
call gcloud run deploy mobil-scan-frontend --image gcr.io/mobil-scan/mobil-scan-frontend:latest --platform managed --region europe-west1 --allow-unauthenticated
call gcloud run deploy mobil-scan-worker --image gcr.io/mobil-scan/mobil-scan-worker:latest --platform managed --region europe-west1

echo.
echo [3/3] Obtenint URLs...
gcloud run services list

echo.
echo ========================================
echo DEPLOY COMPLETAT!
echo ========================================
pause
```

## 📊 Avantatges vs Docker Desktop

| Aspecte | Docker Desktop | Google Cloud Run |
|---------|----------------|------------------|
| **Setup** | Complex | Simple |
| **Compilació** | Local (lent) | Núvol (ràpid) |
| **Recursos** | Limitats (PC) | Il·limitats |
| **Errors I/O** | Freqüents | Mai |
| **Escalabilitat** | Manual | Automàtica |
| **HTTPS** | Manual | Automàtic |
| **Cost** | 0€ (local) | ~40€/mes |
| **Fiabilitat** | Baixa | Alta |
| **Manteniment** | Tu | Google |

## 🆘 Troubleshooting

### Error: "Permission denied"
```bash
gcloud auth login
gcloud auth application-default login
```

### Error: "API not enabled"
```bash
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Error: "Quota exceeded"
```bash
# Augmenta quota a la consola:
# IAM & Admin > Quotas
```

## 📚 Recursos

- **Documentació:** https://cloud.google.com/run/docs
- **Pricing:** https://cloud.google.com/run/pricing
- **Tutorials:** https://cloud.google.com/run/docs/tutorials
- **Support:** https://cloud.google.com/support

## ✅ Checklist Final

- [ ] Compte Google Cloud creat
- [ ] Projecte "mobil-scan" creat
- [ ] APIs activades
- [ ] Google Cloud CLI instal·lat
- [ ] `cloudbuild.yaml` creat
- [ ] Build executat: `gcloud builds submit`
- [ ] Serveis desplegats
- [ ] URLs obtingudes
- [ ] Aplicació funcionant

---

**Amb Google Cloud Run oblides Docker Desktop per sempre!** 🎉
