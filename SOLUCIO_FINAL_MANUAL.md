# 🔧 SOLUCIÓ FINAL - COMANDES MANUALS

## ⚠️ PROBLEMA IDENTIFICAT

`docker ps` es penja → Docker Desktop té un problema.

---

## ✅ SOLUCIÓ (Fes això en ordre)

### 1️⃣ REINICIAR DOCKER DESKTOP

```
1. Obre Docker Desktop
2. Click icona engranatge (Settings)
3. Click "Quit Docker Desktop"
4. Espera 10 segons
5. Obre Docker Desktop de nou
6. Espera que digui "Docker Desktop is running"
```

---

### 2️⃣ DESPRÉS DE REINICIAR

Obre PowerShell i executa **UNA comanda cada vegada**:

```powershell
# Comanda 1: Verificar Docker
docker --version
```

**Espera que respongui.** Si funciona, continua:

```powershell
# Comanda 2: Veure contenidors
docker ps
```

**Si això es penja, Docker Desktop està corrupte.**

---

### 3️⃣ SI DOCKER PS FUNCIONA

Executa aquestes comandes **una per una**:

```powershell
# Aturar contenidors
docker stop backend frontend worker

# Eliminar contenidors
docker rm backend frontend worker

# Crear xarxa
docker network create mobil_scan_network

# Executar Backend
docker run -d --name backend --network mobil_scan_network -p 8000:8000 urkovitx/mobil_scan-backend:latest

# Executar Frontend  
docker run -d --name frontend --network mobil_scan_network -p 8501:8501 urkovitx/mobil_scan-frontend:latest

# Verificar
docker ps

# Obrir navegador
start http://localhost:8501
```

---

### 4️⃣ SI DOCKER PS ES PENJA

**Docker Desktop està corrupte. Solucions:**

#### Opció A: Reset Docker Desktop
```
1. Docker Desktop → Settings
2. Troubleshoot
3. "Reset to factory defaults"
4. Confirmar
5. Esperar 5 minuts
6. Tornar a provar
```

#### Opció B: Reinstal·lar Docker Desktop
```
1. Desinstal·lar Docker Desktop
2. Reiniciar Windows
3. Descarregar: https://www.docker.com/products/docker-desktop
4. Instal·lar
5. Reiniciar Windows
6. Tornar a provar
```

---

## 🎯 DIAGNÒSTIC RÀPID

Obre PowerShell i executa:

```powershell
docker ps
```

**Si respon en < 2 segons:** Docker funciona → Usa les comandes del punt 3

**Si es penja > 10 segons:** Docker corrupte → Fes Reset (punt 4)

---

## 📞 ALTERNATIVA: DOCKER COMPOSE

Si Docker funciona però els scripts fallen, prova:

```powershell
# Crear docker-compose.yml simple
docker-compose up -d
```

Però primer necessito saber si `docker ps` funciona.

---

## 🆘 QUÈ NECESSITO SABER

**Executa això i envia'm el resultat:**

```powershell
docker ps
```

**Opcions:**
1. Respon immediatament → Docker OK
2. Es penja > 10 segons → Docker corrupte
3. Error "Cannot connect" → Docker no està executant-se

---

**Fes el punt 1 (Reiniciar Docker Desktop) i després prova `docker ps`**

**Envia'm què passa.**
