# 🔧 Solució: Docker No Inicia

## 🎯 Problema

Quan intentes executar `RUN_FROM_HUB_MILLORES.bat` o qualsevol comanda Docker, reps l'error:
```
[ERROR] Docker no esta actiu!
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
```

## ✅ Solució Ràpida

### Opció 1: Script Automàtic (RECOMANAT)

```bash
INICIAR_DOCKER_I_EXECUTAR.bat
```

Aquest script:
1. Detecta si Docker està actiu
2. Si no ho està, inicia Docker Desktop automàticament
3. Espera fins que Docker estigui llest (màx 2 minuts)
4. Executa l'aplicació automàticament

### Opció 2: Manual

1. **Obre Docker Desktop**
   - Cerca "Docker Desktop" al menú d'inici
   - O executa: `start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"`

2. **Espera que s'iniciï**
   - Veuràs la icona de Docker a la barra de tasques
   - Quan estigui llest, la icona deixarà de girar
   - Això pot trigar 30-60 segons

3. **Verifica que està actiu**
   ```bash
   docker ps
   ```
   Si funciona, veuràs una llista de contenidors (pot estar buida)

4. **Executa l'aplicació**
   ```bash
   RUN_FROM_HUB_MILLORES.bat
   ```

## 🔍 Diagnòstic

### Verificar estat de Docker

```bash
# Veure versió del client
docker version

# Veure contenidors actius
docker ps

# Veure tots els contenidors
docker ps -a

# Veure informació del sistema
docker info
```

### Errors Comuns

#### Error: "The system cannot find the file specified"
**Causa:** Docker Desktop no està executant-se
**Solució:** Inicia Docker Desktop (veure Opció 1 o 2 més amunt)

#### Error: "This error may indicate that the docker daemon is not running"
**Causa:** El servei de Docker no està actiu
**Solució:** 
1. Reinicia Docker Desktop
2. O reinicia el servei: `net stop com.docker.service && net start com.docker.service` (com a administrador)

#### Error: "docker: command not found"
**Causa:** Docker no està instal·lat o no està al PATH
**Solució:** 
1. Reinstal·la Docker Desktop
2. O afegeix Docker al PATH del sistema

## 🚀 Configuració Automàtica

### Fer que Docker s'iniciï automàticament amb Windows

1. Obre Docker Desktop
2. Ves a **Settings** (icona de l'engranatge)
3. A **General**, activa:
   - ✅ **Start Docker Desktop when you log in**
4. Clica **Apply & Restart**

Ara Docker s'iniciarà automàticament cada vegada que encenguis l'ordinador.

## 🐧 Alternativa: WSL2 (Avançat)

Si Docker Desktop et dona problemes constants, pots utilitzar Docker natiu a WSL2:

### 1. Instal·lar Docker a WSL2

```bash
# Dins de WSL2 (Ubuntu)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 2. Iniciar Docker a WSL2

```bash
sudo service docker start
```

### 3. Executar l'aplicació des de WSL2

```bash
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan
docker-compose -f docker-compose.hub-millores.yml up -d
```

## 📊 Verificació Final

Després d'iniciar Docker, verifica que tot funciona:

```bash
# 1. Docker està actiu
docker ps

# 2. Docker Compose funciona
docker-compose version

# 3. Pots descarregar imatges
docker pull hello-world
docker run hello-world
```

Si tot això funciona, ja pots executar:
```bash
RUN_FROM_HUB_MILLORES.bat
```

## 🆘 Si Res Funciona

### Reinstal·lar Docker Desktop

1. **Desinstal·la Docker Desktop**
   - Configuració > Aplicacions > Docker Desktop > Desinstal·lar

2. **Neteja residus**
   ```bash
   # Elimina carpetes de Docker
   rmdir /s /q "%APPDATA%\Docker"
   rmdir /s /q "%LOCALAPPDATA%\Docker"
   rmdir /s /q "%ProgramData%\Docker"
   ```

3. **Reinicia l'ordinador**

4. **Descarrega i instal·la Docker Desktop**
   - https://www.docker.com/products/docker-desktop/

5. **Configura WSL2 com a backend**
   - Durant la instal·lació, selecciona "Use WSL 2 instead of Hyper-V"

## 📞 Suport Addicional

Si continues tenint problemes:

1. **Revisa els logs de Docker Desktop**
   - Docker Desktop > Troubleshoot > View logs

2. **Comprova requisits del sistema**
   - Windows 10/11 Pro, Enterprise o Education
   - WSL2 instal·lat i actualitzat
   - Virtualització activada a la BIOS

3. **Fòrum de Docker**
   - https://forums.docker.com/

## ✅ Checklist de Verificació

- [ ] Docker Desktop està instal·lat
- [ ] Docker Desktop s'està executant (icona a la barra de tasques)
- [ ] `docker ps` funciona sense errors
- [ ] `docker-compose version` mostra la versió
- [ ] WSL2 està instal·lat i actualitzat (si utilitzes Docker Desktop)
- [ ] Virtualització està activada a la BIOS
- [ ] Tens permisos d'administrador (si cal)

---

**Recorda:** La manera més fàcil és utilitzar `INICIAR_DOCKER_I_EXECUTAR.bat` que ho fa tot automàticament! 🚀
