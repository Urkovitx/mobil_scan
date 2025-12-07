#!/bin/bash

echo "========================================"
echo "  DIAGNÒSTIC OLLAMA LLM"
echo "========================================"
echo ""

echo "📊 Estat del contenidor Ollama:"
docker-compose -f docker-compose.llm.yml ps llm

echo ""
echo "📝 Logs d'Ollama (últimes 50 línies):"
docker-compose -f docker-compose.llm.yml logs --tail=50 llm

echo ""
echo "🔍 Provant connexió a Ollama:"
curl -s http://localhost:11434/api/tags || echo "❌ No es pot connectar"

echo ""
echo "========================================"
echo "  OPCIONS"
echo "========================================"
echo ""
echo "Opció A: Iniciar worker sense esperar LLM"
echo "  docker-compose -f docker-compose.llm.yml up -d --no-deps worker"
echo ""
echo "Opció B: Reiniciar Ollama"
echo "  docker-compose -f docker-compose.llm.yml restart llm"
echo ""
echo "Opció C: Utilitzar sistema sense LLM"
echo "  docker-compose up -d redis db api worker frontend"
