#!/bin/bash

# Script per configurar Git automàticament
# Executa des de WSL2: bash SETUP_GIT_AUTOMATIC.sh

echo "========================================"
echo "CONFIGURACIÓ AUTOMÀTICA DE GIT"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Pas 1: Demanar email
echo -e "${YELLOW}Pas 1: Configurar identitat Git${NC}"
echo ""
read -p "Introdueix el teu email de GitHub: " EMAIL

if [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: Email buit!${NC}"
    exit 1
fi

# Configurar Git
git config --global user.name "Ferran"
git config --global user.email "$EMAIL"
git config --global credential.helper store

echo -e "${GREEN}✅ Git configurat!${NC}"
echo ""

# Mostrar configuració
echo "Configuració actual:"
git config --global --list | grep user
echo ""

# Pas 2: Instruccions per al token
echo -e "${YELLOW}Pas 2: Crear Personal Access Token${NC}"
echo ""
echo "1. Obre aquest enllaç al navegador:"
echo "   https://github.com/settings/tokens/new"
echo ""
echo "2. Configura el token:"
echo "   - Note: Mobil Scan Development"
echo "   - Expiration: No expiration"
echo "   - Scopes: ✅ repo, ✅ workflow, ✅ write:packages"
echo ""
echo "3. Click 'Generate token'"
echo ""
echo "4. COPIA EL TOKEN (comença amb ghp_)"
echo ""
read -p "Prem ENTER quan tinguis el token copiat..."
echo ""

# Pas 3: Test push
echo -e "${YELLOW}Pas 3: Test de configuració${NC}"
echo ""
echo "Ara farem un commit de prova."
echo ""
echo "Quan demani credencials:"
echo "  Username: Urkovitx"
echo "  Password: [ENGANXA EL TOKEN]"
echo ""
read -p "Prem ENTER per continuar..."
echo ""

# Crear commit de prova
git add .
git commit -m "Configure Git and test authentication" --allow-empty

echo ""
echo "Ara farem push. Introdueix les credencials:"
echo ""

# Intentar push
if git push; then
    echo ""
    echo -e "${GREEN}========================================"
    echo "✅ CONFIGURACIÓ COMPLETADA!"
    echo "========================================${NC}"
    echo ""
    echo "Git està configurat i les credencials guardades."
    echo "A partir d'ara pots fer push sense introduir credencials."
    echo ""
    echo "Pròxim pas:"
    echo "  git add ."
    echo "  git commit -m \"Add improvements\""
    echo "  git push"
    echo ""
else
    echo ""
    echo -e "${RED}========================================"
    echo "❌ ERROR EN EL PUSH"
    echo "========================================${NC}"
    echo ""
    echo "Possibles problemes:"
    echo "1. Token incorrecte o sense permisos"
    echo "2. Username incorrecte (ha de ser: Urkovitx)"
    echo "3. Token expirat"
    echo ""
    echo "Solució:"
    echo "1. Crea un nou token: https://github.com/settings/tokens/new"
    echo "2. Assegura't que té permisos: repo, workflow, write:packages"
    echo "3. Torna a executar aquest script"
    echo ""
fi
