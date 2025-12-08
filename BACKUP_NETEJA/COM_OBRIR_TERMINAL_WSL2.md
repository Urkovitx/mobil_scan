# 🐧 Com Obrir i Utilitzar la Terminal WSL2 Ubuntu

## 🎯 El Problema

Estàs a la terminal de **Windows** (CMD o PowerShell), però necessites la terminal de **Ubuntu (WSL2)** per executar comandes Linux.

---

## ✅ SOLUCIÓ: Obrir Terminal Ubuntu

### Opció 1: Des de VSCode (RECOMANAT) ⭐

1. **Obrir terminal a VSCode**:
   - Prem `Ctrl + ñ` (o `Ctrl + `` `)
   - O: Menú → Terminal → New Terminal

2. **Canviar a WSL/Ubuntu**:
   - A la dreta de la terminal, veuràs un desplegable (probablement diu "powershell" o "cmd")
   - Clica la **fletxa cap avall** ▼
   - Selecciona **"Ubuntu"** o **"WSL"**

3. **Verificar que estàs a Ubuntu**:
   ```bash
   # Hauries de veure algo com:
   # user@hostname:~$
   
   # Verifica amb:
   uname -a
   # Hauria de dir "Linux"
   ```

### Opció 2: Windows Terminal

1. **Obrir Windows Terminal**:
   - Prem `Win + X`
   - Selecciona "Windows Terminal"
   - O busca "Terminal" al menú d'inici

2. **Obrir pestanya Ubuntu**:
   - Clica la **fletxa cap avall** ▼ a la barra superior
   - Selecciona **"Ubuntu"**

3. **O directament**:
   - Prem `Ctrl + Shift + 5` (si tens Ubuntu configurat)

### Opció 3: Menú d'Inici

1. **Buscar Ubuntu**:
   - Prem `Win`
   - Escriu "Ubuntu"
   - Clica "Ubuntu" o "Ubuntu 22.04 LTS"

### Opció 4: Des de CMD/PowerShell

Si ja tens una terminal oberta:

```bash
# Escriu simplement:
wsl

# O específicament Ubuntu:
wsl -d Ubuntu
```

---

## 🚀 Executar l'Script (Pas a Pas)

### Pas 1: Obrir Terminal Ubuntu

Utilitza qualsevol de les opcions anteriors. **Hauries de veure**:

```bash
user@hostname:~$
```

**NO** hauries de veure:
```
C:\Users\ferra>
```

### Pas 2: Navegar a la Carpeta del Projecte

```bash
# Anar a la carpeta de Windows des de WSL
cd "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"
```

### Pas 3: Copiar Script a Home

```bash
# Copiar script a la carpeta home de Linux
cp setup_docker_wsl2.sh ~
```

### Pas 4: Anar a Home i Executar

```bash
# Anar a home
cd ~

# Donar permisos d'execució
chmod +x setup_docker_wsl2.sh

# Executar script
./setup_docker_wsl2.sh
```

---

## 📋 Comandes Completes (Copy-Paste)

**Copia i enganxa això a la terminal Ubuntu**:

```bash
# 1. Anar a la carpeta del projecte a Windows
cd "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"

# 2. Copiar script a home de Linux
cp setup_docker_wsl2.sh ~

# 3. Anar a home
cd ~

# 4. Donar permisos
chmod +x setup_docker_wsl2.sh

# 5. Executar
./setup_docker_wsl2.sh
```

---

## 🔍 Com Saber si Estàs a Ubuntu?

### Indicadors que estàs a Ubuntu (WSL2):

✅ **Prompt correcte**:
```bash
user@hostname:~$
```

✅ **Comanda funciona**:
```bash
uname -a
# Output: Linux hostname 5.x.x-xxx-Microsoft ...
```

✅ **Directori home**:
```bash
pwd
# Output: /home/user
```

### Indicadors que estàs a Windows:

❌ **Prompt incorrecte**:
```
C:\Users\ferra>
```

❌ **Comanda no funciona**:
```bash
uname -a
# Output: 'uname' no se reconoce como un comando...
```

❌ **Directori Windows**:
```
C:\Users\ferra\...
```

---

## 🎯 Alternativa: Executar Comandes Directament

Si no vols executar l'script, pots executar les comandes manualment:

### 1. Obrir Terminal Ubuntu

### 2. Executar Comandes d'Instal·lació

```bash
# Actualitzar sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instal·lar dependències
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Afegir clau GPG de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Afegir repositori
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instal·lar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configurar permisos
sudo usermod -aG docker $USER

# Iniciar Docker
sudo service docker start

# Verificar
docker run hello-world
```

### 3. Copiar Projecte

```bash
# Copiar de Windows a Linux
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux

# Anar a la carpeta
cd ~/mobil_scan_linux
```

### 4. Build i Iniciar

```bash
# Build
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# Iniciar
docker compose up -d

# Verificar
docker compose ps
```

---

## 🛠️ Configurar VSCode per Defecte

Per fer que VSCode obri sempre Ubuntu per defecte:

### 1. Obrir Settings

- `Ctrl + ,`
- O: File → Preferences → Settings

### 2. Buscar "Terminal Default Profile"

- Escriu: `terminal.integrated.defaultProfile.windows`

### 3. Seleccionar Ubuntu

- Al desplegable, selecciona **"Ubuntu (WSL)"**

Ara cada vegada que obris una terminal a VSCode, serà Ubuntu! ✅

---

## 📊 Resum Visual

```
❌ INCORRECTE (Windows):
C:\Users\ferra\Projectes\...> ./setup_docker_wsl2.sh
"." no se reconoce como un comando...

✅ CORRECTE (Ubuntu):
user@hostname:~$ ./setup_docker_wsl2.sh
╔════════════════════════════════════════╗
║  PART 1: Instal·lació Docker Engine   ║
╚════════════════════════════════════════╝
```

---

## 🎯 Checklist

- [ ] Obrir terminal Ubuntu (no Windows)
- [ ] Verificar amb `uname -a` (hauria de dir "Linux")
- [ ] Navegar a la carpeta del projecte
- [ ] Copiar script a home: `cp setup_docker_wsl2.sh ~`
- [ ] Anar a home: `cd ~`
- [ ] Donar permisos: `chmod +x setup_docker_wsl2.sh`
- [ ] Executar: `./setup_docker_wsl2.sh`

---

## 💡 Consell Final

**Sempre que vegis comandes que comencen amb `sudo`, `apt-get`, `docker`, etc., has d'estar a la terminal Ubuntu (WSL2), NO a Windows!**

---

**Ara sí, obre la terminal Ubuntu i executa l'script!** 🚀
