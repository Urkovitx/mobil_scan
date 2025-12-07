#!/bin/bash

echo "========================================"
echo "  INICIAR WORKER SENSE ESPERAR LLM"
echo "========================================"
echo ""

echo "ℹ️  El worker funcionarà sense LLM"
echo "   (Detecció de codis funcionarà, però sense respostes intel·ligents)"
echo ""

echo "🚀 Iniciant worker..."
docker-compose -f docker-compose.llm.yml up -d --no-deps worker

echo ""
echo "⏳ Esperant 5 segons..."
sleep 5

echo ""
echo "📊 Estat del worker:"
docker-compose -f docker-compose.llm.yml ps worker

echo ""
echo "📝 Logs del worker (últimes 20 línies):"
docker-compose -f docker-compose.llm.yml logs --tail=20 worker

echo ""
echo "========================================"
echo "  WORKER INICIAT!"
echo "========================================"
echo ""
echo "Ver logs en temps real:"
echo "  docker-compose -f docker-compose.llm.yml logs -f worker"
echo ""
echo "Si veus errors, comprova:"
echo "  1. Redis està funcionant: docker-compose -f docker-compose.llm.yml ps redis"
echo "  2. PostgreSQL està funcionant: docker-compose -f docker-compose.llm.yml ps db"
