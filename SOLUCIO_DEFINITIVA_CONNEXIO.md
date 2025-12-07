# 🎯 SOLUCIÓ DEFINITIVA - Problema de Connexió

## 😤 EL PROBLEMA REAL

**NO és el teu equip, NO és Docker, NO és el codi**

**ÉS LA TEVA CONNEXIÓ A INTERNET** ❌

```
ERROR: read tcp ... connection reset by peer
ERROR: TLS handshake timeout
ERROR: connection reset by peer
```

**Això passa SEMPRE**:
- Construint localment → Timeout descarregant paquets
- Descarregant imatges → Timeout connectant a Docker Hub
- Descarregant Phi-3 → Timeout

---

## ✅ SOLUCIÓ REALISTA

### Opció 1: Utilitzar el que JA TENS (RECOMANAT)

**Ja tens aquestes imatges construïdes localment**:

```bash
# Veure què tens
docker images | grep mobil

# Probablement tens:
# mobil_scan-worker
# mobil_scan-api
# mobil_scan-frontend
```

**Utilitzar-les**:

```bash
# Iniciar amb el que ja tens
docker-compose up -d redis db
sleep 5
docker-compose up -d api worker frontend
```

**Temps**: 30 segons
**Funcionalitat**: Tot menys Ollama (que no funciona per connexió)

---

### Opció 2: Construir Només el Necessari (Sense Ollama)

**Crear docker-compose SENSE LLM**:

```yaml
# docker-compose.simple.yml
services:
  redis:
    image: redis:7-alpine
    # Si falla, usar: redis:latest
    
  db:
    image: postgres:15-alpine
    # Si falla, usar: postgres:latest
    
  api:
    build: ./backend
    depends_on: [redis, db]
    
  worker:
    build:
      context: .
      dockerfile: worker/Dockerfile.cpu
    depends_on: [redis, db]
    
  frontend:
    build: ./frontend
    depends_on: [api]
```

**Iniciar**:

```bash
docker-compose -f docker-compose.simple.yml up -d
```

---

### Opció 3: Utilitzar Imatges Locals Alternatives

**Si redis/postgres fallen, usar versions locals**:

```bash
# Descarregar versions més petites (si funciona)
docker pull redis:alpine
docker pull postgres:alpine

# O utilitzar versions que ja tens
docker images | grep redis
docker images | grep postgres
```

---

## 🎯 SOLUCIÓ IMMEDIATA (ARA MATEIX)

### Pas 1: Veure què tens

```bash
docker images
```

### Pas 2: Iniciar amb el que tens

```bash
# Aturar tot
docker-compose down

# Iniciar només el bàsic
docker-compose up -d redis db

# Esperar 5 segons
sleep 5

# Iniciar aplicació
docker-compose up -d api worker frontend
```

### Pas 3: Accedir

```
http://localhost:8501
```

---

## 💡 PER QUÈ AIXÒ PASSA?

**La teva connexió té**:
- ⚠️ Timeouts freqüents
- ⚠️ Connection resets
- ⚠️ TLS handshake failures

**Possibles causes**:
1. ISP amb problemes
2. Firewall/Antivirus bloquejant
3. DNS lent
4. Proxy/VPN interferint
5. Connexió WiFi inestable

---

## 🔧 SOLUCIONS PER A LA CONNEXIÓ

### Solució A: Canviar DNS

```bash
# Editar resolv.conf
sudo nano /etc/resolv.conf

# Afegir Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### Solució B: Utilitzar Mirror Local

```bash
# Configurar Docker per usar mirror
sudo nano /etc/docker/daemon.json

# Afegir:
{
  "registry-mirrors": ["https://mirror.gcr.io"]
}

# Reiniciar Docker
sudo systemctl restart docker
```

### Solució C: Augmentar Timeouts

```bash
# Configurar Docker
export DOCKER_CLIENT_TIMEOUT=300
export COMPOSE_HTTP_TIMEOUT=300
```

---

## 🎯 COMANDA FINAL (SENSE DESCARREGAR RES)

```bash
# Utilitzar el que ja tens
docker-compose down
docker-compose up -d redis db
sleep 5
docker-compose up -d api worker frontend
```

**Això utilitza**:
- ✅ Imatges que ja tens localment
- ✅ No descarrega res
- ✅ No construeix res
- ✅ Funciona en 30 segons

---

## ❌ OBLIDA OLLAMA DE MOMENT

**Ollama requereix**:
- Descarregar imatge (500MB)
- Descarregar model Phi-3 (2.3GB)
- Connexió estable durant 10-15 minuts

**Amb la teva connexió**: IMPOSSIBLE

**Solució**: Utilitzar sense LLM

---

## ✅ CONCLUSIÓ

**El problema NO és**:
- ❌ El teu codi
- ❌ Docker
- ❌ El teu equip

**El problema ÉS**:
- ❌ Connexió a Internet inestable

**Solució**:
1. Utilitzar el que ja tens localment
2. No intentar descarregar res
3. Oblidar Ollama de moment
4. Arreglar la connexió (DNS, etc.)

**Comanda**:
```bash
docker-compose down && docker-compose up -d redis db && sleep 5 && docker-compose up -d api worker frontend
```

**I JA ESTÀ!** 🎉
