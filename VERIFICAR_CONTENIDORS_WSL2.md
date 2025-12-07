# 🔍 Verificar si els Contenidors s'han Creat Correctament

## 🎯 Situació

La terminal de VSCode s'ha tancat/evaporat durant el procés. Necessitem verificar si Docker i els contenidors s'han creat correctament.

---

## ✅ SOLUCIÓ RÀPIDA: Obrir Nova Terminal Ubuntu

### Opció 1: Windows Terminal (RECOMANAT) ⭐

1. **Obrir Windows Terminal**:
   - Prem `Win` (tecla Windows)
   - Escriu "Terminal"
   - Obre "Windows Terminal"

2. **Obrir pestanya Ubuntu**:
   - Clica la **fletxa ▼** a la barra superior
   - Selecciona **"Ubuntu"**

3. **Ja tens terminal Ubuntu funcionant!**

### Opció 2: Des del Menú d'Inici

1. Prem `Win`
2. Escriu "Ubuntu"
3. Clica "Ubuntu" o "Ubuntu 22.04 LTS"

### Opció 3: Des de PowerShell/CMD

1. Obre PowerShell o CMD
2. Escriu:
   ```bash
   wsl
   ```

---

## 🔍 VERIFICAR ESTAT DE DOCKER

### Pas 1: Verificar si Docker està Instal·lat

```bash
# A la terminal Ubuntu, executa:
docker --version
```

**Si veus**:
```
Docker version 24.0.x, build xxxxx
```
✅ **Docker està instal·lat!**

**Si veus**:
```
Command 'docker' not found
```
❌ **Docker NO està instal·lat** → Torna a executar l'script

### Pas 2: Verificar si Docker està en Execució

```bash
# Iniciar Docker (per si no està iniciat)
sudo service docker start

# Verificar estat
sudo service docker status
```

**Si veus**:
```
* Docker is running
```
✅ **Docker està funcionant!**

**Si veus**:
```
* Docker is not running
```
❌ **Docker NO està funcionant** → Executa: `sudo service docker start`

### Pas 3: Verificar Permisos

```bash
# Provar docker sense sudo
docker ps
```

**Si funciona sense errors**:
✅ **Permisos correctes!**

**Si diu "permission denied"**:
```bash
# Afegir usuari al grup docker
sudo usermod -aG docker $USER

# Aplicar canvis
newgrp docker

# Provar de nou
docker ps
```

---

## 🐳 VERIFICAR CONTENIDORS

### Pas 1: Verificar si el Projecte s'ha Copiat

```bash
# Verificar si existeix la carpeta
ls -la ~/mobil_scan_linux
```

**Si veus fitxers**:
✅ **Projecte copiat!**

**Si diu "No such file or directory"**:
❌ **Projecte NO copiat** → Executa:
```bash
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux
```

### Pas 2: Anar a la Carpeta del Projecte

```bash
cd ~/mobil_scan_linux
```

### Pas 3: Verificar si hi ha Contenidors

```bash
# Llistar tots els contenidors (en execució i aturats)
docker ps -a
```

**Possibles resultats**:

#### ✅ Cas 1: Contenidors en Execució
```
CONTAINER ID   IMAGE              STATUS         PORTS                    NAMES
abc123         mobil_scan-worker  Up 5 minutes                            mobil_scan_worker
def456         mobil_scan-api     Up 5 minutes   0.0.0.0:8000->8000/tcp   mobil_scan_api
...
```
**Perfecte! Els contenidors estan funcionant!**

#### ⚠️ Cas 2: Contenidors Aturats
```
CONTAINER ID   IMAGE              STATUS         NAMES
abc123         mobil_scan-worker  Exited (1)     mobil_scan_worker
```
**Els contenidors existeixen però estan aturats** → Iniciar-los:
```bash
docker compose up -d
```

#### ❌ Cas 3: Cap Contenidor
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
**No hi ha contenidors** → Fer el build:
```bash
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .
docker compose up -d
```

### Pas 4: Verificar Imatges Docker

```bash
# Llistar imatges
docker images
```

**Si veus**:
```
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
mobil_scan-worker   latest    abc123def456   5 minutes ago   800MB
```
✅ **Imatge creada!**

**Si no veus cap imatge**:
❌ **Build no completat** → Fer el build

---

## 🚀 RECONSTRUIR SI CAL

Si els contenidors NO s'han creat o hi ha errors:

