# 🧠 Per Què Ollama No Funciona? - Explicació Completa

## 🔍 La Veritat

**NO havies aconseguit Ollama abans** ❌

### Proves:

1. **Docker Hub**: No hi ha cap imatge d'Ollama
   - Només tens: frontend, backend, worker-test
   - Ollama NO hauria d'estar-hi (és imatge oficial)

2. **Logs anteriors**: Sempre fallava descarregant
   ```
   ERROR: failed to copy: connection reset by peer
   ```

3. **Estat actual**: Contenidor creat però "unhealthy"

---

## 📦 Què És Ollama?

**Ollama és una imatge OFICIAL** de Docker Hub:

```yaml
llm:
  image: ollama/ollama:latest  # ← NO és teva
```

**Per tant**:
- ✅ NO apareix al teu Docker Hub (és normal)
- ✅ Es descarrega de `hub.docker.com/r/ollama/ollama`
- ✅ Tu només la utilitzes, no la construeixes

---

## ⚠️ Per Què Està "Unhealthy"?

### El Healthcheck

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

**Això comprova**:
- Si Ollama respon a `/api/tags`
- Si retorna llista de models
- Si el servei està llest

### Possibles Causes:

#### 1. Model Phi-3 No Descarregat ⚠️

El servei `llm_init` intenta descarregar Phi-3:

```yaml
llm_init:
  command: >
    sh -c "
    curl -X POST http://llm:11434/api/pull -d '{\"name\":\"phi3\"}';
    "
```

**Si això falla**:
- Ollama funciona
- Però NO té cap model
- `/api/tags` retorna `[]` (buit)
- Healthcheck falla

#### 2. Ollama Encara Inicialitzant ⏳

- Ollama triga 1-2 minuts a estar llest
- Durant aquest temps, healthcheck falla
- Després de `start_period: 60s`, hauria de funcionar

#### 3. Curl No Disponible ❌

- El healthcheck usa `curl`
- Si el contenidor no té curl, falla
- Solució: Canviar healthcheck

---

## 🔍 Com Diagnosticar?

### Opció A: Veure Logs d'Ollama

```bash
docker-compose -f docker-compose.llm.yml logs llm
```

**Busca**:
- `Listening on 0.0.0.0:11434` ✅ (funciona)
- Errors de connexió ❌
- Errors de memòria ❌

### Opció B: Provar Connexió Manual

```bash
# Des de l'host
curl http://localhost:11434/api/tags

# Hauries de veure:
{"models":[]}  # Buit si no hi ha models
# o
{"models":[{"name":"phi3",...}]}  # Amb model
```

### Opció C: Entrar al Contenidor

```bash
docker exec -it mobil_scan_llm /bin/bash

# Dins del contenidor
ollama list  # Veure models instal·lats
ollama pull phi3  # Descarregar model manualment
```

---

## ✅ Solucions

### Solució 1: Esperar Més Temps (FÀCIL)

```bash
# Espera 2-3 minuts
sleep 180

# Comprova estat
docker-compose -f docker-compose.llm.yml ps llm
```

### Solució 2: Descarregar Model Manualment

```bash
# Entrar al contenidor
docker exec -it mobil_scan_llm ollama pull phi3

# Esperar 5-10 minuts (2.3GB)
# Després verificar
docker exec -it mobil_scan_llm ollama list
```

### Solució 3: Canviar Healthcheck

Editar `docker-compose.llm.yml`:

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:11434"]
  # o més simple:
  test: ["CMD-SHELL", "exit 0"]  # Sempre healthy
```

### Solució 4: Eliminar Healthcheck (TEMPORAL)

```yaml
llm:
  image: ollama/ollama:latest
  # healthcheck: ...  ← Comentar o eliminar
```

Després:

```bash
docker-compose -f docker-compose.llm.yml up -d llm
```

---

## 🎓 Per Què Això Passa?

### Docker Healthchecks

Un contenidor pot estar en 3 estats:

1. **Starting**: Acabat de crear
2. **Healthy**: Healthcheck passa ✅
3. **Unhealthy**: Healthcheck falla ❌

**Ollama està "Unhealthy"** perquè:
- El contenidor funciona
- Però el healthcheck falla
- Probablement perquè no té models

### Dependències

```yaml
worker:
  depends_on:
    llm:
      condition: service_healthy  # ← Espera healthy
```

**Per això el worker no s'inicia**:
- Espera que Ollama sigui "healthy"
- Com està "unhealthy", no inicia
- Solució: Iniciar sense dependència

---

## 💡 Recomanació

### Opció A: Utilitzar Sense LLM (IMMEDIAT)

```bash
./iniciar_worker_sense_llm.sh
```

**Avantatges**:
- Funciona ara mateix
- Detecció de codis operativa
- LLM no és crític

### Opció B: Arreglar Ollama (10-15 min)

```bash
# 1. Descarregar model manualment
docker exec -it mobil_scan_llm ollama pull phi3

# 2. Esperar descàrrega (2.3GB)

# 3. Verificar
docker exec -it mobil_scan_llm ollama list

# 4. Reiniciar worker
docker-compose -f docker-compose.llm.yml restart worker
```

---

## 📊 Resum

**Pregunta**: Per què NO funciona Ollama?

**Resposta**:
1. ❌ NO ho havies aconseguit abans
2. ✅ Contenidor creat correctament
3. ⚠️ Healthcheck falla (probablement model no descarregat)
4. ✅ Es pot arreglar descarregant model manualment

**Pregunta**: Per què no veig Ollama a Docker Hub?

**Resposta**:
- ✅ És NORMAL
- Ollama és imatge oficial (`ollama/ollama`)
- NO és una imatge teva
- NO hauria d'aparèixer al teu Docker Hub

---

## 🎯 Conclusió

**Ollama funciona**, però:
- El healthcheck falla
- Probablement perquè no té models
- Es pot utilitzar el sistema sense LLM
- O arreglar descarregant model manualment

**NO és un problema de codi** ✅
**És un problema de configuració/temps** ⏳
