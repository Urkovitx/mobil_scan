# 🐧 Guia Completa: Docker Natiu a WSL2 Ubuntu

## 🎯 Objectiu

Instal·lar Docker Engine natiu dins de WSL2 Ubuntu per evitar els problemes de rendiment i errors EOF de Docker Desktop.

---

## 📋 Prerequisits

✅ WSL2 instal·lat amb Ubuntu
✅ Docker Desktop desactivat (integració WSL2 en gris)
✅ Terminal Ubuntu oberta

---

## 🚀 PART 1: Instal·lar Docker Engine Natiu

### Pas 1: Actualitzar el Sistema

```bash
# Actualitzar llista de paquets
sudo apt-get update

# Actualitzar paquets instal·lats
sudo apt-get upgrade -y
```

### Pas 2: Instal·lar Dependències

```bash
# Instal·lar paquets necessaris
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

### Pas 3: Afegir Clau GPG Oficial de Docker

```bash
# Crear directori per les claus
sudo mkdir -p /etc/apt/keyrings

# Descarregar i afegir la clau GPG de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Donar permisos de lectura
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### Pas 4: Afegir Repositori de Docker

```bash
# Afegir el repositori oficial de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Pas 5: Instal·lar Docker Engine

```bash
# Actualitzar la llista de paquets amb el nou repositori
sudo apt-get update

# Instal·lar Docker Engine, CLI, containerd i plugins
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
```

### Pas 6: Verificar Instal·lació

```bash
# Verificar versió de Docker
docker --version

# Verificar versió de Docker Compose
docker compose version
```

**Sortida esperada**:
```
Docker version 24.0.x, build xxxxx
Docker Compose version v2.x.x
```

---

## 👤 PART 2: Configurar Permisos d'Usuari

### Pas 1: Afegir Usuari al Grup Docker

```bash
# Afegir el teu usuari al grup docker
sudo usermod -aG docker $USER
```

### Pas 2: Aplicar Canvis de Grup

```bash
# Opció A: Reiniciar sessió (recomanat)
# Tanca i torna a obrir la terminal Ubuntu

# Opció B: Aplicar canvis sense tancar (temporal)
newgrp docker
```

### Pas 3: Verificar Permisos

```bash
# Provar docker sense sudo
docker ps

# Si funciona, veuràs:
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

---

## 🔧 PART 3: Iniciar Servei Docker

### Pas 1: Iniciar Docker Daemon

```bash
# Iniciar el servei Docker
sudo service docker start
```

### Pas 2: Verificar Estat

```bash
# Verificar que Docker està en execució
sudo service docker status
```

**Sortida esperada**:
```
* Docker is running
```

### Pas 3: Test Complet

```bash
# Executar contenidor de test
docker run hello-world
```

**Si veus "Hello from Docker!", tot funciona correctament!** ✅

---

## 📁 PART 4: Migrar Codi de Windows a Linux

### Pas 1: Verificar Ruta de Windows

```bash
# Llistar contingut de la carpeta Windows
ls -la "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan/"
```

### Pas 2: Copiar Projecte a Home de Linux

```bash
# Copiar tot el projecte a la carpeta home de Linux
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux

# Verificar que s'ha copiat correctament
ls -la ~/mobil_scan_linux
```

### Pas 3: Verificar Permisos

```bash
# Assegurar que tens permisos sobre els fitxers
sudo chown -R $USER:$USER ~/mobil_scan_linux

# Verificar permisos
ls -la ~/mobil_scan_linux
```

---

## 🐳 PART 5: Reconstruir amb Docker Natiu

### Pas 1: Entrar a la Carpeta del Projecte

```bash
# Navegar a la carpeta del projecte
cd ~/mobil_scan_linux
```

### Pas 2: Verificar Fitxers Docker

```bash
# Llistar fitxers Docker
ls -la docker-compose.yml
ls -la worker/Dockerfile*

# Veure contingut del docker-compose
cat docker-compose.yml
```

### Pas 3: Reconstruir Worker (Versió Minimal)

```bash
# Opció A: Utilitzar Dockerfile.minimal (RECOMANAT)
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# Opció B: Utilitzar docker-compose amb Dockerfile original
docker compose build --no-cache --pull worker
```

### Pas 4: Iniciar Tots els Serveis

```bash
# Iniciar tots els serveis
docker compose up -d

# Verificar que estan en execució
docker compose ps
```

### Pas 5: Verificar Logs

```bash
# Veure logs del worker
docker compose logs worker

# Veure logs en temps real
docker compose logs -f worker
```

---

## ✅ PART 6: Verificació Final

### Verificar zxing-cpp

```bash
# Verificar versió de zxing-cpp
docker compose exec worker python -c "import zxingcpp; print(f'zxing-cpp version: {zxingcpp.__version__}')"
```

**Sortida esperada**: `zxing-cpp version: 2.2.0` o superior ✅

### Test Funcional

```bash
# Test ràpid de zxing-cpp
docker compose exec worker python -c "import zxingcpp; import numpy as np; img = np.zeros((100, 100), dtype=np.uint8); results = zxingcpp.read_barcodes(img); print('✅ zxing-cpp funciona correctament')"
```

### Verificar Tots els Serveis

