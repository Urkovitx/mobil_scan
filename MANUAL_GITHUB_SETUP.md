# 🚀 SETUP MANUAL GITHUB (Sense Git Local)

## ✅ OPCIÓ ALTERNATIVA: GitHub Web + GitHub Desktop

Si Git no funciona, pots fer-ho tot des de la web!

---

## 📋 PASSOS (10 minuts)

### 1️⃣ Crear Repo a GitHub Web

1. Anar a: https://github.com/new
2. Repository name: `mobil_scan`
3. Description: `Industrial Video Audit Tool - AI-Powered Tag Detection`
4. Public ✅
5. Click "Create repository"

---

### 2️⃣ Pujar Fitxers

**Opció A: Drag & Drop (Més fàcil)**

1. Al repo nou, click "uploading an existing file"
2. Arrossegar TOTA la carpeta `mobil_scan` al navegador
3. Commit message: "Initial commit with GitHub Actions"
4. Click "Commit changes"

**Opció B: GitHub Desktop**

1. Descarregar: https://desktop.github.com/
2. Instal·lar i login
3. File → Add Local Repository
4. Seleccionar carpeta `mobil_scan`
5. Publish repository

---

### 3️⃣ Configurar Secrets

1. Anar a: https://github.com/urkovitx/mobil_scan/settings/secrets/actions
2. Click "New repository secret"

**Secret 1:**
- Name: `DOCKER_USERNAME`
- Value: `urkovitx`
- Click "Add secret"

**Secret 2:**
- Name: `DOCKER_PASSWORD`
- Value: [Token de Docker Hub]
- Click "Add secret"

**Com obtenir el token:**
1. https://hub.docker.com/settings/security
2. New Access Token
3. Name: github-actions
4. Permissions: Read, Write, Delete
5. Generate
6. COPIAR TOKEN

---

### 4️⃣ Activar GitHub Actions

1. Anar a: https://github.com/urkovitx/mobil_scan/actions
2. Si demana permís, click "I understand my workflows, go ahead and enable them"
3. Click "Build and Push Docker Images"
4. Click "Run workflow"
5. Branch: main
6. Click "Run workflow"

---

### 5️⃣ Monitoritzar Build

1. Veure el workflow en execució
2. Click per veure logs en temps real
3. Esperar 15-20 minuts
4. Verificar que acaba amb ✅

---

### 6️⃣ Verificar Imatges

1. Anar a: https://hub.docker.com/u/urkovitx
2. Verificar que existeixen:
   - mobil_scan-backend:latest
   - mobil_scan-frontend:latest
   - mobil_scan-worker:latest

---

### 7️⃣ Descarregar i Executar

```powershell
# A la terminal de VSCode:
docker pull urkovitx/mobil_scan-backend:latest
docker pull urkovitx/mobil_scan-frontend:latest
docker pull urkovitx/mobil_scan-worker:latest

.\run_all_local.bat
```

---

## ⏱️ TEMPS TOTAL

- Crear repo: 2 min
- Pujar fitxers: 3 min
- Configurar secrets: 3 min
- Activar workflow: 2 min
- **Esperar build: 15-20 min**
- Descarregar i executar: 3 min

**Total:** ~30 minuts

---

## 💡 AVANTATGES D'AQUESTA OPCIÓ

- ✅ No necessites Git local
- ✅ Tot des del navegador
- ✅ Més visual
- ✅ Mateix resultat final

---

## 🔄 DESPRÉS POTS INSTAL·LAR GIT

Quan tinguis temps:
1. Tancar VSCode
2. Instal·lar Git: https://git-scm.com/download/win
3. Obrir VSCode
4. Clonar repo: `git clone https://github.com/urkovitx/mobil_scan.git`

---

## 🎯 RECOMANACIÓ

**Usa aquesta opció manual ara** per no perdre temps.

Després, quan Git estigui instal·lat, ja podràs fer push/pull normalment.

---

## 📝 CHECKLIST

- [ ] Crear repo a GitHub
- [ ] Pujar fitxers (drag & drop)
- [ ] Configurar secrets (DOCKER_USERNAME, DOCKER_PASSWORD)
- [ ] Activar workflow
- [ ] Esperar build (15-20 min)
- [ ] Verificar imatges a Docker Hub
- [ ] Descarregar i executar localment

---

**🚀 Comença ara! No necessites Git per fer-ho funcionar!**
