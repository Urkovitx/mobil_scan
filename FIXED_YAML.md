# 🔧 YAML CORREGIT - GitHub Actions

## ⚠️ PROBLEMA: Error a la línia 7

El problema és probablement amb la indentació o els secrets.

---

## ✅ YAML CORREGIT (Copia aquest)

```yaml
name: Build and Push Docker Images

on:
  push:
    branches:
      - main
      - master
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
```

---

## 🔍 CANVIS FETS

1. ✅ Canviat `branches: [ main, master ]` per format llista correcte
2. ✅ Eliminat `build-args` que podia causar problemes
3. ✅ Verificada indentació correcta

---

## 📝 COM ACTUALITZAR-LO

### Opció A: Editar el fitxer existent
1. Anar a: https://github.com/urkovitx/mobil_scan/blob/main/.github/workflows/blank.yml
2. Click icona del llapis (Edit)
3. ESBORRAR TOT
4. ENGANXAR el YAML de dalt ☝️
5. Commit changes

### Opció B: Esborrar i crear de nou
1. Esborrar `.github/workflows/blank.yml`
2. Crear nou: `.github/workflows/docker-build.yml`
3. Enganxar el YAML de dalt ☝️
4. Commit

---

## ⚠️ IMPORTANT

Assegura't que:
- ✅ No hi ha espais extra al principi
- ✅ La indentació és amb espais (no tabs)
- ✅ Els secrets estan configurats correctament

---

## 🧪 VERIFICAR SECRETS

Anar a: https://github.com/urkovitx/mobil_scan/settings/secrets/actions

Hauries de veure:
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD

---

**📋 Copia el YAML corregit de dalt i substitueix el fitxer a GitHub!**
