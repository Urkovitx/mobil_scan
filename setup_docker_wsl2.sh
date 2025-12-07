#!/bin/bash

# ============================================================================
# Script d'Instal·lació Docker Natiu a WSL2 Ubuntu
# ============================================================================
# Aquest script automatitza la instal·lació de Docker Engine natiu
# i la migració del projecte des de Windows a Linux
# ============================================================================

set -e  # Aturar si hi ha errors

# Colors per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funcions d'utilitat
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================================================
# PART 1: INSTAL·LAR DOCKER ENGINE
# ============================================================================

print_header "PART 1: Instal·lació Docker Engine Natiu"

# Verificar si Docker ja està instal·lat
if command -v docker &> /dev/null; then
    print_warning "Docker ja està instal·lat"
    docker --version
    read -p "Vols reinstal·lar Docker? (s/N): " reinstall
    if [[ ! $reinstall =~ ^[Ss]$ ]]; then
        print_info "Saltant instal·lació de Docker"
        SKIP_DOCKER_INSTALL=true
    fi
fi

if [ "$SKIP_DOCKER_INSTALL" != true ]; then
    print_info "Actualitzant sistema..."
    sudo apt-get update -qq
    sudo apt-get upgrade -y -qq
    print_success "Sistema actualitzat"

    print_info "Instal·lant dependències..."
    sudo apt-get install -y -qq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    print_success "Dependències instal·lades"

    print_info "Afegint clau GPG de Docker..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    print_success "Clau GPG afegida"

    print_info "Afegint repositori de Docker..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    print_success "Repositori afegit"

    print_info "Instal·lant Docker Engine..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    print_success "Docker Engine instal·lat"

    # Mostrar versions
    echo ""
    docker --version
    docker compose version
fi

# ============================================================================
# PART 2: CONFIGURAR PERMISOS
# ============================================================================

print_header "PART 2: Configuració de Permisos"

print_info "Afegint usuari al grup docker..."
sudo usermod -aG docker $USER
print_success "Usuari afegit al grup docker"

print_warning "Nota: Hauràs de tancar i tornar a obrir la terminal per aplicar els canvis de grup"
print_info "O pots executar: newgrp docker"

# ============================================================================
# PART 3: INICIAR DOCKER
# ============================================================================

print_header "PART 3: Iniciar Servei Docker"

print_info "Iniciant Docker daemon..."
sudo service docker start
sleep 2

if sudo service docker status | grep -q "running"; then
    print_success "Docker està en execució"
else
    print_error "Docker no s'ha pogut iniciar"
    exit 1
fi

# Test de Docker
print_info "Provant Docker amb hello-world..."
if docker run --rm hello-world > /dev/null 2>&1; then
    print_success "Docker funciona correctament!"
else
    print_warning "Docker funciona però necessites executar: newgrp docker"
fi

# ============================================================================
# PART 4: MIGRAR PROJECTE
# ============================================================================

print_header "PART 4: Migració del Projecte"

# Ruta de Windows (ajusta si cal)
WINDOWS_PATH="/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"
LINUX_PATH="$HOME/mobil_scan_linux"

# Verificar si la ruta de Windows existeix
if [ ! -d "$WINDOWS_PATH" ]; then
    print_error "No s'ha trobat el projecte a: $WINDOWS_PATH"
    read -p "Introdueix la ruta correcta del projecte a Windows: " WINDOWS_PATH
fi

# Verificar si ja existeix a Linux
if [ -d "$LINUX_PATH" ]; then
    print_warning "El projecte ja existeix a: $LINUX_PATH"
    read -p "Vols sobreescriure'l? (s/N): " overwrite
    if [[ $overwrite =~ ^[Ss]$ ]]; then
        print_info "Eliminant carpeta existent..."
        rm -rf "$LINUX_PATH"
    else
        print_info "Utilitzant projecte existent"
        SKIP_COPY=true
    fi
fi

if [ "$SKIP_COPY" != true ]; then
    print_info "Copiant projecte de Windows a Linux..."
    print_info "Origen: $WINDOWS_PATH"
    print_info "Destí: $LINUX_PATH"
    
    cp -r "$WINDOWS_PATH" "$LINUX_PATH"
    
    print_success "Projecte copiat"
    
    print_info "Configurant permisos..."
    sudo chown -R $USER:$USER "$LINUX_PATH"
    print_success "Permisos configurats"
