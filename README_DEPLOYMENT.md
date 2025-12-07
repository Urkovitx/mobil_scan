# 🚀 Mobile Scan - Guia de Desplegament

## 📦 Estat Actual

✅ **Totes les imatges al Docker Hub:**
- `urkovitx/mobil-scan-backend:latest`
- `urkovitx/mobil-scan-frontend:latest`
- `urkovitx/mobil-scan-worker-test:ci`

---

## 🎯 OPCIÓ A: Executar Localment (Docker Compose)

### Avantatges:
- ✅ Ràpid per provar
- ✅ No cal build local (usa Docker Hub)
- ✅ Tot en un sol comando

### Desavantatges:
- ⚠️ Docker Desktop pot ser inestable a Windows
- ⚠️ Requereix recursos locals

### Com executar:

```bash
# 1. Copia .env.example a .env
copy .env.example .env

# 2. Edita .env i afegeix la teva GEMINI_API_KEY
notepad .env

# 3. Executa l'script
run_from_dockerhub.bat
```

**O manualment:**
```bash
docker-compose -f docker-compose.hub.yml up -d
```

**Accedir:**
- Frontend: http://localhost:3000
- Backend: http://localhost:8000

---

## 🎯 OPCIÓ B: Google Cloud Run ⭐ RECOMANAT

### Avantatges:
- ✅ **Serverless** - No cal gestionar servidors
- ✅ **Escalat automàtic** - De 0 a N instàncies
- ✅ **Econòmic** - Tier gratuït + ~$10-15/mes després
- ✅ **HTTPS gratuït** - SSL automàtic
- ✅ **Alta disponibilitat** - 99.95% uptime SLA
- ✅ **Deploy en minuts** - Molt ràpid

### Desavantatges:
- ⚠️ Requereix compte de Google Cloud
- ⚠️ Corba d'aprenentatge inicial

### Com desplegar:

**Veure guia completa:** [GOOGLE_CLOUD_RUN_GUIDE.md](GOOGLE_CLOUD_RUN_GUIDE.md)

**Resum ràpid:**
```bash
# 1. Instal·la gcloud CLI
# https://cloud.google.com/sdk/docs/install

# 2. Login i configura
gcloud auth login
gcloud config set project mobil-scan-prod

# 3. Deploy (3 comandos)
gcloud run deploy mobilscan-backend --image=urkovitx/mobil-scan-backend:latest
gcloud run deploy mobilscan-frontend --image=urkovitx/mobil-scan-frontend:latest
gcloud run deploy mobilscan-worker --image=urkovitx/mobil-scan-worker-test:ci
```

**Cost estimat:** GRATIS (tier gratuït) o $10-15/mes

---

## 🎯 OPCIÓ C: Altres Plataformes Cloud

