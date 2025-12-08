# ⚠️ Nota Important sobre Redis

## Problema Detectat

El worker necessita **Redis** per funcionar, però Redis no està executant-se al teu PC.

```
❌ Failed to connect to Redis: Error 10061 connecting to localhost:6379
```

---

## Solucions

### Opció 1: Instal·lar Redis a Windows (RECOMANAT)

#### **Mètode A: Amb Chocolatey (Fàcil)**

```powershell
# 1. Instal·la Chocolatey (si no el tens)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instal·la Redis
choco install redis-64 -y

# 3. Inicia Redis
redis-server
```

#### **Mètode B: Descàrrega Manual**

1. Descarrega Redis per Windows:
   - https://github.com/microsoftarchive/redis/releases
   - Descarrega `Redis-x64-3.0.504.msi`

2. Instal·la Redis

3. Inicia Redis:
   ```bash
   redis-server
   ```

---

### Opció 2: Usar Docker només per Redis (Més Simple)

Si tens Docker Desktop instal·lat:

```bash
# Inicia Redis en un contenidor
docker run -d -p 6379:6379 --name redis redis:7-alpine

# Verifica que funciona
docker ps
```

**Avantatges:**
- ✅ No necessites instal·lar Redis a Windows
- ✅ Fàcil d'iniciar i aturar
- ✅ No afecta el sistema

---

### Opció 3: Usar WSL2 amb Redis (Avançat)

Si tens WSL2:

```bash
# A WSL2
sudo apt update
sudo apt install redis-server -y
sudo service redis-server start
```

---

## Verificar que Redis Funciona

Després d'instal·lar Redis, verifica que funciona:

```bash
# Prova la connexió
redis-cli ping
```

**Resposta esperada:** `PONG`

---

## Workflow Complet

### **1. Inicia Redis**

**Opció A (Windows):**
```bash
redis-server
```

**Opció B (Docker):**
```bash
docker run -d -p 6379:6379 --name redis redis:7-alpine
```

---

### **2. Executa el Worker**

```bash
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

**Ara hauria de funcionar!** ✅

---

### **3. Executa el Backend**

En una altra terminal:

```bash
cd backend
python main.py
```

---

### **4. Executa el Frontend**

En una altra terminal:

```bash
cd frontend
streamlit run app.py
```

---

## Recomanació Final

### **Per a tu, la millor opció és:**

#### **Opció 1: Redis amb Docker (Més Simple)**

```bash
# 1. Inicia Redis
docker run -d -p 6379:6379 --name redis redis:7-alpine

# 2. Executa el worker
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

**Avantatges:**
- ✅ No necessites instal·lar Redis a Windows
- ✅ Fàcil d'iniciar: `docker start redis`
- ✅ Fàcil d'aturar: `docker stop redis`
- ✅ No afecta el sistema

---

## Troubleshooting

### Error: "redis-server no es reconoce"

**Solució:** Redis no està instal·lat o no està al PATH.

1. Instal·la Redis (veure Opció 1)
2. O usa Docker (veure Opció 2)

---

### Error: "docker: command not found"

**Solució:** Docker no està instal·lat.

1. Instal·la Docker Desktop: https://www.docker.com/products/docker-desktop
2. O instal·la Redis directament a Windows (veure Opció 1)

---

### Redis funciona però el worker no connecta

**Solució:** Verifica el port:

```bash
# Verifica que Redis està escoltant al port 6379
netstat -an | findstr 6379
```

---

## Conclusió

**Redis és necessari per al worker.**

**Millor opció:**
```bash
# Inicia Redis amb Docker (més fàcil)
docker run -d -p 6379:6379 --name redis redis:7-alpine

# Després executa el worker
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

**Això és el que fan els professionals! 🚀**
