#!/bin/bash

echo "========================================"
echo "  MOBILE SCANNER + LLM (WSL2 Native)"
echo "========================================"
echo ""

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo "❌ Docker no està actiu!"
    echo ""
    echo "Iniciant Docker..."
    sudo service docker start
    sleep 3
    
    if ! docker ps &> /dev/null; then
        echo "❌ Error iniciant Docker"
        echo ""
        echo "Prova manualment:"
        echo "  sudo service docker start"
        exit 1
    fi
fi

echo "✅ Docker actiu!"
echo ""

echo "[Pas 1/6] Aturant serveis antics..."
docker-compose down 2>/dev/null
docker-compose -f docker-compose.llm.yml down 2>/dev/null
echo "✅ Serveis aturats"
echo ""

echo "[Pas 2/6] Iniciant Redis + PostgreSQL..."
docker-compose -f docker-compose.llm.yml up -d redis db
sleep 10
echo "✅ Serveis base iniciats"
echo ""

echo "[Pas 3/6] Iniciant Ollama LLM..."
echo "(Pot trigar 2-3 minuts la primera vegada)"
docker-compose -f docker-compose.llm.yml up -d llm

echo -n "Esperant que Ollama estigui llest..."
for i in {1..24}; do # Intentar durant 2 minuts (24 * 5s)
    if curl -s --head http://localhost:11434/ | head -n 1 | grep "200 OK" > /dev/null; then
        echo " ✅ Ollama iniciat i responent!"
        OLLAMA_READY=true
        break
    fi
    echo -n "."
    sleep 5
done

[ "$OLLAMA_READY" = true ] || echo " ⚠️  Ollama ha trigat massa a respondre."

echo ""

echo "[Pas 4/6] Descarregant model Phi-3..."
echo "(Primera vegada: 5-10 minuts per 2.3GB)"
echo "(Següents vegades: instantani)"
docker-compose -f docker-compose.llm.yml up llm_init
echo "✅ Model Phi-3 llest"
echo ""

echo "[Pas 5/6] Iniciant aplicació..."
docker-compose -f docker-compose.llm.yml up -d api worker frontend
sleep 15 # Donar temps extra per a que el worker i l'api s'iniciïn
echo "✅ Aplicació iniciada"
echo ""

echo "========================================"
echo "  ESTAT DELS SERVEIS"
echo "========================================"
echo ""
docker-compose -f docker-compose.llm.yml ps
echo ""

echo "========================================"
echo "  TOT LLEST!"
echo "========================================"
echo ""
echo "🌐 Aplicació: http://localhost:8501"
echo "🔌 API: http://localhost:8000"
echo "🧠 Ollama: http://localhost:11434"
echo ""
echo "COMANDES ÚTILS:"
echo "  Ver logs:     docker-compose -f docker-compose.llm.yml logs -f"
echo "  Ver worker:   docker-compose -f docker-compose.llm.yml logs -f worker"
echo "  Aturar:       docker-compose -f docker-compose.llm.yml down"
echo ""