```bash
# Estat de tots els contenidors
docker compose ps

# Hauries de veure:
# - redis (Up)
# - db (Up)
# - api (Up)
# - worker (Up)
# - frontend (Up)
```

### Accedir a l'Aplicació

```bash
# Des de Windows, obre el navegador:
# http://localhost:8501
```

---

## 🔄 PART 7: Iniciar Docker Automàticament

### Opció A: Script d'Inici

Crea un script per iniciar Docker automàticament:

```bash
# Crear script
cat > ~/start-docker.sh << 'EOF'
#!/bin/bash
sudo service docker start
echo "✅ Docker iniciat"
EOF

# Donar permisos d'execució
chmod +x ~/start-docker.sh

# Executar
~/start-docker.sh
```

### Opció B: Afegir a .bashrc

```bash
# Afegir a .bashrc per iniciar automàticament
echo '# Iniciar Docker automàticament' >> ~/.bashrc
echo 'if ! service docker status > /dev/null 2>&1; then' >> ~/.bashrc
echo '    sudo service docker start > /dev/null 2>&1' >> ~/.bashrc
echo 'fi' >> ~/.bashrc

# Recarregar .bashrc
source ~/.bashrc
```

---

## 📊 Comparativa: Docker Desktop vs Docker Natiu

| Aspecte | Docker Desktop | Docker Natiu WSL2 |
|---------|----------------|-------------------|
| **Rendiment** | Lent (capa virtualització) | Ràpid (natiu) ✅ |
| **Errors EOF** | Freqüents ❌ | Rars ✅ |
| **Memòria** | 4-6GB necessaris | 2-4GB suficients ✅ |
| **Build time** | 10-15 min | 3-5 min ✅ |
| **Estabilitat** | Problemes freqüents | Molt estable ✅ |
| **Integració** | GUI Windows | CLI Linux ✅ |

---

## 🛠️ Comandes Útils

### Gestió de Docker

```bash
# Iniciar Docker
sudo service docker start

# Aturar Docker
sudo service docker stop

# Reiniciar Docker
sudo service docker restart

# Estat de Docker
sudo service docker status
```

### Gestió de Contenidors

```bash
# Llistar contenidors en execució
docker ps

# Llistar tots els contenidors
docker ps -a

# Aturar tots els contenidors
docker compose down

# Iniciar serveis
docker compose up -d

# Veure logs
docker compose logs -f
```

### Neteja

```bash
# Neteja de contenidors aturats
docker container prune -f

# Neteja d'imatges no utilitzades
docker image prune -a -f

# Neteja completa
docker system prune -a --volumes -f
```

---

## 🐛 Troubleshooting

### Problema: "Cannot connect to Docker daemon"

```bash
# Solució: Iniciar Docker
sudo service docker start
```

### Problema: "Permission denied"

```bash
# Solució: Afegir usuari al grup docker
sudo usermod -aG docker $USER
newgrp docker
```

### Problema: "Port already in use"

```bash
# Solució: Aturar contenidors existents
docker compose down

# O trobar i matar el procés
sudo lsof -i :8501
sudo kill -9 <PID>
```

### Problema: Build lent

```bash
# Solució: Utilitzar Dockerfile.minimal
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .
```

---

## 📝 Resum de Comandes Clau

### Instal·lació Completa (Copy-Paste)

```bash
# 1. Actualitzar sistema
sudo apt-get update && sudo apt-get upgrade -y

# 2. Instal·lar dependències
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 3. Afegir clau GPG
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Afegir repositori
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Instal·lar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Configurar permisos
sudo usermod -aG docker $USER
newgrp docker

# 7. Iniciar Docker
sudo service docker start

# 8. Verificar
docker run hello-world
```

### Migració i Build (Copy-Paste)

```bash
# 1. Copiar projecte
cp -r "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan" ~/mobil_scan_linux

# 2. Entrar a la carpeta
cd ~/mobil_scan_linux

# 3. Build amb Dockerfile minimal (RECOMANAT)
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# 4. Iniciar serveis
docker compose up -d

# 5. Verificar
docker compose ps
docker compose logs worker
```

---

## ✅ Checklist Final

- [ ] Docker Engine instal·lat
- [ ] Usuari afegit al grup docker
- [ ] Docker daemon en execució
- [ ] Test `docker run hello-world` funciona
- [ ] Projecte copiat a ~/mobil_scan_linux
- [ ] Build completat sense errors
- [ ] Tots els serveis en execució
- [ ] zxing-cpp v2.2.0+ verificat
- [ ] Aplicació accessible a http://localhost:8501

---

## 🎯 Avantatges d'Aquesta Configuració

1. ✅ **Rendiment natiu**: Docker corre directament a Linux
2. ✅ **Sense errors EOF**: Millor estabilitat
3. ✅ **Menys recursos**: 2-4GB vs 6GB
4. ✅ **Build més ràpid**: 3-5 min vs 10-15 min
5. ✅ **Més control**: CLI completa de Docker
6. ✅ **Millor per desenvolupament**: Entorn més proper a producció

---

**Amb aquesta configuració, hauràs eliminat els problemes de Docker Desktop i tindràs un entorn molt més estable i ràpid!** 🚀
