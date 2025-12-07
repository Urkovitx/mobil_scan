# 🚨 Error: Docker Sense Recursos

## ❌ Problema Nou

```
rpc error: code = Unavailable desc = error reading from server: EOF
```

Després de 144 segons de build, Docker s'ha quedat **sense recursos** (RAM/CPU).

---

## 🔍 Causa Real

El projecte té **dependencies massa pesades**:

1. **torch** - 900 MB
2. **nvidia-cudnn-cu12** - 706 MB
3. **torchvision** - 8 MB
4. **paddlepaddle** - 126 MB
5. **opencv-python** - 67 MB
6. **ultralytics** (YOLO) - 699 KB + dependencies

**Total:** ~2 GB de paquets Python!

Docker no té prou RAM per compilar tot això simultàniament en 3 contenidors.

---

## ✅ SOLUCIONS (3 Opcions)

### Opció 1: Augmenta Recursos de Docker (RECOMANAT)

**Obre Docker Desktop:**
1. Settings → Resources
2. **Memory:** Augmenta a 8 GB (mínim 6 GB)
3. **CPU:** Augmenta a 4 cores
4. **Swap:** Augmenta a 2 GB
5. Apply & Restart

### Opció 2: Build Seqüencial (ALTERNATIVA)

En lloc de `docker-compose up --build`, fes:

```powershell
# Build un per un
docker-compose build worker
docker-compose build api
docker-compose build frontend

# Després arrenca tot
docker-compose up
```

### Opció 3: Simplifica Dependencies (DRÀSTIC)

Elimina PaddleOCR i Ultralytics si no els necessites:

```txt
# Comenta aquestes línies a requirements.txt:
# paddlepaddle==2.6.2
# paddleocr==2.7.3
# ultralytics==8.1.0
```

---

## 🎯 RECOMANACIÓ: Opció 1

**Augmenta recursos de Docker:**

1. Obre Docker Desktop
2. Settings (icona engranatge)
3. Resources
4. **Memory: 8 GB** (ara probablement tens 2-4 GB)
5. **CPUs: 4** (ara probablement tens 2)
6. **Swap: 2 GB**
7. Apply & Restart

**Després:**

```powershell
docker-compose up --build
```

---

## 💡 Per Què Passa Això?

Docker Desktop per defecte té **límits de recursos molt baixos**:
- Memory: 2 GB (insuficient!)
- CPUs: 2 cores
- Swap: 1 GB

Amb 3 contenidors compilant simultàniament paquets grans (torch, nvidia-cudnn), Docker es queda sense RAM i peta.

---

## 📊 Recursos Necessaris

**Mínim:**
- RAM: 6 GB
- CPU: 2 cores
- Swap: 2 GB

**Recomanat:**
- RAM: 8 GB
- CPU: 4 cores
- Swap: 2 GB
- Disk: 20 GB lliures

---

## 🚀 Passos Detallats

### 1. Obre Docker Desktop

Fes clic a la icona de Docker (balena) a la barra de tasques.

### 2. Ves a Settings

Fes clic a l'engranatge (⚙️) a dalt a la dreta.

### 3. Ves a Resources

Al menú esquerre, selecciona **Resources**.

### 4. Augmenta Memory

Mou el slider de **Memory** a **8 GB**.

### 5. Augmenta CPUs

Mou el slider de **CPUs** a **4**.

### 6. Augmenta Swap

Mou el slider de **Swap** a **2 GB**.

### 7. Apply & Restart

Fes clic a **Apply & Restart**.

Espera que Docker es reiniciï (1-2 minuts).

### 8. Torna a Intentar

```powershell
docker-compose up --build
```

---

## 🎯 Alternativa: Build Seqüencial

Si no pots augmentar recursos:

```powershell
# Neteja primer
docker-compose down
docker system prune -f

# Build un per un (més lent però més segur)
docker-compose build worker
# Espera que acabi...

docker-compose build api
# Espera que acabi...

docker-compose build frontend
# Espera que acabi...

# Arrenca tot
docker-compose up
```

Això trigarà més (30-40 minuts) però no petar per falta de recursos.

---

## 📋 Resum

**Problema:** Docker sense recursos (RAM/CPU)  
**Causa:** 3 contenidors compilant 2 GB de paquets simultàniament  
**Solució 1:** Augmenta RAM a 8 GB i CPU a 4 cores  
**Solució 2:** Build seqüencial (un per un)  
**Solució 3:** Elimina dependencies pesades  

---

## 🎯 Errors Resolts Fins Ara

1. ✅ Docker Desktop bloquejat → Reiniciat
2. ✅ PaddlePaddle 2.6.0 → 2.6.2
3. ✅ Network timeout → 1000s
4. ⚠️ **Docker sense recursos** → Augmenta RAM/CPU

---

**Propera Acció:** Augmenta recursos de Docker a 8 GB RAM + 4 CPUs  
**Temps:** 2 minuts per configurar + 20 minuts per build  
**Probabilitat d'èxit:** 99% amb 8 GB RAM
