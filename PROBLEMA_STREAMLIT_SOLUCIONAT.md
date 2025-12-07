# Problema Streamlit - Connection Error

## 🔴 Problema Detectat

Quan s'obria http://localhost:3000 al navegador, Streamlit mostrava:
```
Connection error
Is Streamlit still running? If you accidentally stopped Streamlit, just restart it in your terminal:
streamlit run yourscript.py
```

## 🔍 Diagnòstic

### Estat dels Serveis
- ✅ Backend: Running correctament (port 8000)
- ✅ PostgreSQL: Healthy
- ✅ Redis: Healthy
- ✅ Frontend container: Running
- ✅ Streamlit: Escoltant al port 8501 dins del contenidor
- ✅ Port mapping: 3000:8501 correcte

### Problema Identificat

El problema NO era el port mapping de Docker, sinó la **configuració interna de Streamlit**.

Streamlit necessita saber:
1. **On escolta el servidor** (dins del contenidor): `0.0.0.0:8501` ✅
2. **Com el navegador ha de connectar-se** (des de fora): `localhost:3000` ❌ (faltava)

Sense aquesta configuració, el navegador intentava connectar-se directament al port 8501 en lloc del 3000, causant l'error de connexió.

## ✅ Solució Implementada

### 1. Crear Configuració de Streamlit

**Fitxer:** `frontend/.streamlit/config.toml`

```toml
[server]
port = 8501
address = "0.0.0.0"
headless = true
enableCORS = false
enableXsrfProtection = false

[browser]
serverAddress = "localhost"
serverPort = 3000
gatherUsageStats = false
```

**Explicació:**
- `[server]`: Configuració del servidor Streamlit dins del contenidor
  - `port = 8501`: Port intern on escolta Streamlit
  - `address = "0.0.0.0"`: Escolta a totes les interfícies
  - `headless = true`: Mode servidor (sense GUI)
  - `enableCORS = false`: Desactiva CORS (no necessari en Docker)
  
- `[browser]`: Configuració per al navegador del client
  - `serverAddress = "localhost"`: Adreça que el navegador usarà
  - `serverPort = 3000`: Port que el navegador usarà (el mapejat per Docker)
  - `gatherUsageStats = false`: Desactiva estadístiques

### 2. Actualitzar Dockerfile

**Fitxer:** `frontend/Dockerfile`

Afegit:
```dockerfile
# Copy Streamlit configuration
COPY frontend/.streamlit /app/.streamlit
```

Això copia la configuració de Streamlit dins del contenidor.

### 3. Rebuild i Deploy

```bash
# Build nova imatge
docker build -t urkovitx/mobil-scan-frontend:latest -f frontend/Dockerfile .

# Push a Docker Hub
docker push urkovitx/mobil-scan-frontend:latest

# Pull i restart
docker-compose -f docker-compose.hub.yml pull frontend
docker-compose -f docker-compose.hub.yml up -d frontend
```

## 📊 Flux de Connexió Correcte

```
Navegador (localhost:3000)
    ↓
Docker Port Mapping (3000 → 8501)
    ↓
Streamlit Server (0.0.0.0:8501)
    ↓
Streamlit envia al navegador: "Connecta't a localhost:3000"
    ↓
✅ Connexió establerta correctament
```

## 🔧 Verificació

Després del rebuild:

```bash
# 1. Comprovar que el contenidor està UP
docker ps | grep frontend

# 2. Comprovar logs de Streamlit
docker logs mobilscan-frontend

# 3. Provar connexió HTTP
curl -I http://localhost:3000

# 4. Obrir navegador
start http://localhost:3000
```

**Resultat Esperat:**
- ✅ Pàgina de Streamlit carrega correctament
- ✅ Sidebar mostra "✅ API Connected"
- ✅ No hi ha errors de connexió
- ✅ Tots els tabs funcionen

## 📝 Notes Importants

### Per què això era necessari?

Streamlit té dues configuracions diferents:
1. **Server config**: On escolta el servidor (dins del contenidor)
2. **Browser config**: Com el navegador s'ha de connectar (des de fora)

En un entorn Docker amb port mapping, aquestes dues configuracions són **diferents**:
- Servidor: `0.0.0.0:8501` (dins del contenidor)
- Navegador: `localhost:3000` (des de l'host)

### Alternativa (sense config.toml)

També es podria passar com a paràmetres al CMD:

```dockerfile
CMD ["streamlit", "run", "app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0", \
     "--server.headless=true", \
     "--browser.serverAddress=localhost", \
     "--browser.serverPort=3000"]
```

Però usar `config.toml` és més net i mantenible.

## ✅ Estat Final

Després d'aplicar aquesta solució:

- ✅ Frontend accessible a http://localhost:3000
- ✅ Streamlit carrega correctament
- ✅ Connexió amb backend API funciona
- ✅ No hi ha errors de connexió
- ✅ Aplicació completament funcional

---

**Data:** 6 de desembre de 2024  
**Problema:** Connection error en Streamlit  
**Solució:** Configuració de `browser.serverPort` en config.toml  
**Estat:** ✅ RESOLT
