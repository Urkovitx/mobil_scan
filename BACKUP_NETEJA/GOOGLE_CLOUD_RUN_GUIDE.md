# 🚀 Guia de Desplegament a Google Cloud Run

## Per què Cloud Run és PERFECTE per aquest projecte?

✅ **Avantatges:**
- **Serverless**: No cal gestionar servidors
- **Escalat automàtic**: De 0 a N instàncies segons demanda
- **Pay-per-use**: Només pagues quan s'usa (molt econòmic)
- **Docker nativ**: Usa directament les teves imatges del Docker Hub
- **HTTPS gratuït**: SSL/TLS automàtic
- **Integració amb GCP**: Cloud SQL, Cloud Storage, etc.
- **Fàcil CI/CD**: Deploy automàtic des de GitHub

💰 **Cost estimat:**
- **Tier gratuït**: 2 milions de peticions/mes GRATIS
- **Després**: ~$0.40 per milió de peticions
- **Per aquest projecte**: Probablement GRATIS o <$5/mes

---

## 📋 Prerequisits

1. **Compte de Google Cloud** (300$ gratis per 90 dies)
   - Ves a: https://cloud.google.com/free
   - Crea un compte (necessita targeta, però no cobra fins que ho autoritzis)

2. **Google Cloud CLI** (gcloud)
   - Descarrega: https://cloud.google.com/sdk/docs/install
   - Instal·la i executa: `gcloud init`

3. **Imatges al Docker Hub** ✅ (ja les tens!)
   - urkovitx/mobil-scan-backend:latest
   - urkovitx/mobil-scan-frontend:latest
   - urkovitx/mobil-scan-worker-test:ci

---

## 🎯 OPCIÓ 1: Deploy Manual (Ràpid i Fàcil)

### Pas 1: Configurar Google Cloud

```bash
# Login
gcloud auth login

# Crear projecte
gcloud projects create mobil-scan-prod --name="Mobile Scan Production"

# Seleccionar projecte
gcloud config set project mobil-scan-prod

# Activar APIs necessàries
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

### Pas 2: Crear Cloud SQL (PostgreSQL)

```bash
# Crear instància de PostgreSQL
gcloud sql instances create mobilscan-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=europe-west1 \
  --root-password=CANVIA_AQUESTA_PASSWORD

# Crear base de dades
gcloud sql databases create mobilscan --instance=mobilscan-db

# Crear usuari
gcloud sql users create mobilscan \
  --instance=mobilscan-db \
  --password=CANVIA_AQUESTA_PASSWORD
```

### Pas 3: Guardar secrets (API Keys)

```bash
# Crear secret per Gemini API Key
echo -n "LA_TEVA_GEMINI_API_KEY" | gcloud secrets create gemini-api-key --data-file=-

# Donar permisos a Cloud Run per accedir al secret
gcloud secrets add-iam-policy-binding gemini-api-key \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### Pas 4: Deploy Backend

```bash
# Deploy del backend des de Docker Hub
gcloud run deploy mobilscan-backend \
  --image=urkovitx/mobil-scan-backend:latest \
  --platform=managed \
  --region=europe-west1 \
  --allow-unauthenticated \
  --set-env-vars="DATABASE_URL=postgresql://mobilscan:PASSWORD@/mobilscan?host=/cloudsql/mobil-scan-prod:europe-west1:mobilscan-db" \
  --set-secrets="GEMINI_API_KEY=gemini-api-key:latest" \
  --add-cloudsql-instances=mobil-scan-prod:europe-west1:mobilscan-db \
  --memory=1Gi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=10
```

### Pas 5: Deploy Frontend

```bash
# Obtenir URL del backend
BACKEND_URL=$(gcloud run services describe mobilscan-backend --region=europe-west1 --format='value(status.url)')

# Deploy del frontend
gcloud run deploy mobilscan-frontend \
  --image=urkovitx/mobil-scan-frontend:latest \
  --platform=managed \
  --region=europe-west1 \
  --allow-unauthenticated \
  --set-env-vars="REACT_APP_API_URL=$BACKEND_URL" \
  --memory=512Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=5
```