fi

# Verificar fitxers clau
cd "$LINUX_PATH"
if [ -f "docker-compose.yml" ]; then
    print_success "docker-compose.yml trobat"
else
    print_error "docker-compose.yml no trobat!"
    exit 1
fi

if [ -f "worker/Dockerfile.minimal" ]; then
    print_success "worker/Dockerfile.minimal trobat"
else
    print_warning "worker/Dockerfile.minimal no trobat, utilitzarem Dockerfile original"
fi

# ============================================================================
# PART 5: BUILD DEL PROJECTE
# ============================================================================

print_header "PART 5: Build del Projecte"

print_info "Directori actual: $(pwd)"

read -p "Vols fer el build ara? (S/n): " do_build
if [[ ! $do_build =~ ^[Nn]$ ]]; then
    
    # Seleccionar Dockerfile
    if [ -f "worker/Dockerfile.minimal" ]; then
        print_info "Utilitzant Dockerfile.minimal (recomanat)"
        DOCKERFILE="worker/Dockerfile.minimal"
        BUILD_CMD="docker build --no-cache --pull -f $DOCKERFILE -t mobil_scan-worker ."
    else
        print_info "Utilitzant docker-compose amb Dockerfile original"
        BUILD_CMD="docker compose build --no-cache --pull worker"
    fi
    
    print_info "Comanda de build: $BUILD_CMD"
    print_warning "Això pot trigar 3-5 minuts..."
    
    # Executar build
    if eval $BUILD_CMD; then
        print_success "Build completat correctament!"
    else
        print_error "Error durant el build"
        print_info "Pots intentar-ho manualment amb:"
        echo "  cd $LINUX_PATH"
        echo "  $BUILD_CMD"
        exit 1
    fi
    
    # Iniciar serveis
    read -p "Vols iniciar els serveis ara? (S/n): " start_services
    if [[ ! $start_services =~ ^[Nn]$ ]]; then
        print_info "Iniciant serveis..."
        docker compose up -d
        
        sleep 5
        
        print_info "Estat dels serveis:"
        docker compose ps
        
        print_success "Serveis iniciats!"
    fi
fi

# ============================================================================
# PART 6: VERIFICACIÓ
# ============================================================================

print_header "PART 6: Verificació"

if docker compose ps | grep -q "Up"; then
    print_success "Contenidors en execució"
    
    # Verificar zxing-cpp
    print_info "Verificant zxing-cpp..."
    if docker compose exec -T worker python -c "import zxingcpp; print(f'✅ zxing-cpp version: {zxingcpp.__version__}')" 2>/dev/null; then
        print_success "zxing-cpp verificat"
    else
        print_warning "No s'ha pogut verificar zxing-cpp (potser el worker encara s'està iniciant)"
    fi
else
    print_info "Contenidors no iniciats. Pots iniciar-los amb:"
    echo "  cd $LINUX_PATH"
    echo "  docker compose up -d"
fi

# ============================================================================
# RESUM FINAL
# ============================================================================

print_header "INSTAL·LACIÓ COMPLETADA!"

echo -e "${GREEN}✅ Docker Engine instal·lat i configurat${NC}"
echo -e "${GREEN}✅ Projecte migrat a: $LINUX_PATH${NC}"
echo -e "${GREEN}✅ Tot llest per utilitzar!${NC}"

echo ""
echo -e "${BLUE}📋 Pròxims passos:${NC}"
echo ""
echo "1. Tanca i torna a obrir la terminal (per aplicar permisos de grup)"
echo "   O executa: newgrp docker"
echo ""
echo "2. Navega al projecte:"
echo "   cd $LINUX_PATH"
echo ""
echo "3. Si no has fet el build, executa:"
echo "   docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker ."
echo ""
echo "4. Inicia els serveis:"
echo "   docker compose up -d"
echo ""
echo "5. Verifica l'estat:"
echo "   docker compose ps"
echo ""
echo "6. Accedeix a l'aplicació:"
echo "   http://localhost:8501"
echo ""

echo -e "${BLUE}🛠️  Comandes útils:${NC}"
echo ""
echo "  docker compose logs -f worker    # Veure logs del worker"
echo "  docker compose ps                # Estat dels contenidors"
echo "  docker compose down              # Aturar tots els serveis"
echo "  docker compose up -d             # Iniciar tots els serveis"
echo ""

print_success "Script completat!"
