#!/bin/bash

echo "========================================"
echo "  REBUILD WORKER AMB PyTorch CPU"
echo "========================================"
echo ""

echo "🛑 Aturant worker antic..."
docker-compose -f docker-compose.llm.yml stop worker
docker-compose -f docker-compose.llm.yml rm -f worker

echo ""
echo "🗑️  Eliminant imatge antiga..."
docker rmi mobil_scan_worker 2>/dev/null || true

echo ""
echo "🔨 Construint worker amb PyTorch CPU..."
echo "   (Això trigarà 5-10 minuts)"
echo ""

docker-compose -f docker-compose.llm.yml build --no-cache worker

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Worker construït correctament!"
    echo ""
    echo "🚀 Iniciant worker..."
    docker-compose -f docker-compose.llm.yml up -d worker
    
    echo ""
    echo "📊 Estat dels serveis:"
    docker-compose -f docker-compose.llm.yml ps
    
    echo ""
    echo "========================================" 
    echo "  WORKER LLEST!"
    echo "========================================"
    echo ""
    echo "Ver logs: docker-compose -f docker-compose.llm.yml logs -f worker"
else
    echo ""
    echo "❌ Error construint worker"
    echo ""
    echo "Revisa els logs per més detalls"
fi