### Pas 6: Deploy Worker

```bash
# Deploy del worker (sense port públic)
gcloud run deploy mobilscan-worker \
  --image=urkovitx/mobil-scan-worker-test:ci \
  --platform=managed \
  --region=europe-west1 \
  --no-allow-unauthenticated \
  --set-env-vars="DATABASE_URL=postgresql://mobilscan:PASSWORD@/mobilscan?host=/cloudsql/mobil-scan-prod:europe-west1:mobilscan-db" \
  --set-secrets="GEMINI_API_KEY=gemini-api-key:latest" \
  --add-cloudsql-instances=mobil-scan-prod:europe-west1:mobilscan-db \
  --memory=2Gi \
  --cpu=2 \
  --min-instances=0 \
  --max-instances=3
```

### Pas 7: Obtenir URLs

```bash
# URL del frontend (aquesta és la que compartiràs)
gcloud run services describe mobilscan-frontend --region=europe-west1 --format='value(status.url)'

# URL del backend (per configurar)
gcloud run services describe mobilscan-backend --region=europe-west1 --format='value(status.url)'
```

---

## 🎯 OPCIÓ 2: Deploy Automàtic amb GitHub Actions

Crea `.github/workflows/deploy-cloudrun.yml`:

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [ master ]
  workflow_dispatch:

env:
  PROJECT_ID: mobil-scan-prod
  REGION: europe-west1

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
      
      - name: Deploy Backend
        run: |
          gcloud run deploy mobilscan-backend \
            --image=urkovitx/mobil-scan-backend:latest \
            --platform=managed \
            --region=${{ env.REGION }} \
            --allow-unauthenticated \
            --project=${{ env.PROJECT_ID }}
      
      - name: Deploy Frontend
        run: |
          BACKEND_URL=$(gcloud run services describe mobilscan-backend \
            --region=${{ env.REGION }} \
            --format='value(status.url)' \
            --project=${{ env.PROJECT_ID }})
          
          gcloud run deploy mobilscan-frontend \
            --image=urkovitx/mobil-scan-frontend:latest \
            --platform=managed \
            --region=${{ env.REGION }} \
            --allow-unauthenticated \
            --set-env-vars="REACT_APP_API_URL=$BACKEND_URL" \
            --project=${{ env.PROJECT_ID }}
      
      - name: Deploy Worker
        run: |
          gcloud run deploy mobilscan-worker \
            --image=urkovitx/mobil-scan-worker-test:ci \
            --platform=managed \
            --region=${{ env.REGION }} \
            --no-allow-unauthenticated \
            --project=${{ env.PROJECT_ID }}
```

---

## 🎯 OPCIÓ 3: Deploy amb Terraform (Infraestructura com a Codi)

Crea `terraform/main.tf`:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "mobil-scan-prod"
  region  = "europe-west1"
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "mobilscan-db"
  database_version = "POSTGRES_15"
  region           = "europe-west1"

  settings {
    tier = "db-f1-micro"
  }
}

# Backend Service
resource "google_cloud_run_service" "backend" {
  name     = "mobilscan-backend"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "urkovitx/mobil-scan-backend:latest"
        
        env {
          name  = "DATABASE_URL"
          value = "postgresql://..."
        }
      }
    }
  }
}

# Frontend Service
resource "google_cloud_run_service" "frontend" {
  name     = "mobilscan-frontend"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "urkovitx/mobil-scan-frontend:latest"
        
        env {
          name  = "REACT_APP_API_URL"
          value = google_cloud_run_service.backend.status[0].url
        }
      }
    }
  }
}

# Worker Service
resource "google_cloud_run_service" "worker" {
  name     = "mobilscan-worker"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "urkovitx/mobil-scan-worker-test:ci"
      }
    }
  }
}
```

---

