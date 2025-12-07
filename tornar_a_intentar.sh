#!/bin/bash

echo "========================================"
echo "  TORNAR A INTENTAR - Descarregar Ollama"
echo "========================================"
echo ""

echo "📥 Intentant descarregar imatge Ollama..."
echo ""

MAX_RETRIES=5
RETRY_COUNT=0
SUCCESS=false

until [ $RETRY_COUNT -ge $MAX_RETRIES ] || $SUCCESS; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    echo "🔹 Intent $RETRY_COUNT de $MAX_RETRIES..."
    docker-compose -f docker-compose.llm.yml pull llm
    if [ $? -eq 0 ]; then
        SUCCESS=true
    else
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "⚠️  Intent fallit. La xarxa és inestable. Esperant 30 segons abans de reintentar..."
            sleep 30
        fi
    fi
done

if $SUCCESS; then
    echo ""
    echo "✅ Imatge descarregada correctament!"
    echo ""
    echo "========================================" 
    echo "  PRÒXIM PAS"
    echo "========================================"
    echo ""
    echo "Ara que la imatge està descarregada, executa l'script principal"
    echo "per iniciar tot el sistema correctament:"
    echo "  ./iniciar_amb_llm_wsl.sh"
else
    echo ""
    echo "❌ Error descarregant imatge després de $MAX_RETRIES intents."
    echo ""
    echo "Possibles causes:"
    echo "  - Problema de connexió a Internet persistent."
    echo "  - Falta d'espai en disc (executa 'sudo docker system prune')."
    echo "  - Docker Hub temporalment no disponible."
    echo ""
    echo "Solucions:"
    echo "  1. Allibera espai i torna a executar aquest script."
    echo "  2. Verifica connexió: ping google.com"
    echo "  3. Prova des d'una altra xarxa (hotspot del mòbil)."
    echo ""
    echo "Mentrestant, pots utilitzar el sistema sense LLM:"
    echo "  docker-compose up -d redis db api worker frontend"
fi
