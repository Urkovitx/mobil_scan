# ⚡ Comandes Ràpides - Docker WSL2

## 🚀 Instal·lació Ràpida (Copy-Paste)

### Opció A: Script Automàtic (RECOMANAT)

```bash
# 1. Copiar script a WSL2
cd ~
cp /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan/setup_docker_wsl2.sh .

# 2. Donar permisos d'execució
chmod +x setup_docker_wsl2.sh

# 3. Executar script
./setup_docker_wsl2.sh
```

### Opció B: Comandes Manuals

```bash
# 1. INSTAL·LAR DOCKER
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 2. CONFIGURAR PERMISOS
sudo usermod -aG docker $USER
newgrp docker

# 3. INICIAR DOCKER
sudo service docker start

# 4. VERIFICAR
docker run hello-world

# 5. COPIAR PROJECTE
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux
cd ~/mobil_scan_linux

# 6. BUILD (Dockerfile minimal)
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# 7. INICIAR SERVEIS
docker compose up -d

# 8. VERIFICAR
docker compose ps
docker compose logs worker
```

---

## 📋 Comandes Essencials

### Gestió Docker Daemon

```bash
# Iniciar Docker
sudo service docker start

# Aturar Docker
sudo service docker stop

# Reiniciar Docker
sudo service docker restart

# Estat Docker
sudo service docker status
```

### Gestió del Projecte

```bash
# Navegar al projecte
cd ~/mobil_scan_linux

# Build worker (minimal)
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# Build worker (original)
docker compose build --no-cache --pull worker

# Build tots els serveis
docker compose build --no-cache --pull

# Iniciar serveis
docker compose up -d

# Aturar serveis
docker compose down

# Reiniciar un servei
docker compose restart worker

# Veure logs
docker compose logs -f worker

# Veure estat
docker compose ps
```

### Verificació

```bash
# Verificar zxing-cpp
docker compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"

# Test funcional
docker compose exec worker python -c "import zxingcpp; import numpy as np; img = np.zeros((100,100), dtype=np.uint8); print(len(zxingcpp.read_barcodes(img)))"

# Entrar al contenidor
docker compose exec worker bash

# Veure logs en temps real
docker compose logs -f
```

### Neteja

```bash
# Neteja contenidors aturats
docker container prune -f

# Neteja imatges no utilitzades
docker image prune -a -f

# Neteja volums no utilitzats
docker volume prune -f

# Neteja completa
docker system prune -a --volumes -f
```

---

## 🔧 Troubleshooting Ràpid

### Docker no inicia

```bash
sudo service docker start
sudo service docker status
```

### Permission denied

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Port ocupat

```bash
# Trobar procés
sudo lsof -i :8501

# Matar procés
sudo kill -9 <PID>

# O aturar contenidors
docker compose down
```

### Build falla

```bash
# Utilitzar Dockerfile minimal
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# Neteja i retry
docker system prune -f
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .
```

### Contenidor no inicia

```bash
# Veure logs
docker compose logs worker

# Reiniciar
docker compose restart worker

# Rebuild i reiniciar
docker compose build --no-cache worker
docker compose up -d worker
```

---

## 📊 Verificació Completa

```bash
# 1. Docker funciona
docker --version
docker compose version
docker ps

# 2. Projecte copiat
ls -la ~/mobil_scan_linux
cd ~/mobil_scan_linux
ls -la docker-compose.yml

# 3. Serveis en execució
docker compose ps

# 4. zxing-cpp instal·lat
docker compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"

# 5. Aplicació accessible
curl http://localhost:8501
```

---

## 🎯 Workflow Diari

```bash
# 1. Obrir terminal Ubuntu
# (Des de Windows Terminal o WSL)

# 2. Iniciar Docker (si no està iniciat)
sudo service docker start

# 3. Navegar al projecte
cd ~/mobil_scan_linux

# 4. Iniciar serveis
docker compose up -d

# 5. Veure logs (opcional)
docker compose logs -f

# 6. Treballar amb l'aplicació
# http://localhost:8501

# 7. Aturar serveis (quan acabis)
docker compose down
```

---

## 🔄 Actualitzar Codi

```bash
# Si has fet canvis a Windows i vols actualitzar Linux:

# Opció A: Copiar tot de nou
rm -rf ~/mobil_scan_linux
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux

# Opció B: Copiar fitxers específics
cp "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan/worker/processor.py" ~/mobil_scan_linux/worker/

# Després rebuild
cd ~/mobil_scan_linux
docker compose build worker
docker compose up -d
```

---

## 📝 Alias Útils

Afegeix aquests alias al teu `~/.bashrc`:

```bash
# Editar .bashrc
nano ~/.bashrc

# Afegir al final:
alias dps='docker compose ps'
alias dup='docker compose up -d'
alias ddown='docker compose down'
alias dlogs='docker compose logs -f'
alias dworker='docker compose logs -f worker'
alias dstart='sudo service docker start'
alias dstatus='sudo service docker status'
alias mobil='cd ~/mobil_scan_linux'

# Guardar i recarregar
source ~/.bashrc
```

Ara pots utilitzar:
```bash
mobil      # Anar al projecte
dstart     # Iniciar Docker
dup        # Iniciar serveis
dps        # Veure estat
dworker    # Veure logs del worker
ddown      # Aturar serveis
```

---

## 🌐 Accés des de Windows

L'aplicació és accessible des de Windows a:
- **Frontend**: http://localhost:8501
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## 💡 Consells

1. **Sempre treballa des de Linux** (`~/mobil_scan_linux`) per màxim rendiment
2. **Inicia Docker** abans de treballar: `sudo service docker start`
3. **Utilitza Dockerfile.minimal** per builds més ràpids
4. **Veure logs** si alguna cosa falla: `docker compose logs -f`
5. **Neteja periòdica**: `docker system prune -f`

---

## 🎓 Recursos

- **Guia completa**: `GUIA_DOCKER_WSL2_NATIU.md`
- **Script automàtic**: `setup_docker_wsl2.sh`
- **Documentació Docker**: https://docs.docker.com/
- **Documentació WSL2**: https://docs.microsoft.com/en-us/windows/wsl/

---

**Amb aquestes comandes tindràs tot el que necessites per treballar amb Docker a WSL2!** 🚀