### Opció A: Build Ràpid (Dockerfile Minimal)

```bash
# 1. Anar al projecte
cd ~/mobil_scan_linux

# 2. Build worker
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# 3. Iniciar serveis
docker compose up -d

# 4. Verificar
docker compose ps
```

### Opció B: Build Complet

```bash
# 1. Anar al projecte
cd ~/mobil_scan_linux

# 2. Build tots els serveis
docker compose build --no-cache --pull

# 3. Iniciar
docker compose up -d

# 4. Verificar
docker compose ps
```

---

## ✅ VERIFICACIÓ FINAL

### 1. Estat dels Contenidors

```bash
docker compose ps
```

**Hauries de veure**:
```
NAME                  STATUS         PORTS
mobil_scan_redis      Up             0.0.0.0:6379->6379/tcp
mobil_scan_db         Up             0.0.0.0:5432->5432/tcp
mobil_scan_api        Up             0.0.0.0:8000->8000/tcp
mobil_scan_worker     Up
mobil_scan_frontend   Up             0.0.0.0:8501->8501/tcp
```

### 2. Verificar zxing-cpp

```bash
docker compose exec worker python -c "import zxingcpp; print(f'zxing-cpp version: {zxingcpp.__version__}')"
```

**Hauries de veure**:
```
zxing-cpp version: 2.2.0
```

### 3. Verificar Logs

```bash
# Veure logs del worker
docker compose logs worker

# Veure logs de tots els serveis
docker compose logs
```

### 4. Accedir a l'Aplicació

Obre el navegador a:
- **Frontend**: http://localhost:8501
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## 🔧 SOLUCIONAR PROBLEMA DE TERMINAL VSCODE

Si vols tornar a utilitzar la terminal de VSCode:

### Solució 1: Reiniciar VSCode

1. Tanca VSCode completament
2. Torna a obrir-lo
3. Obre nova terminal: `Ctrl + ñ`
4. Selecciona "Ubuntu" al desplegable

### Solució 2: Netejar Configuració Terminal

1. `Ctrl + Shift + P`
2. Escriu: "Terminal: Kill All Terminals"
3. Obre nova terminal
4. Selecciona "Ubuntu"

### Solució 3: Utilitzar Windows Terminal

**Recomanació**: Utilitza Windows Terminal en lloc de la terminal integrada de VSCode per treballar amb WSL2. És més estable i fiable.

---

## 📊 Checklist de Verificació

- [ ] Docker instal·lat: `docker --version`
- [ ] Docker en execució: `sudo service docker status`
- [ ] Permisos correctes: `docker ps` (sense sudo)
- [ ] Projecte copiat: `ls ~/mobil_scan_linux`
- [ ] Imatges creades: `docker images`
- [ ] Contenidors en execució: `docker compose ps`
- [ ] zxing-cpp v2.2.0+: `docker compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"`
- [ ] Aplicació accessible: http://localhost:8501

---

## 🎯 Comandes Ràpides de Diagnòstic

Copia i enganxa això per fer un diagnòstic complet:

```bash
echo "=== DIAGNÒSTIC DOCKER WSL2 ==="
echo ""
echo "1. Docker instal·lat?"
docker --version
echo ""
echo "2. Docker en execució?"
sudo service docker status
echo ""
echo "3. Projecte copiat?"
ls -la ~/mobil_scan_linux/docker-compose.yml
echo ""
echo "4. Imatges Docker:"
docker images | grep mobil
echo ""
echo "5. Contenidors:"
docker ps -a
echo ""
echo "6. Estat serveis:"
cd ~/mobil_scan_linux && docker compose ps
echo ""
echo "=== FI DIAGNÒSTIC ==="
```

---

## 💡 Consells

1. **Utilitza Windows Terminal** en lloc de la terminal de VSCode per WSL2
2. **Sempre inicia Docker** abans de treballar: `sudo service docker start`
3. **Si tens dubtes**, executa el diagnòstic complet de dalt
4. **Els logs són els teus amics**: `docker compose logs -f`

---

## 🆘 Si Res Funciona

Si després de tot això els contenidors no funcionen:

```bash
# Neteja completa
docker compose down
docker system prune -a -f

# Rebuild des de zero
cd ~/mobil_scan_linux
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .
docker compose up -d

# Verificar
docker compose ps
docker compose logs
```

---

**Obre Windows Terminal, executa les comandes de verificació i sabrem exactament què ha passat!** 🔍
