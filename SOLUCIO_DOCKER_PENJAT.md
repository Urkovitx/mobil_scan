# ⚠️ Solució: Docker Penjat

## Problema

Docker Desktop es penja o no respon quan intentes executar comandes.

---

## Solucions Ràpides

### **Solució 1: Reiniciar Docker Desktop (RECOMANAT)**

```bash
# 1. Tanca Docker Desktop completament
# Clica dret a la icona de Docker a la barra de tasques > Quit Docker Desktop

# 2. Espera 10 segons

# 3. Obre Docker Desktop de nou
# Cerca "Docker Desktop" al menú d'inici i obre'l

# 4. Espera que Docker s'iniciï completament (icona verda)

# 5. Verifica que funciona
docker ps
```

---

### **Solució 2: Reiniciar el Servei de Docker**

**PowerShell com a Administrador:**

```powershell
# Atura el servei
Stop-Service com.docker.service

# Espera 5 segons
Start-Sleep -Seconds 5

# Inicia el servei
Start-Service com.docker.service

# Verifica
docker ps
```

---

### **Solució 3: Reiniciar WSL2 (Si uses WSL2)**

```bash
# PowerShell com a Administrador
wsl --shutdown

# Espera 10 segons

# Obre Docker Desktop de nou
```

---

### **Solució 4: Neteja de Docker**

```bash
# Atura tots els contenidors
docker stop $(docker ps -aq)

# Elimina tots els contenidors
docker rm $(docker ps -aq)

# Neteja imatges no utilitzades
docker system prune -a -f

# Reinicia Docker Desktop
```

---

## Verificar Redis Després de Reiniciar

### **Pas 1: Verifica si Redis existeix**

```bash
docker ps -a | findstr redis
```

**Si existeix:**
```bash
# Inicia Redis
docker start redis

# Verifica que funciona
docker exec redis redis-cli ping
```

**Resposta esperada:** `PONG`

---

**Si NO existeix:**
```bash
# Crea Redis de nou
docker run -d -p 6379:6379 --name redis redis:7-alpine

# Verifica que funciona
docker exec redis redis-cli ping
```

---

### **Pas 2: Executa el Script de Verificació**

```bash
VERIFICAR_REDIS.bat
```

**Això farà:**
1. ✅ Verificar Docker
2. ✅ Verificar contenidors
3. ✅ Verificar Redis
4. ✅ Crear Redis si no existeix
5. ✅ Iniciar Redis si està aturat
6. ✅ Testar connexió

---

## Problema Persistent: Docker Sempre es Penja

### **Opció A: Augmentar Recursos de Docker**

1. Obre Docker Desktop
2. Ves a **Settings** > **Resources**
3. Augmenta:
   - **CPUs:** Mínim 4
   - **Memory:** Mínim 8 GB
   - **Swap:** Mínim 2 GB
4. Clica **Apply & Restart**

---

### **Opció B: Reinstal·lar Docker Desktop**

```bash
# 1. Desinstal·la Docker Desktop
# Panell de Control > Programes > Desinstal·lar

# 2. Elimina dades residuals
# Elimina aquestes carpetes:
# - C:\Users\<usuari>\AppData\Local\Docker
# - C:\Users\<usuari>\AppData\Roaming\Docker

# 3. Reinicia el PC

# 4. Descarrega Docker Desktop
# https://www.docker.com/products/docker-desktop

# 5. Instal·la Docker Desktop

# 6. Configura WSL2 si et demana
```

---

### **Opció C: Usar Redis Natiu a Windows (ALTERNATIVA)**

Si Docker continua donant problemes, pots instal·lar Redis directament a Windows:

#### **Amb Chocolatey:**

```powershell
# PowerShell com a Administrador

# 1. Instal·la Chocolatey (si no el tens)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instal·la Redis
choco install redis-64 -y

# 3. Inicia Redis
redis-server
```

#### **Manual:**

1. Descarrega Redis per Windows:
   - https://github.com/microsoftarchive/redis/releases
   - Descarrega `Redis-x64-3.0.504.msi`

2. Instal·la Redis

3. Inicia Redis:
   ```bash
   redis-server
   ```

4. Verifica:
   ```bash
   redis-cli ping
   ```

**Resposta esperada:** `PONG`

---

## Workflow Complet Després de Solucionar

### **1. Verifica Docker i Redis**

```bash
# Executa el script de verificació
VERIFICAR_REDIS.bat
```

---

### **2. Executa el Worker**

```bash
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

---

### **3. Executa el Backend (altra terminal)**

```bash
cd backend
python main.py
```

---

### **4. Executa el Frontend (altra terminal)**

```bash
cd frontend
streamlit run app.py
```

---

## Troubleshooting

### Error: "docker: command not found"

**Solució:** Docker no està al PATH

```bash
# Afegeix Docker al PATH:
# 1. Cerca "Variables d'entorn" al menú d'inici
# 2. Edita "Path" a les variables del sistema
# 3. Afegeix: C:\Program Files\Docker\Docker\resources\bin
# 4. Reinicia el terminal
```

---

### Error: "Cannot connect to the Docker daemon"

**Solució:** Docker Desktop no està executant-se

```bash
# 1. Obre Docker Desktop
# 2. Espera que la icona es posi verda
# 3. Torna a intentar la comanda
```

---

### Error: "Error response from daemon: driver failed"

**Solució:** Problema amb WSL2

```bash
# PowerShell com a Administrador
wsl --shutdown

# Espera 10 segons

# Obre Docker Desktop de nou
```

---

## Recomanació Final

### **Si Docker continua donant problemes:**

**Opció 1: Usa Redis Natiu a Windows**
```bash
choco install redis-64 -y
redis-server
```

**Avantatges:**
- ✅ No depèn de Docker
- ✅ Més estable
- ✅ Més ràpid
- ✅ Menys recursos

---

**Opció 2: Usa WSL2 amb Redis**
```bash
# A WSL2
sudo apt update
sudo apt install redis-server -y
sudo service redis-server start
```

**Avantatges:**
- ✅ Entorn Linux natiu
- ✅ Més estable que Docker Desktop
- ✅ Menys recursos

---

## Conclusió

**Millor estratègia:**

1. **Primer:** Intenta reiniciar Docker Desktop
2. **Si no funciona:** Reinstal·la Docker Desktop
3. **Si continua fallant:** Usa Redis natiu a Windows (Chocolatey)

**Redis natiu és més fiable que Docker Desktop a Windows! 🚀**
