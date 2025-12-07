#!/bin/bash

echo "========================================"
echo "  INICIAR AMB IMATGES LOCALS"
echo "  (Sense descarregar res)"
echo "========================================"
echo ""

# Aturar tot
echo "[Pas 1/4] Aturant serveis antics..."
docker-compose down 2>/dev/null
echo "✅ Serveis aturats"
echo ""

# Veure què tens
echo "[Pas 2/4] Verificant imatges locals..."
echo ""
echo "Imatges disponibles:"
docker images | grep -E "redis|postgres|mobil" || echo "  (buscant...)"
echo ""

# Iniciar serveis base
echo "[Pas 3/4] Iniciant Redis + PostgreSQL..."
echo "  (utilitzant imatges locals si estan disponibles)"

# Intentar iniciar redis i db
docker-compose up -d redis db 2>/dev/null

if [ $? -ne 0 ]; then
    echo "⚠️  Error iniciant redis/postgres"
    echo "   Provant amb versions alternatives..."
    
    # Crear contenidors manualment amb imatges locals
    docker run -d --name mobil_scan_redis \
        --network mobil_scan_mobil_network \
        -p 6379:6379 \
        redis:alpine 2>/dev/null || \
    docker run -d --name mobil_scan_redis \
        --network mobil_scan_mobil_network \
        -p 6379:6379 \
        redis:latest 2>/dev/null
    
    docker run -d --name mobil_scan_db \
        --network mobil_scan_mobil_network \
        -p 5432:5432 \
        -e POSTGRES_USER=mobilscan \
        -e POSTGRES_PASSWORD=mobilscan123 \
        -e POSTGRES_DB=mobilscan_db \
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
echo "✅ Serveis base iniciats"
echo ""

# Iniciar aplicació
echo "[Pas 4/4] Iniciant aplicació..."
docker-compose up -d api worker frontend 2>/dev/null

if [ $? -ne 0 ]; then
    echo "⚠️  Alguns serveis poden no haver iniciat"
    echo "   Verificant estat..."
fi

echo ""

# Mostrar estat
echo "========================================"
echo "  ESTAT DELS SERVEIS"
echo "========================================"
echo ""
docker-compose ps 2>/dev/null || docker ps
echo ""

# Informació final
echo "========================================"
echo "  RESULTAT"
echo "========================================"
echo ""
echo "🌐 Aplicació: http://localhost:8501"
echo "🔌 API: http://localhost:8000"
echo ""
echo "COMANDES ÚTILS:"
echo "  Ver logs:     docker-compose logs -f"
echo "  Ver worker:   docker-compose logs -f worker"
echo "  Aturar:       docker-compose down"
echo ""
echo "ℹ️  Aquest mètode utilitza només imatges locals"
echo "   NO descarrega res d'Internet"
