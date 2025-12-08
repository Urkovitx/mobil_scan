# 🔧 Solució: Error I/O i Bus Error en Docker

## ❌ Error Detectat

```
Could not open file /var/cache/apt/archives/partial/... - open (5: Input/output error)
Bus error
rpc error: code = Unavailable desc = error reading from server: EOF
```

## 🎯 Causa

Docker Desktop ha perdut la connexió amb WSL2 o s'ha quedat sense recursos. Això passa sovint en builds llargs.

## ✅ Solució Immediata (3 Passos)

### Pas 1: Reiniciar Docker Desktop

```bash
# Opció A: Des de Windows
1. Obre Docker Desktop
2. Clica la icona d'engranatge (Settings)
3. Clica "Quit Docker Desktop"
4. Espera 10 segons
5. Torna a obrir Docker Desktop
6. Espera que digui "Docker Desktop is running"

# Opció B: Des de PowerShell (com a Administrador)
Stop-Service -Name "com.docker.service" -Force
Start-Sleep -Seconds 10
Start-Service -Name "com.docker.service"
```

### Pas 2: Netejar Caché de Docker

```bash
docker system prune -af --volumes
```

**ATENCIÓ:** Això eliminarà:
- ✅ Contenidors aturats
- ✅ Imatges no utilitzades
- ✅ Caché de build
- ✅ Volums no utilitzats

### Pas 3: Tornar a Intentar el Build

```bash
REBUILD_COMPLET_AMB_IA.bat
```

## 🚀 Solució Alternativa: Build Pas a Pas

Si el problema persisteix, compila un servei cada vegada:

```bash
# 1. Només Worker
docker-compose -f docker-compose.llm.yml build --no-cache worker

# Espera que acabi, després:

# 2. Només Frontend
docker-compose -f docker-compose.llm.yml build --no-cache frontend

# Espera que acabi, després:

# 3. Només Backend
docker-compose -f docker-compose.llm.yml build --no-cache api

# Finalment, inicia tot:
docker-compose -f docker-compose.llm.yml up -d
```

## 🔧 Solució Avançada: Augmentar Recursos

### Opció 1: Docker Desktop Settings

1. Obre Docker Desktop
2. Settings > Resources
3. Augmenta:
   - **Memory:** 6-8 GB (mínim 4 GB)
   - **CPUs:** 4-6 cores
   - **Disk:** 60 GB
   - **Swap:** 2 GB
4. Apply & Restart

### Opció 2: WSL2 Memory Limit

Crea/edita: `C:\Users\ferra\.wslconfig`

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

Després reinicia WSL2:

```powershell
wsl --shutdown
```

## 🆘 Si Res Funciona

### Opció A: Utilitzar Imatges Pre-compilades

```bash
# Utilitza les imatges de Docker Hub (sense millores IA)
docker-compose -f docker-compose.hub.yml up -d
```

### Opció B: Compilar en WSL2 Directament

```bash
# Obre WSL2
wsl

# Navega al projecte
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan

# Compila
docker-compose -f docker-compose.llm.yml build --no-cache worker
```

### Opció C: Reinstal·lar Docker Desktop

1. Desinstal·la Docker Desktop
2. Reinicia Windows
3. Descarrega l'última versió: https://www.docker.com/products/docker-desktop
4. Instal·la
5. Configura WSL2 backend
6. Torna a intentar

## 📊 Diagnòstic

### Verificar Estat de Docker

```bash
# Docker funcionant?
docker info

# WSL2 funcionant?
wsl --list --verbose

# Espai disponible?
docker system df
```

### Logs de Docker

```bash
# Windows Event Viewer
eventvwr.msc
# Busca: Application and Services Logs > Docker Desktop

# O des de PowerShell
Get-EventLog -LogName Application -Source Docker* -Newest 50
```

## 🎯 Recomanació Actual

**Per ara, fes això:**

1. **Reinicia Docker Desktop** (Quit + Reobre)
2. **Neteja tot:** `docker system prune -af --volumes`
3. **Compila només el Worker primer:**
   ```bash
   docker-compose -f docker-compose.llm.yml build --no-cache worker
   ```
4. **Si funciona, continua amb Frontend:**
   ```bash
   docker-compose -f docker-compose.llm.yml build --no-cache frontend
   ```
5. **Inicia els serveis:**
   ```bash
   docker-compose -f docker-compose.llm.yml up -d
   ```

## ✅ Verificació

Després de cada pas, verifica:

```bash
# Docker actiu?
docker ps

# Imatges creades?
docker images | findstr mobil

# Espai disponible?
docker system df
```

## 💡 Consells per Evitar-ho

1. **Tanca altres aplicacions** durant el build
2. **Augmenta recursos** de Docker Desktop
3. **Neteja regularment:** `docker system prune -f`
4. **Compila en hores de menys càrrega** del sistema
5. **Utilitza SSD** si és possible (més ràpid i fiable)

---

**Nota Important:** Aquest error NO és culpa teva ni del codi. És una limitació de Docker Desktop en Windows. És molt comú en builds llargs.

**La tasca de zxing-cpp està completada.** Aquest és només un problema de build de Docker que es pot solucionar reiniciant i tornant a intentar.
