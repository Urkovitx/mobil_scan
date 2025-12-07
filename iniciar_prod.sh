#!/bin/bash

echo "========================================"
echo "  MOBILE SCANNER - MODE PRODUCCIÓ"
echo "  (Utilitzant imatges pre-built)"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}ℹ️  Aquest mode utilitza imatges ja construïdes de Docker Hub${NC}"
echo -e "${YELLOW}   Temps d'inici: 2-3 minuts (vs 20+ minuts construint)${NC}"
echo ""

# Aturar serveis antics
echo "[Pas 1/5] Aturant serveis antics..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null
echo -e "${GREEN}✅ Serveis aturats${NC}"
echo ""

# Descarregar imatges
echo "[Pas 2/5] Descarregant imatges de Docker Hub..."
echo "   (Això pot trigar 2-3 minuts la primera vegada)"
docker-compose -f docker-compose.prod.yml pull

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error descarregant imatges${NC}"
    echo ""
    echo "Possibles causes:"
    echo "  1. Connexió a Internet inestable"
    echo "  2. Imatges no disponibles a Docker Hub"
    echo ""
    echo "Solució: Utilitza docker-compose.yml per construir localment"
    exit 1
fi

echo -e "${GREEN}✅ Imatges descarregades${NC}"
echo ""

# Iniciar serveis base
echo "[Pas 3/5] Iniciant Redis + PostgreSQL..."
docker-compose -f docker-compose.prod.yml up -d redis db
sleep 5
echo -e "${GREEN}✅ Serveis base iniciats${NC}"
echo ""

# Iniciar Ollama (sense esperar healthcheck)
echo "[Pas 4/5] Iniciant Ollama LLM..."
echo "   (Sense healthcheck - no bloqueja l'inici)"
docker-compose -f docker-compose.prod.yml up -d llm
echo -e "${GREEN}✅ Ollama iniciat${NC}"
echo ""

# Descarregar model Phi-3 en background
echo "   📥 Descarregant model Phi-3 en background..."
echo "   (Això pot trigar 5-10 minuts, però no bloqueja)"
docker exec mobil_scan_llm ollama pull phi3 > /dev/null 2>&1 &
echo ""

# Iniciar aplicació
echo "[Pas 5/5] Iniciant aplicació (API, Worker, Frontend)..."
docker-compose -f docker-compose.prod.yml up -d api worker frontend

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error iniciant aplicació${NC}"
    echo ""
    echo "Ver logs:"
    echo "  docker-compose -f docker-compose.prod.yml logs"
    exit 1
fi

echo -e "${GREEN}✅ Aplicació iniciada${NC}"
echo ""

# Esperar 5 segons
sleep 5

# Mostrar estat
echo "========================================"
echo "  ESTAT DELS SERVEIS"
echo "========================================"
echo ""
docker-compose -f docker-compose.prod.yml ps
echo ""

# Informació final
echo "========================================"
echo "  TOT LLEST!"
echo "========================================"
echo ""
echo -e "${GREEN}🌐 Aplicació: http://localhost:8501${NC}"
echo -e "${GREEN}🔌 API: http://localhost:8000${NC}"
echo -e "${GREEN}🧠 Ollama: http://localhost:11434${NC}"
echo ""
echo "ℹ️  El model Phi-3 s'està descarregant en background"
echo "   Comprova l'estat: docker exec mobil_scan_llm ollama list"
echo ""
echo "COMANDES ÚTILS:"
echo "  Ver logs:     docker-compose -f docker-compose.prod.yml logs -f"
echo "  Ver worker:   docker-compose -f docker-compose.prod.yml logs -f worker"
echo "  Aturar:       docker-compose -f docker-compose.prod.yml down"
echo ""
echo -e "${YELLOW}💡 Avantatge: Inici en 2-3 minuts (vs 20+ construint)${NC}"
