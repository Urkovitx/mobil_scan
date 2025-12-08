# 🚀 EXECUTAR BUILD A GITHUB ACTIONS

## 📋 PASSOS PER LLENÇAR EL BUILD

### 1️⃣ Anar a GitHub Actions
```
https://github.com/urkovitx/mobil_scan/actions
```

### 2️⃣ Seleccionar el Workflow
- Veuràs "Build and Push Docker Images" a l'esquerra
- Click sobre aquest workflow

### 3️⃣ Executar Manualment
- A la dreta veuràs un botó **"Run workflow"**
- Click "Run workflow"
- Seleccionar branch: **main**
- Click botó verd **"Run workflow"**

### 4️⃣ Monitoritzar el Build
- Apareixerà un nou workflow en execució
- Click sobre ell per veure els logs en temps real
- Veuràs 3 jobs en paral·lel:
  - 🔵 build-backend
  - 🔵 build-frontend
  - 🔵 build-worker

### 5️⃣ Esperar (15-20 minuts)
- Backend: ~3-5 min ✅
- Frontend: ~3-5 min ✅
- Worker: ~15-20 min ⏳ (PaddlePaddle és pesat)

### 6️⃣ Verificar Èxit
Quan acabi, hauries de veure:
- ✅ build-backend: Success
- ✅ build-frontend: Success
- ✅ build-worker: Success

---

## 🔍 VERIFICAR IMATGES A DOCKER HUB

### Anar a Docker Hub:
```
https://hub.docker.com/u/urkovitx
```

### Hauries de veure:
- ✅ `urkovitx/mobil_scan-backend:latest`
- ✅ `urkovitx/mobil_scan-frontend:latest`
- ✅ `urkovitx/mobil_scan-worker:latest`

---

## 💻 DESCARREGAR I EXECUTAR LOCALMENT

### Opció A: Script Automàtic (Recomanat)

```powershell
# A la terminal de VSCode:
.\run_all_local.bat
```

Aquest script farà:
1. Pull de les 3 imatges des de Docker Hub
2. Crear xarxa Docker
3. Executar els 3 contenidors
4. Mostrar logs

### Opció B: Manual

```powershell
# 1. Descarregar imatges
docker pull urkovitx/mobil_scan-backend:latest
docker pull urkovitx/mobil_scan-frontend:latest
docker pull urkovitx/mobil_scan-worker:latest

# 2. Crear xarxa
docker network create mobil_scan_network

# 3. Executar Backend
docker run -d --name backend --network mobil_scan_network -p 8000:8000 urkovitx/mobil_scan-backend:latest

# 4. Executar Worker
docker run -d --name worker --network mobil_scan_network -v ./shared:/app/shared urkovitx/mobil_scan-worker:latest

# 5. Executar Frontend
docker run -d --name frontend --network mobil_scan_network -p 8501:8501 -v ./shared:/app/shared urkovitx/mobil_scan-frontend:latest

# 6. Veure logs
docker logs -f frontend
```

---

## 🌐 ACCEDIR A L'APLICACIÓ

### Frontend (Streamlit):
```
http://localhost:8501
```

### Backend API:
```
http://localhost:8000
```

### Documentació API:
```
http://localhost:8000/docs
```

---

## 🎯 WORKFLOW COMPLET

```
1. GitHub Actions Build (15-20 min)
   ↓
2. Imatges a Docker Hub
   ↓
3. Pull local (2-3 min)
   ↓
4. Executar contenidors (1 min)
   ↓
5. Aplicació funcionant! 🎉
```

---

## 🔧 TROUBLESHOOTING

### Si el build falla:

1. **Verificar secrets:**
   ```
   https://github.com/urkovitx/mobil_scan/settings/secrets/actions
   ```
   - DOCKER_USERNAME: urkovitx
   - DOCKER_PASSWORD: [token]

2. **Verificar logs:**
   - Click al job que ha fallat
   - Llegir el missatge d'error
   - Buscar "Error" o "Failed"

3. **Errors comuns:**
   - ❌ "Invalid credentials" → Revisar secrets
   - ❌ "Timeout" → Normal per Worker (augmentar timeout)
   - ❌ "No space left" → Problema de GitHub (re-executar)

### Si el pull local falla:

```powershell
# Verificar que les imatges existeixen
docker search urkovitx/mobil_scan

# Verificar login
docker login
# Username: urkovitx
# Password: [el mateix token]
```

---

## 📊 TEMPS ESTIMATS

| Pas | Temps |
|-----|-------|
| Executar workflow | 1 min |
| Build Backend | 3-5 min |
| Build Frontend | 3-5 min |
| Build Worker | 15-20 min |
| **Total Build** | **~20 min** |
| Pull local | 2-3 min |
| Executar local | 1 min |
| **Total fins funcionar** | **~25 min** |

---

## ✅ CHECKLIST

- [ ] Anar a GitHub Actions
- [ ] Click "Run workflow"
- [ ] Esperar 15-20 minuts
- [ ] Verificar èxit (3 jobs verds)
- [ ] Verificar Docker Hub (3 imatges)
- [ ] Executar `.\run_all_local.bat`
- [ ] Obrir http://localhost:8501
- [ ] Provar l'aplicació! 🎉

---

## 🎉 SEGÜENT PAS

**Executa ara:**
1. Anar a: https://github.com/urkovitx/mobil_scan/actions
2. Click "Run workflow"
3. Esperar 20 minuts
4. Executar `.\run_all_local.bat`
5. Obrir http://localhost:8501

**En 25 minuts tindràs l'aplicació funcionant!** 🚀
