# 🔧 Solució: GitHub Actions Ha Fallat

## 🎯 Problema

GitHub Actions ha intentat compilar les imatges Docker però ha fallat:
```
"status": "completed",
"conclusion": "failure"
```

Per això la imatge `urkovitx/mobil-scan-worker:latest` no existeix al Docker Hub.

## ✅ Solucions Immediates

### Opció 1: Utilitzar Versió Base (RECOMANAT ARA)

```bash
EXECUTAR_SENSE_MILLORES.bat
```

Això utilitzarà el `docker-compose.yml` original que **SÍ funciona** i inclou:
- ✅ Backend (FastAPI)
- ✅ Frontend (Streamlit)
- ✅ Worker (amb zxing-cpp actualitzat)
- ✅ Database (PostgreSQL)
- ✅ Redis

**NO inclou:**
- ❌ Millores de preprocessament
- ❌ Pestanya IA amb Ollama

### Opció 2: Compilar Localment amb Millores

Si vols les millores amb IA, compila localment:

```bash
REBUILD_COMPLET_AMB_IA.bat
```

Això trigarà **15-30 minuts** però tindràs totes les millores.

## 🔍 Diagnosticar Per Què Ha Fallat GitHub Actions

### 1. Veure els Logs

Ves a: https://github.com/Urkovitx/mobil_scan/actions

Clica al workflow més recent i revisa els errors.

### 2. Errors Comuns

#### Error: "Docker build timeout"
**Causa:** El build triga més de 6 hores (límit de GitHub Actions)
**Solució:** 
- Optimitza els Dockerfiles
- Utilitza caché de Docker
- Compila localment i puja manualment

#### Error: "Authentication required"
**Causa:** Els secrets de Docker Hub no estan configurats correctament
**Solució:**
```bash
# Verifica els secrets a:
# GitHub > Settings > Secrets and variables > Actions

# Han d'existir:
DOCKER_USERNAME=urkovitx
DOCKER_TOKEN=<el teu token>
```

#### Error: "No space left on device"
**Causa:** GitHub Actions s'ha quedat sense espai
**Solució:**
- Afegeix pas de neteja al workflow
- Redueix mida de les imatges

#### Error: "Rate limit exceeded"
**Causa:** Massa pulls de Docker Hub
**Solució:**
- Espera 6 hores
- O utilitza Docker Hub Pro

## 🔧 Arreglar GitHub Actions

### Workflow Actual

Revisa `.github/workflows/docker-build-millores.yml`:

```yaml
name: Build and Push Docker Images (Millores)

on:
  workflow_dispatch:  # Manual trigger
  push:
    branches: [ master ]
    paths:
      - 'worker/**'
      - 'frontend/**'
      - 'backend/**'
      - 'docker-compose.hub-millores.yml'

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    timeout-minutes: 360  # 6 hores màxim
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      
      - name: Build and push backend
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./backend/Dockerfile
          push: true
          tags: urkovitx/mobil-scan-backend:latest
          cache-from: type=registry,ref=urkovitx/mobil-scan-backend:buildcache
          cache-to: type=registry,ref=urkovitx/mobil-scan-backend:buildcache,mode=max
      
      - name: Build and push frontend
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./frontend/Dockerfile
          push: true
          tags: urkovitx/mobil-scan-frontend:latest
          cache-from: type=registry,ref=urkovitx/mobil-scan-frontend:buildcache
          cache-to: type=registry,ref=urkovitx/mobil-scan-frontend:buildcache,mode=max
      
      - name: Build and push worker
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./worker/Dockerfile
          push: true
          tags: urkovitx/mobil-scan-worker:latest
          cache-from: type=registry,ref=urkovitx/mobil-scan-worker:buildcache
          cache-to: type=registry,ref=urkovitx/mobil-scan-worker:buildcache,mode=max
```

### Possibles Millores

1. **Afegir neteja d'espai:**
```yaml
- name: Free disk space
  run: |
    docker system prune -af
    df -h
```

2. **Reduir timeout si és massa llarg:**
```yaml
timeout-minutes: 120  # 2 hores
```

3. **Compilar només el que ha canviat:**
```yaml
on:
  push:
    paths:
      - 'worker/**'  # Només worker
```

## 🚀 Solució Definitiva

### Pas 1: Utilitza la Versió Base Ara

```bash
EXECUTAR_SENSE_MILLORES.bat
```

Això et permetrà utilitzar l'aplicació **ara mateix** amb zxing-cpp actualitzat.

### Pas 2: Compila Localment (Opcional)

Si vols les millores amb IA:

```bash
# Opció A: Compilar tot
REBUILD_COMPLET_AMB_IA.bat

# Opció B: Només el worker
REBUILD_WORKER_NO_CACHE.bat
```

### Pas 3: Puja Manualment a Docker Hub (Opcional)

Si vols pujar les imatges compilades localment:

```bash
# Login
docker login -u urkovitx

# Tag i push
docker tag mobil_scan_worker:latest urkovitx/mobil-scan-worker:latest
docker push urkovitx/mobil-scan-worker:latest

docker tag mobil_scan_frontend:latest urkovitx/mobil-scan-frontend:latest
docker push urkovitx/mobil-scan-frontend:latest

docker tag mobil_scan_backend:latest urkovitx/mobil-scan-backend:latest
docker push urkovitx/mobil-scan-backend:latest
```

### Pas 4: Arregla GitHub Actions (Per al Futur)

1. Revisa els logs: https://github.com/Urkovitx/mobil_scan/actions
2. Identifica l'error específic
3. Aplica la solució corresponent
4. Torna a executar el workflow manualment

## 📊 Comparació d'Opcions

| Opció | Temps | Millores IA | zxing-cpp v2.2 | Funciona Ara |
|-------|-------|-------------|----------------|--------------|
| **EXECUTAR_SENSE_MILLORES.bat** | 2 min | ❌ | ✅ | ✅ |
| **REBUILD_COMPLET_AMB_IA.bat** | 20-30 min | ✅ | ✅ | ✅ |
| **GitHub Actions (quan funcioni)** | 15-20 min | ✅ | ✅ | ❌ (ara) |

## ✅ Recomanació

**Per ara:**
```bash
EXECUTAR_SENSE_MILLORES.bat
```

Això et dona:
- ✅ Aplicació funcionant **ara mateix**
- ✅ zxing-cpp v2.2.0 actualitzat
- ✅ Component C++ natiu disponible
- ✅ Tots els serveis bàsics

**Per després:**
- Arregla GitHub Actions per builds futurs
- O compila localment quan vulguis les millores amb IA

## 🆘 Si Necessites Ajuda

1. **Revisa els logs de GitHub Actions:**
   ```
   https://github.com/Urkovitx/mobil_scan/actions
   ```

2. **Verifica els secrets:**
   ```
   GitHub > Settings > Secrets and variables > Actions
   ```

3. **Prova compilació local:**
   ```bash
   REBUILD_WORKER_NO_CACHE.bat
   ```

4. **Consulta la documentació:**
   - `worker/cpp_scanner/README.md` - Component C++
   - `GUIA_INTEGRACIO_LLM.md` - Millores IA
   - `SOLUCIO_DOCKER_NO_INICIA.md` - Problemes Docker

---

**Recorda:** La tasca principal (actualitzar zxing-cpp) està **completada**. Les millores amb IA són un bonus que pots afegir després! 🎉