## 💰 Estimació de Costs

### Tier Gratuït (Always Free):
- **Cloud Run**: 2M peticions/mes
- **Cloud SQL**: db-f1-micro (1 instància)
- **Egress**: 1GB/mes

### Ús Típic (després del tier gratuït):
- **Cloud Run**: $0.40 per milió de peticions
- **Cloud SQL**: ~$10/mes (db-f1-micro)
- **Storage**: ~$0.02/GB/mes

**Total estimat: $10-15/mes** (molt econòmic!)

---

## 🔒 Seguretat

### 1. Secrets Manager
```bash
# Guardar API keys de forma segura
gcloud secrets create gemini-api-key --data-file=key.txt
```

### 2. IAM Roles
```bash
# Donar permisos mínims necessaris
gcloud projects add-iam-policy-binding mobil-scan-prod \
  --member="serviceAccount:..." \
  --role="roles/cloudsql.client"
```

### 3. VPC Connector (opcional)
```bash
# Per comunicació privada entre serveis
gcloud compute networks vpc-access connectors create mobilscan-connector \
  --region=europe-west1 \
  --range=10.8.0.0/28
```

---

## 📊 Monitorització

### Cloud Logging
```bash
# Veure logs del backend
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=mobilscan-backend" --limit=50
```

### Cloud Monitoring
- Dashboard automàtic a: https://console.cloud.google.com/monitoring
- Mètriques: Peticions, latència, errors, CPU, memòria

### Alertes
```bash
# Crear alerta per errors
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Backend Errors" \
  --condition-display-name="Error rate > 5%" \
  --condition-threshold-value=0.05
```

---

## 🚀 CI/CD Complet

### GitHub Actions + Cloud Run

1. **Build** → GitHub Actions
2. **Push** → Docker Hub
3. **Deploy** → Cloud Run (automàtic)

**Flux complet:**
```
git push → GitHub Actions → Build → Docker Hub → Cloud Run → LIVE!
```

---

## 📝 Checklist de Deploy

- [ ] Compte de Google Cloud creat
- [ ] gcloud CLI instal·lat i configurat
- [ ] Projecte creat a GCP
- [ ] APIs activades (Cloud Run, Cloud SQL)
- [ ] Cloud SQL creat i configurat
- [ ] Secrets creats (API keys)
- [ ] Backend desplegat
- [ ] Frontend desplegat
- [ ] Worker desplegat
- [ ] URLs obtingudes i verificades
- [ ] Monitorització configurada
- [ ] CI/CD configurat (opcional)

---

## 🎯 Pròxims Passos

1. **Ara**: Prova local amb `docker-compose.hub.yml`
2. **Després**: Deploy a Cloud Run seguint aquesta guia
3. **Finalment**: Configura CI/CD per deploys automàtics

---

## ❓ Preguntes Freqüents

**Q: És realment gratuït?**
A: Sí, amb el tier gratuït pots tenir l'app funcionant sense cost. Després, ~$10-15/mes.

**Q: Puc usar el meu propi domini?**
A: Sí! Cloud Run permet dominis personalitzats amb SSL gratuït.

**Q: Com escalo si tinc molt tràfic?**
A: Cloud Run escala automàticament. Només configura `--max-instances`.

**Q: Puc fer rollback si alguna cosa falla?**
A: Sí! Cloud Run manté versions anteriors. Rollback amb 1 click.

**Q: És millor que altres opcions?**
A: Per aquest projecte, SÍ. És més fàcil, econòmic i escalable que AWS/Azure.

---

## 📚 Recursos

- [Cloud Run Docs](https://cloud.google.com/run/docs)
- [Cloud SQL Docs](https://cloud.google.com/sql/docs)
- [Pricing Calculator](https://cloud.google.com/products/calculator)
- [Best Practices](https://cloud.google.com/run/docs/best-practices)

---

**Vols que t'ajudi a fer el deploy a Cloud Run? Digues-me i comencem! 🚀**