### Railway.app
- ✅ Molt fàcil d'usar
- ✅ $5/mes per servei
- ✅ Deploy des de GitHub
- 📝 [Guia Railway](https://railway.app/new)

### Render.com
- ✅ Tier gratuït disponible
- ✅ SSL automàtic
- ✅ Deploy des de Docker Hub
- 📝 [Guia Render](https://render.com/docs)

### DigitalOcean App Platform
- ✅ $5/mes per servei
- ✅ Molt estable
- ✅ Bona documentació
- 📝 [Guia DigitalOcean](https://docs.digitalocean.com/products/app-platform/)

### AWS ECS / Azure Container Instances
- ✅ Molt potent i escalable
- ⚠️ Més complex
- ⚠️ Més car
- 📝 Requereix més configuració

---

## 📊 Comparativa de Plataformes

| Plataforma | Cost/mes | Dificultat | Escalabilitat | Recomanat per |
|------------|----------|------------|---------------|---------------|
| **Local (Docker)** | $0 | Fàcil | Baixa | Desenvolupament |
| **Cloud Run** ⭐ | $0-15 | Mitjana | Alta | Producció |
| **Railway** | $15 | Fàcil | Mitjana | Startups |
| **Render** | $0-21 | Fàcil | Mitjana | Projectes petits |
| **DigitalOcean** | $15 | Mitjana | Alta | Empreses |
| **AWS/Azure** | $30+ | Alta | Molt Alta | Empreses grans |

---

## 🎯 Recomanació per Fases

### Fase 1: Desenvolupament (ARA)
**Opció:** Local amb Docker Compose
- Usa `run_from_dockerhub.bat`
- Prova que tot funciona
- Desenvolupa noves features

### Fase 2: Testing / MVP
**Opció:** Google Cloud Run (tier gratuït)
- Deploy ràpid
- Comparteix amb beta testers
- Cost: $0 (tier gratuït)

### Fase 3: Producció
**Opció:** Google Cloud Run (escalat)
- Configura dominis personalitzats
- Activa monitorització
- Cost: $10-30/mes segons ús

### Fase 4: Creixement
**Opció:** Cloud Run + CDN + Load Balancer
- Multi-regió
- Alta disponibilitat
- Cost: $50-200/mes segons tràfic

---

## 🔧 Configuració Necessària

### Variables d'Entorn (.env)

```env
# API Keys
GEMINI_API_KEY=your-key-here

# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Redis
REDIS_URL=redis://host:6379/0

# App Config
DEBUG=false
ALLOWED_HOSTS=your-domain.com
CORS_ORIGINS=https://your-domain.com
```

### Secrets a Configurar

1. **GitHub Secrets** (per CI/CD):
   - `DOCKER_HUB_USERNAME`
   - `DOCKER_HUB_TOKEN`
   - `GCP_SA_KEY` (si uses Cloud Run)

2. **Cloud Secrets** (per producció):
   - `GEMINI_API_KEY`
   - `DATABASE_PASSWORD`
   - Altres API keys

---

## 📝 Checklist de Deploy

### Pre-Deploy
- [ ] Imatges al Docker Hub ✅
- [ ] Variables d'entorn configurades
- [ ] Secrets configurats
- [ ] Base de dades preparada

### Deploy Local
- [ ] Docker Desktop funcionant
- [ ] `.env` creat i configurat
- [ ] `run_from_dockerhub.bat` executat
- [ ] Frontend accessible a localhost:3000
- [ ] Backend accessible a localhost:8000

### Deploy Cloud Run
- [ ] Compte de Google Cloud creat
- [ ] gcloud CLI instal·lat
- [ ] Projecte GCP creat
- [ ] APIs activades
- [ ] Cloud SQL creat
- [ ] Serveis desplegats
- [ ] URLs obtingudes i verificades

---

## 🐛 Troubleshooting

### Docker Local

**Problema:** Docker Desktop no inicia
```bash
# Solució 1: Reinicia WSL
wsl --shutdown
wsl

# Solució 2: Reinicia Docker Desktop
# Tanca i obre Docker Desktop

# Solució 3: Usa les imatges del Docker Hub (no cal build local!)
docker-compose -f docker-compose.hub.yml up -d
```

**Problema:** Port ja en ús
```bash
# Atura contenidors anteriors
docker-compose -f docker-compose.hub.yml down

# Verifica ports
netstat -ano | findstr :3000
netstat -ano | findstr :8000
```

### Cloud Run

**Problema:** Deploy falla
```bash
# Verifica logs
gcloud run services logs read mobilscan-backend --region=europe-west1

# Verifica configuració
gcloud run services describe mobilscan-backend --region=europe-west1
```

**Problema:** Base de dades no connecta
```bash
# Verifica Cloud SQL
gcloud sql instances describe mobilscan-db

# Verifica connexió
gcloud sql connect mobilscan-db --user=mobilscan
```

---

## 📚 Documentació Addicional

- [Docker Compose Reference](docker-compose.hub.yml)
- [Google Cloud Run Guide](GOOGLE_CLOUD_RUN_GUIDE.md)
- [GitHub Actions Workflows](.github/workflows/)
- [Environment Variables](.env.example)

---

## 🎯 Pròxims Passos

### Ara Mateix:
1. ✅ Prova local amb `run_from_dockerhub.bat`
2. ✅ Verifica que tot funciona
3. ✅ Desenvolupa/prova features

### Aquesta Setmana:
1. 📝 Crea compte de Google Cloud
2. 📝 Segueix [GOOGLE_CLOUD_RUN_GUIDE.md](GOOGLE_CLOUD_RUN_GUIDE.md)
3. 📝 Deploy a Cloud Run (tier gratuït)

### Aquest Mes:
1. 📝 Configura domini personalitzat
2. 📝 Activa monitorització
3. 📝 Configura CI/CD automàtic

---

## ❓ Necessites Ajuda?

**Per executar localment:**
```bash
run_from_dockerhub.bat
```

**Per desplegar a Cloud Run:**
Veure [GOOGLE_CLOUD_RUN_GUIDE.md](GOOGLE_CLOUD_RUN_GUIDE.md)

**Per altres plataformes:**
Contacta'm i t'ajudo amb la configuració específica!

---

## 🎉 Conclusió

Tens 3 opcions excel·lents:

1. **Local** - Ràpid per desenvolupar
2. **Cloud Run** - Millor per producció (RECOMANAT)
3. **Altres clouds** - Alternatives vàlides

**La meva recomanació:** Comença amb local, després Cloud Run! 🚀
