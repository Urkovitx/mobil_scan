# 🔧 Solució Error Build - "error reading from server: EOF"

## 🎯 Problema Detectat

El build ha fallat amb:
```
failed to solve: Unavailable: error reading from server: EOF
```

Aquest error indica que la connexió s'ha interromput durant la descàrrega/compilació de zxing-cpp.

---

## 🚀 Solucions Ordenades per Prioritat

### ✅ Solució 1: Utilitzar Script amb Retry (RECOMANAT)

He creat un script que reintenta el build automàticament:

```batch
REBUILD_WORKER_RETRY.bat
```

Aquest script:
- Fa 3 intents automàtics
- Neteja entre intents
- Gestiona millor els timeouts

---

### ✅ Solució 2: Augmentar Recursos de Docker

El problema pot ser per falta de recursos durant la compilació.

#### Passos:

1. **Obre Docker Desktop**
2. **Settings → Resources**
3. **Augmenta**:
   - **Memory**: 6 GB (mínim 4 GB)
   - **CPUs**: 4 cores (mínim 2)
   - **Disk**: Assegura't que tens 20+ GB lliures
4. **Apply & Restart**
5. **Torna a intentar**: `REBUILD_WORKER_RETRY.bat`

---

### ✅ Solució 3: Neteja Completa de Docker

Pot haver-hi problemes amb la caché corrupta.

```batch
# Aturar tots els contenidors
docker-compose down

# Neteja completa
docker system prune -a --volumes

# Confirma amb 'y'

# Rebuild
REBUILD_WORKER_RETRY.bat
```

⚠️ **ATENCIÓ**: Això eliminarà TOTES les imatges i volums no utilitzats.

---

### ✅ Solució 4: Build Manual Pas a Pas

Si els scripts fallen, prova build manual:

#### Pas 1: Compilar C++ localment (fora de Docker)

```bash
# Instal·la dependències (si no les tens)
# Windows: Instal·la Visual Studio Build Tools o MinGW

cd worker/cpp_scanner
mkdir build
cd build

# Configura
cmake ..

# Compila
cmake --build .

# Verifica
./bin/barcode_test
```

Si això funciona, el problema és de Docker, no del codi.

#### Pas 2: Build Docker sense C++ (temporal)

Crea un `worker/Dockerfile.simple`:

```dockerfile
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Només runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       ffmpeg \
       libgl1 \
       libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Python requirements
COPY ./worker/requirements-worker.txt ./
RUN pip install --no-cache-dir --default-timeout=1000 -r requirements-worker.txt

# Application code
COPY ./worker/processor.py ./
COPY ./shared/database.py ./

RUN mkdir -p /app/videos /app/frames /app/results /app/models

CMD ["python", "processor.py"]
```

Build amb aquest Dockerfile:
```bash
docker build -f worker/Dockerfile.simple -t mobil_scan-worker .
```

Això et permetrà tenir el worker funcionant mentre soluciones el problema del C++.

---

### ✅ Solució 5: Descarregar zxing-cpp Manualment

Si el problema és la descàrrega de GitHub:

#### Opció A: Descarregar ZIP

1. Descarrega: https://github.com/zxing-cpp/zxing-cpp/archive/refs/tags/v2.2.1.zip
2. Descomprimeix a `worker/cpp_scanner/zxing-cpp-2.2.1/`
3. Modifica `CMakeLists.txt`:

```cmake
# Comenta FetchContent
# FetchContent_Declare(...)

# Afegeix directament
add_subdirectory(zxing-cpp-2.2.1 EXCLUDE_FROM_ALL)
```

#### Opció B: Git Clone Manual

```bash
cd worker/cpp_scanner
git clone --depth 1 --branch v2.2.1 https://github.com/zxing-cpp/zxing-cpp.git
```

Després modifica `CMakeLists.txt` com a l'Opció A.

---

### ✅ Solució 6: Utilitzar Imatge Pre-compilada (Workaround)

Si res funciona, pots utilitzar només els Python bindings (sense component C++):

1. **Elimina** la compilació C++ del Dockerfile
2. **Mantén** només `zxing-cpp>=2.2.0` a requirements
3. El worker funcionarà amb els Python bindings

Modifica `worker/Dockerfile`:

```dockerfile
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       ffmpeg \
       libgl1 \
       libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Python requirements (inclou zxing-cpp Python bindings)
COPY ./worker/requirements-worker.txt ./
RUN pip install --no-cache-dir --default-timeout=1000 -r requirements-worker.txt

# Application code
COPY ./worker/processor.py ./
COPY ./shared/database.py ./

RUN mkdir -p /app/videos /app/frames /app/results /app/models

CMD ["python", "processor.py"]
```

Això et dona zxing-cpp v2.2.0+ via Python, que és el més important.

---

### ✅ Solució 7: Verificar Connexió i Proxy

El problema pot ser de xarxa:

```bash
# Test connexió a GitHub
ping github.com

# Test descàrrega
curl -I https://github.com/zxing-cpp/zxing-cpp/archive/refs/tags/v2.2.1.tar.gz

# Si estàs darrere d'un proxy, configura Docker:
# Docker Desktop → Settings → Resources → Proxies
```

---

### ✅ Solució 8: Reiniciar Docker Desktop

A vegades Docker Desktop té problemes interns:

1. **Tanca Docker Desktop completament**
2. **Obre Task Manager** (Ctrl+Shift+Esc)
3. **Finalitza** tots els processos "Docker"
4. **Reinicia Docker Desktop**
5. **Espera** que estigui completament iniciat
6. **Prova**: `REBUILD_WORKER_RETRY.bat`

---

## 🎯 Recomanació Immediata

**Prova en aquest ordre**:

1. ✅ **REBUILD_WORKER_RETRY.bat** (3 intents automàtics)
2. ✅ **Augmentar recursos** de Docker (6GB RAM, 4 CPUs)
3. ✅ **Neteja Docker**: `docker system prune -a`
4. ✅ **Reiniciar Docker Desktop**
5. ✅ **Solució 6** (només Python bindings) com a workaround temporal

---

## 📊 Diagnòstic

Per entendre millor el problema:

```bash
# Veure logs complets del build
docker-compose build worker 2>&1 | tee build.log

# Veure recursos de Docker
docker system df

# Veure memòria disponible
docker info | findstr Memory

# Veure processos
docker ps -a
```

---

## 🆘 Si Res Funciona

Si cap solució funciona:

1. **Utilitza Solució 6** (només Python bindings)
2. El worker funcionarà perfectament amb `zxing-cpp>=2.2.0` via Python
3. El component C++ és un extra per testing, no és essencial

El més important és que tinguis **zxing-cpp v2.2.0+** funcionant, i això ho aconsegueixes amb els Python bindings.

---

## ✅ Verificació Final

Quan el build funcioni:

```bash
# Verificar Python bindings
docker-compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"

# Verificar worker
docker-compose logs worker

# Test complet
TEST_CPP_SCANNER.bat
```

---

**Recorda**: L'objectiu principal és tenir zxing-cpp v2.2.0+ funcionant. Els Python bindings són suficients per a això!
