#!/bin/bash

echo "========================================"
echo "  INSTAL·LAR DOCKER COMPOSE A WSL2"
echo "========================================"
echo ""

# Check if docker-compose is already installed
if command -v docker-compose &> /dev/null; then
    echo "✅ docker-compose ja està instal·lat!"
    docker-compose --version
    exit 0
fi

echo "📦 Instal·lant docker-compose..."
echo ""

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
if command -v docker-compose &> /dev/null; then
    echo ""
    echo "✅ docker-compose instal·lat correctament!"
    docker-compose --version
    echo ""
    echo "Ara pots executar:"
    echo "  ./iniciar_amb_llm_wsl.sh"
else
    echo ""
    echo "❌ Error instal·lant docker-compose"
    echo ""
    echo "Prova manualment:"
    echo "  sudo apt update"
    echo "  sudo apt install docker-compose"
fi
