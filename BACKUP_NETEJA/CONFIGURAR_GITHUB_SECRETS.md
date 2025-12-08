# 🔐 Configurar GitHub Secrets per Docker Hub

## ⚠️ IMPORTANT

Els tokens de Docker Hub **NO** es poden posar directament al codi per seguretat. GitHub els detecta i bloqueja el push.

## 📋 Passos per Configurar Secrets

### 1️⃣ Obtenir Token de Docker Hub

1. Ves a: https://hub.docker.com
2. Login amb el teu compte
3. Click a **Account Settings** (dalt a la dreta)
4. Click a **Security** (menú esquerra)
5. Click a **New Access Token**
6. Configura:
   - **Description**: `GitHub Actions - Mobil Scan`
   - **Access permissions**: `Read, Write, Delete`
7. Click **Generate**
8. **COPIA EL TOKEN** (només es mostra una vegada!)
   - Format: `dckr_pat_XXXXXXXXXXXXXXXXXXXXXXXXXX`

### 2️⃣ Afegir Secrets a GitHub

1. Ves al teu repositori: https://github.com/Urkovitx/mobil_scan
2. Click a **Settings** (pestanya superior)
3. Al menú esquerra, click a **Secrets and variables** → **Actions**
4. Click a **New repository secret**

#### Secret 1: DOCKER_USERNAME
- **Name**: `DOCKER_USERNAME`
- **Secret**: `urkovitx` (el teu usuari de Docker Hub)
- Click **Add secret**

#### Secret 2: DOCKER_TOKEN
- Click a **New repository secret** de nou
- **Name**: `DOCKER_TOKEN`
- **Secret**: `dckr_pat_XXXXXXXXX` (el token que has copiat)
- Click **Add secret**

### 3️⃣ Verificar Configuració

Hauries de veure 2 secrets:
```
DOCKER_USERNAME
DOCKER_TOKEN
```

## 🚀 Executar GitHub Actions

Un cop configurats els secrets:

1. Ves a: https://github.com/Urkovitx/mobil_scan/actions
2. Click a **Build and Push Docker Images** (workflow esquerra)
3. Click a **Run workflow** (botó dret)
4. Selecciona `Branch: master`
5. Click a **Run workflow** (verd)

## 📊 Monitoritzar Build

El build trigarà uns **15-20 minuts**:
- ✅ Worker: ~8-10 min (més gran per PaddlePaddle)
- ✅ Frontend: ~3-4 min
- ✅ Backend: ~2-3 min

Pots veure el progrés en temps real a:
https://github.com/Urkovitx/mobil_scan/actions

## ✅ Verificar Imatges

Un cop completat, les imatges estaran a Docker Hub:
- https://hub.docker.com/r/urkovitx/mobil-scan-worker
- https://hub.docker.com/r/urkovitx/mobil-scan-frontend
- https://hub.docker.com/r/urkovitx/mobil-scan-backend

## 🎯 Executar Aplicació

Després del build, executa:
```bash
RUN_FROM_HUB_MILLORES.bat
```

Això descarregarà les imatges del núvol i executarà l'aplicació.

## 🔧 Troubleshooting

### Error: "Secret not found"
- Verifica que els secrets s'han creat correctament
- Els noms han de ser **exactament**: `DOCKER_USERNAME` i `DOCKER_TOKEN`

### Error: "Authentication failed"
- Regenera el token a Docker Hub
- Actualitza el secret `DOCKER_TOKEN` a GitHub

### Build falla
- Revisa els logs a GitHub Actions
- Comprova que tens espai suficient a Docker Hub (compte gratuït: 1 repositori privat)

## 📚 Referències

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

## 🎉 Fet!

Un cop configurat, cada cop que facis push a `master`, GitHub Actions compilarà automàticament les imatges i les pujarà a Docker Hub.
