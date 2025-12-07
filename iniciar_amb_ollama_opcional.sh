#!/bin/bash

echo "========================================"
echo "  INICIAR AMB OLLAMA OPCIONAL"
echo "  (Ollama s'intenta però no bloqueja)"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Aturar tot
echo "[Pas 1/6] Aturant serveis antics..."
docker-compose down 2>/dev/null
echo -e "${GREEN}✅ Serveis aturats${NC}"
echo ""

# Iniciar serveis base
echo "[Pas 2/6] Iniciant Redis + PostgreSQL..."
docker-compose up -d redis db 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Error amb docker-compose, provant manualment...${NC}"
    
    # Crear xarxa si no existeix
    docker network create mobil_scan_mobil_network 2>/dev/null
    
    # Redis
    docker run -d --name mobil_scan_redis \
        --network mobil_scan_mobil_network \
        -p 6379:6379 \
        redis:alpine 2>/dev/null || \
    docker run -d --name mobil_scan_redis \
        --network mobil_scan_mobil_network \
        -p 6379:6379 \
        redis:latest 2>/dev/null
    
    # PostgreSQL
    docker run -d --name mobil_scan_db \
        --network mobil_scan_mobil_network \
        -p 5432:5432 \
        -e POSTGRES_USER=mobilscan \
        -e POSTGRES_PASSWORD=mobilscan123 \
        -e POSTGRES_DB=mobilscan_db \
        -v $(pwd)/shared/init_db.sql:/docker-entrypoint-initdb.d/init.sql \
        postgres:alpine 2>/dev/null || \
    docker run -d --name mobil_scan_db \
        --network mobil_scan_mobil_network \
        -p 5432:5432 \
        -e POSTGRES_USER=mobilscan \
        -e POSTGRES_PASSWORD=mobilscan123 \
        -e POSTGRES_DB=mobilscan_db \
        postgres:latest 2>/dev/null
fi

sleep 5
echo -e "${GREEN}✅ Serveis base iniciats${NC}"
echo ""

# Intentar iniciar Ollama (OPCIONAL)
echo "[Pas 3/6] Intentant iniciar Ollama..."
echo -e "${YELLOW}   (Això pot fallar per connexió - no és crític)${NC}"

# Comprovar si Ollama ja està descarregat
if docker images | grep -q "ollama/ollama"; then
    echo "   ✅ Imatge Ollama ja disponible localment"
    docker run -d --name mobil_scan_llm \
        --network mobil_scan_mobil_network \
        -p 11434:11434 \
        -v ollama_data:/root/.ollama \
        -e OLLAMA_HOST=0.0.0.0:11434 \
        ollama/ollama:latest 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ Ollama iniciat${NC}"
        
        # Intentar descarregar Phi-3 en background (no bloqueja)
        echo "   📥 Descarregant Phi-3 en background..."
        (docker exec mobil_scan_llm ollama pull phi3 > /dev/null 2>&1 &)
    else
        echo -e "${YELLOW}   ⚠️  Ollama no s'ha pogut iniciar${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Imatge Ollama no disponible localment${NC}"
    echo "   Intentant descarregar (pot fallar per connexió)..."
    
    timeout 30 docker pull ollama/ollama:latest 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ Ollama descarregat${NC}"
        docker run -d --name mobil_scan_llm \
            --network mobil_scan_mobil_network \
            -p 11434:11434 \
            -v ollama_data:/root/.ollama \
            -e OLLAMA_HOST=0.0.0.0:11434 \
            ollama/ollama:latest 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}   ✅ Ollama iniciat${NC}"
            (docker exec mobil_scan_llm ollama pull phi3 > /dev/null 2>&1 &)
        fi
    else
        echo -e "${RED}   ❌ No s'ha pogut descarregar Ollama (connexió)${NC}"
        echo -e "${YELLOW}   ℹ️  Continuant sense LLM...${NC}"
    fi
fi

echo ""

