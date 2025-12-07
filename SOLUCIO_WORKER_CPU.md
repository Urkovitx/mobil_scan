# 🔧 Solució Worker - PyTorch CPU

## 🎯 El Problema

El worker estava fallant durant el build amb aquest error:

```
ERROR: failed to copy: read tcp ... connection reset by peer
BrokenPipeError: [Errno 32] Broken pipe
```

**Causa**: ultralytics intentava descarregar PyTorch amb CUDA (706MB + 88MB de paquets NVIDIA), i la connexió es tallava.

---

## ✅ La Solució

Utilitzar **PyTorch CPU** en lloc de CUDA:

### Avantatges PyTorch CPU:
- ✅ **Molt més lleuger** (~200MB vs ~800MB)
- ✅ **Descàrrega més ràpida** (2-3 min vs 10-15 min)
- ✅ **Més estable** (menys errors de xarxa)
- ✅ **Suficient per CPU** (no necessites GPU per aquest projecte)

---

## 🚀 Com Aplicar la Solució

### A la Terminal Ubuntu:

```bash
# 1. Donar permisos
chmod +x rebuild_worker_cpu.sh

# 2. Executar rebuild
./rebuild_worker_cpu.sh
```

**Temps**: 5-10 minuts

---

## 📋 Què Fa l'Script?

1. Atura el worker antic
2. Elimina la imatge antiga
3. Construeix amb `Dockerfile.cpu`:
   - Instal·la PyTorch CPU primer
   - Després instal·la ultralytics (ja no descarrega CUDA)
4. Inicia el nou worker
5. Mostra l'estat

---

## 🔍 Diferències Dockerfile.cpu

### ❌ Abans (Dockerfile.ultra-minimal):
```dockerfile
# Instal·lava ultralytics directament
RUN pip install ultralytics==8.0.196
# ↓ Això descarregava PyTorch amb CUDA automàticament
```

### ✅ Ara (Dockerfile.cpu):
```dockerfile
# Instal·la PyTorch CPU PRIMER
RUN pip install --no-cache-dir \
    torch==2.0.1+cpu \
    torchvision==0.15.2+cpu \
    --index-url https://download.pytorch.org/whl/cpu

# Després instal·la ultralytics
RUN pip install ultralytics==8.0.196
# ↓ Ara ja no descarrega CUDA perquè PyTorch CPU ja està
```

---

## 📊 Comparació

| Aspecte | CUDA | CPU |
|---------|------|-----|
| Mida descàrrega | ~800MB | ~200MB |
| Temps build | 15-20 min | 5-10 min |
| Errors xarxa | Freqüents | Rars |
| Rendiment GPU | ⚡ Ràpid | - |
| Rendiment CPU | - | ✅ Bo |
| Necessita GPU | Sí | No |

---

## 🎓 Per Què Funciona?

**El problema original**:
1. ultralytics depèn de PyTorch
2. PyTorch per defecte instal·la versió CUDA
3. CUDA són 800MB de paquets NVIDIA
4. Connexió es talla descarregant tant

**La solució**:
1. Instal·lem PyTorch CPU primer (200MB)
2. ultralytics veu que PyTorch ja està instal·lat
3. No intenta descarregar CUDA
4. Build completa sense errors

---

## ✅ Verificar que Funciona

Després del rebuild:

```bash
# Ver logs del worker
docker-compose -f docker-compose.llm.yml logs -f worker

# Hauries de veure:
# ✅ YOLOv8 model loaded
# ✅ Supervision annotators initialized
# ✅ zxing-cpp available
# 👂 Listening for jobs on 'video_queue'...
```

---

## 🔄 Si Encara Falla

### Opció A: Retry amb més timeout

```bash
# Edita Dockerfile.cpu i afegeix timeout més llarg:
RUN pip install --no-cache-dir --timeout=2000 \
    torch==2.0.1+cpu \
    torchvision==0.15.2+cpu \
    --index-url https://download.pytorch.org/whl/cpu
```

### Opció B: Descarregar manualment

```bash
# Descarrega wheels localment i copia al contenidor
wget https://download.pytorch.org/whl/cpu/torch-2.0.1%2Bcpu-cp310-cp310-linux_x86_64.whl
```

### Opció C: Utilitzar imatge pre-built

```bash
# Utilitza una imatge Docker que ja té PyTorch
FROM pytorch/pytorch:2.0.1-cpu-py3.10-ubuntu20.04
```

---

## 📝 Notes Importants

### Rendiment CPU vs GPU

**Per aquest projecte (detecció de codis de barres)**:
- CPU és **suficient** ✅
- GPU seria més ràpid però **no necessari**
- La majoria del temps és I/O (llegir vídeo), no càlcul

### Quan Necessitaries GPU?

- Processar 100+ vídeos simultàniament
- Vídeos 4K de llarga durada
- Detecció en temps real (webcam)
- Models molt grans (>100M paràmetres)

**Per aquest cas d'ús**: CPU és perfecte! 👍

---

## 🎯 Resum

**Problema**: Build fallava descarregant CUDA (800MB)
**Solució**: Utilitzar PyTorch CPU (200MB)
**Resultat**: Build ràpid i estable ✅

**Executa**:
```bash
chmod +x rebuild_worker_cpu.sh && ./rebuild_worker_cpu.sh
```

**I ja està!** 🎉
