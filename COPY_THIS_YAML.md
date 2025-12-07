# 📋 COPIA AQUEST YAML PER GITHUB ACTIONS

## 🎯 FITXER: `.github/workflows/docker-build.yml`

Copia tot el contingut de sota i enganxa'l a GitHub:

```yaml
name: Build and Push Docker Images

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build-backend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push Backend
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./backend/Dockerfile
          push: true
          tags: urkovitx/mobil_scan-backend:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  build-frontend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push Frontend
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./frontend/Dockerfile
          push: true
          tags: urkovitx/mobil_scan-frontend:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  build-worker:
    runs-on: ubuntu-latest
    timeout-minutes: 60
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push Worker
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./worker/Dockerfile
          push: true
          tags: urkovitx/mobil_scan-worker:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILDKIT_INLINE_CACHE=1
```

---

## 📝 PASSOS PER PUJAR-LO

### 1️⃣ Anar al teu repo GitHub
```
https://github.com/urkovitx/mobil_scan
```

### 2️⃣ Crear el fitxer
- Click "Add file" → "Create new file"
- Nom del fitxer: `.github/workflows/docker-build.yml`
- Enganxar el YAML de dalt ☝️

### 3️⃣ Commit
- Commit message: "Add GitHub Actions workflow"
- Click "Commit new file"

### 4️⃣ Executar
- Anar a: https://github.com/urkovitx/mobil_scan/actions
- Click "Build and Push Docker Images"
- Click "Run workflow" → "Run workflow"

### 5️⃣ Monitoritzar
- Veure el build en temps real
- Esperar 15-20 minuts
- Verificar a Docker Hub

---

## ✅ SECRETS NECESSARIS (Ja configurats)

- ✅ DOCKER_USERNAME: urkovitx
- ✅ DOCKER_PASSWORD: [token]

---

## 🎯 RESULTAT ESPERAT

Després de 15-20 minuts tindràs:
- ✅ urkovitx/mobil_scan-backend:latest
- ✅ urkovitx/mobil_scan-frontend:latest
- ✅ urkovitx/mobil_scan-worker:latest

---

## 🚀 DESPRÉS POTS EXECUTAR LOCALMENT

```powershell
docker pull urkovitx/mobil_scan-backend:latest
docker pull urkovitx/mobil_scan-frontend:latest
docker pull urkovitx/mobil_scan-worker:latest

.\run_all_local.bat
```

---

**📋 Copia el YAML de dalt i enganxa'l a GitHub!**