# Iniciar API
echo "[Pas 4/6] Iniciant API..."
docker-compose up -d api 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Error amb docker-compose, provant construir...${NC}"
    docker-compose build api 2>/dev/null && docker-compose up -d api 2>/dev/null
fi

echo -e "${GREEN}✅ API iniciat${NC}"
echo ""

# Iniciar Worker
echo "[Pas 5/6] Iniciant Worker..."
docker-compose up -d worker 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Error amb docker-compose, provant construir...${NC}"
    docker-compose build worker 2>/dev/null && docker-compose up -d worker 2>/dev/null
fi

echo -e "${GREEN}✅ Worker iniciat${NC}"
echo ""

# Iniciar Frontend
echo "[Pas 6/6] Iniciant Frontend..."
docker-compose up -d frontend 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Error amb docker-compose, provant construir...${NC}"
    docker-compose build frontend 2>/dev/null && docker-compose up -d frontend 2>/dev/null
fi

echo -e "${GREEN}✅ Frontend iniciat${NC}"
echo ""

# Esperar 5 segons
sleep 5

# Mostrar estat
echo "========================================"
echo "  ESTAT DELS SERVEIS"
echo "========================================"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep mobil || docker ps
echo ""

# Comprovar Ollama
echo "========================================"
echo "  ESTAT D'OLLAMA"
echo "========================================"
echo ""

if docker ps | grep -q "mobil_scan_llm"; then
    echo -e "${GREEN}✅ Ollama funcionant${NC}"
    
    # Comprovar models
    MODELS=$(docker exec mobil_scan_llm ollama list 2>/dev/null)
    if echo "$MODELS" | grep -q "phi3"; then
        echo -e "${GREEN}✅ Model Phi-3 disponible${NC}"
    else
        echo -e "${YELLOW}⚠️  Model Phi-3 encara descarregant...${NC}"
        echo "   Comprova: docker exec mobil_scan_llm ollama list"
    fi
else
    echo -e "${YELLOW}⚠️  Ollama no disponible${NC}"
    echo "   L'aplicació funcionarà sense LLM"
fi

echo ""

# Informació final
echo "========================================"
echo "  TOT LLEST!"
echo "========================================"
echo ""
echo -e "${GREEN}🌐 Aplicació: http://localhost:8501${NC}"
echo -e "${GREEN}🔌 API: http://localhost:8000${NC}"

if docker ps | grep -q "mobil_scan_llm"; then
    echo -e "${GREEN}🧠 Ollama: http://localhost:11434${NC}"
else
    echo -e "${YELLOW}🧠 Ollama: No disponible (connexió)${NC}"
fi

echo ""
echo "FUNCIONALITAT:"
if docker ps | grep -q "mobil_scan_llm"; then
    echo "  ✅ Detecció de codis"
    echo "  ✅ Decodificació zxing-cpp v2.2.1"
    echo "  ✅ Base de dades"
    if docker exec mobil_scan_llm ollama list 2>/dev/null | grep -q "phi3"; then
        echo "  ✅ Respostes LLM (Phi-3)"
    else
        echo "  ⏳ Respostes LLM (Phi-3 descarregant...)"
    fi
else
    echo "  ✅ Detecció de codis"
    echo "  ✅ Decodificació zxing-cpp v2.2.1"
    echo "  ✅ Base de dades"
    echo "  ❌ Respostes LLM (Ollama no disponible)"
fi

echo ""
echo "COMANDES ÚTILS:"
echo "  Ver logs:        docker-compose logs -f"
echo "  Ver worker:      docker-compose logs -f worker"
echo "  Ver Ollama:      docker exec mobil_scan_llm ollama list"
echo "  Descarregar Phi-3: docker exec mobil_scan_llm ollama pull phi3"
echo "  Aturar:          docker-compose down"
echo ""
echo -e "${YELLOW}💡 Ollama és opcional - l'aplicació funciona sense ell${NC}"
