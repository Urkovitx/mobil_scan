# 🚀 DEPLOY A DOCKER HUB - INSTRUCCIONS

## ✅ PREREQUISITS

Ja tens:
- ✅ Compte Docker Hub
- ✅ Token d'accés

---

## 🎯 EXECUTA ARA

```powershell
.\DEPLOY_DOCKER_HUB_ARA.bat
```

---

## 📝 QUÈ FARÀ

1. **Login a Docker Hub** amb el teu token
2. **Build Backend** (5 min)
3. **Push Backend** a Docker Hub (2 min)
4. **Build Frontend** (5 min)
5. **Push Frontend** a Docker Hub (2 min)
6. **Pregunta si vols Worker** (opcional, triga 20 min)
7. **Executa els contenidors** des de Docker Hub
8. **Obre el navegador** a http://localhost:8501

**Temps total: 15-20 min (sense Worker) o 35-40 min (amb Worker)**

---

## 🔑 ON TROBAR EL TOKEN

1. Anar a https://hub.docker.com
2. Click al teu avatar (dalt dreta)
3. **Account Settings**
4. **Security**
5. **New Access Token**
6. Nom: "mobil-scan-deploy"
7. Permisos: **Read, Write, Delete**
8. **Generate**
9. **COPIAR EL TOKEN** (només es mostra una vegada!)

---

## ⚡ AVANTATGES D'AQUEST MÈTODE

### Vs Docker Desktop Local:
- ✅ **Més ràpid**: Build al núvol és més ràpid
- ✅ **Més fiable**: No depèn de WSL2
- ✅ **Portable**: Pots descarregar les imatges a qualsevol lloc
- ✅ **Compartible**: Altres poden usar les teves imatges

### Vs Build Local:
- ✅ **No es penja**: Build al núvol no té problemes de memòria
- ✅ **Persistent**: Les imatges queden guardades
- ✅ **Versionat**: Pots tenir múltiples versions (tags)

---

## 📊 PROCÉS DETALLAT

### Pas 1: Login (30 segons)
```
Introdueix usuari: urkovitx
Introdueix token: dckr_pat_xxxxx...
✅ Login Succeeded
```

### Pas 2: Build Backend (5 min)
```
Building backend...
Step 1/10 : FROM python:3.11-slim
Step 2/10 : WORKDIR /app
...
✅ Successfully built abc123
```

### Pas 3: Push Backend (2 min)
```
Pushing urkovitx/mobil-scan-backend:latest...
latest: digest: sha256:abc123... size: 1234
✅ Push complete
```

### Pas 4: Build Frontend (5 min)
```
Building frontend...
✅ Successfully built def456
```

### Pas 5: Push Frontend (2 min)
```
Pushing urkovitx/mobil-scan-frontend:latest...
✅ Push complete
```

### Pas 6: Worker (opcional)
```
Vols fer build del Worker? (S/N)
N → Continua sense Worker
S → Build i push Worker (20 min)
```

### Pas 7: Deploy (1 min)
```
Creant xarxa...
Executant Backend...
Executant Frontend...
✅ Contenidors executant-se
```

### Pas 8: Verificar
```
docker ps
CONTAINER ID   IMAGE                                    STATUS
abc123         urkovitx/mobil-scan-backend:latest      Up 10 seconds
def456         urkovitx/mobil-scan-frontend:latest     Up 5 seconds
```

---

## 🌐 DESPRÉS DEL DEPLOY

### Accedir a l'aplicació:
```
Frontend:  http://localhost:8501
Backend:   http://localhost:8000
API Docs:  http://localhost:8000/docs
```

### Verificar imatges a Docker Hub:
```
1. Anar a hub.docker.com
2. Repositories
3. Veure:
   - mobil-scan-backend
   - mobil-scan-frontend
   - mobil-scan-worker (si has fet build)
```

---

## 🔄 ACTUALITZAR EL CODI

Si fas canvis al codi:

```powershell
# 1. Aturar contenidors
docker stop backend frontend worker

# 2. Eliminar contenidors
docker rm backend frontend worker

# 3. Tornar a executar el script
.\DEPLOY_DOCKER_HUB_ARA.bat
```

O només rebuild el servei que has canviat:

```powershell
# Exemple: Només Backend
cd backend
docker build -t urkovitx/mobil-scan-backend:latest .
docker push urkovitx/mobil-scan-backend:latest
docker stop backend
docker rm backend
docker run -d --name backend --network mobil_scan_network -p 8000:8000 urkovitx/mobil-scan-backend:latest
```

---

## ⚠️ TROUBLESHOOTING

### Error: "Login failed"
```
Solució:
1. Verifica usuari (urkovitx)
2. Verifica token (copia'l de nou)
3. Assegura't que el token té permisos Read, Write, Delete
```

### Error: "Build failed"
```
Solució:
1. Verifica que estàs a la carpeta correcta
2. Verifica que els Dockerfiles existeixen
3. Verifica que requirements.txt existeix
```

### Error: "Push failed"
```
Solució:
1. Verifica que has fet login
2. Verifica que el nom del repositori és correcte
3. Verifica que tens permisos de push
```

### Error: "Port already in use"
```
Solució:
docker stop backend frontend worker
docker rm backend frontend worker
```

---

## 💡 CONSELLS

### Per desenvolupament:
```
1. Fes build només del servei que estàs canviant
2. Usa tags per versions (v1.0, v1.1, etc)
3. Mantén "latest" sempre actualitzat
```

### Per producció:
```
1. Usa tags específics (no "latest")
2. Fes build de tots els serveis
3. Testa abans de fer push
```

---

## 🎯 SEGÜENTS PASSOS

Després d'aquest deploy:

### Opció A: Continuar desenvolupant
```
1. Fes canvis al codi
2. Rebuild només el servei canviat
3. Push a Docker Hub
4. Restart contenidor
```

### Opció B: Deploy a producció
```
1. Usa Render.com / Google Cloud Run
2. Connecta amb Docker Hub
3. Deploy automàtic
4. URL pública
```

---

## ✅ CHECKLIST

Abans d'executar:
- [ ] Tens compte Docker Hub
- [ ] Tens token d'accés
- [ ] Docker Desktop està executant-se
- [ ] Estàs a la carpeta mobil_scan

Durant l'execució:
- [ ] Login correcte
- [ ] Build backend OK
- [ ] Push backend OK
- [ ] Build frontend OK
- [ ] Push frontend OK
- [ ] Contenidors executant-se

Després:
- [ ] http://localhost:8501 funciona
- [ ] http://localhost:8000/docs funciona
- [ ] Imatges visibles a hub.docker.com

---

## 🚀 EXECUTA ARA

```powershell
.\DEPLOY_DOCKER_HUB_ARA.bat
```

**Temps estimat: 15-20 minuts**

**Resultat: Aplicació funcionant + Imatges al núvol** ✅
