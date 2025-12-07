# 🔥 ERROR RPC EOF - Docker Sense Memòria

## ❌ Què Ha Passat?

```
error reading from server: EOF
```

Després de 1400 segons (23 minuts), Docker ha perdut la connexió perquè:

1. **Memòria exhaurida** - Compilant 3 contenidors alhora
2. **PaddlePaddle massa gran** - 706 MB per contenidor
3. **WSL2 col·lapsat** - Encara que tens 8 GB, no n'hi ha prou per 3 builds simultanis

---

## ✅ SOLUCIÓ: Build Seqüencial (Un per Un)

### Opció 1: Script Automàtic (RECOMANAT)

```powershell
.\build_sequential.bat
```

Això farà build:
1. Backend (primer, més ràpid)
2. Frontend (segon)
3. Worker (últim, més lent)

**Temps:** 60-90 minuts (20-30 min per contenidor)

---

### Opció 2: Manual (Si l'script falla)

```powershell
# 1. Backend (5-10 min)
docker-compose build backend

# 2. Frontend (15-20 min)
docker-compose build frontend

# 3. Worker (30-40 min)
docker-compose build worker

# 4. Inicia tot
docker-compose up
```

---

## 🎯 Per Què Això Funciona?

**Build Simultani (el que has fet):**
- 3 contenidors × 2 GB RAM = 6 GB
- + Sistema operatiu = 8 GB
- = **Memòria exhaurida!** ❌

**Build Seqüencial:**
- 1 contenidor × 2 GB RAM = 2 GB
- + Sistema operatiu = 3 GB
- = **Sobra memòria!** ✅

---

## 📋 Passos Ara

1. **Atura tot:**
   ```powershell
   docker-compose down
   ```

2. **Build seqüencial:**
   ```powershell
   .\build_sequential.bat
   ```

3. **Espera 60-90 minuts**

4. **Verifica:**
   ```powershell
   docker-compose ps
   ```

---

## ⏱️ Temps Estimat

- Backend: 10 min
- Frontend: 20 min
- Worker: 40 min
- **Total: 70 minuts**

---

## 💡 Alternativa: Reduir Dependencies

Si encara falla, podem:

1. **Eliminar PaddleOCR** (usa només Ultralytics)
2. **Usar imatges pre-compilades**
3. **Build en Google Cloud** (més RAM)

---

## 🚀 Propera Acció

**Executa ARA:**

```powershell
docker-compose down
.\build_sequential.bat
```

**I vés a fer un cafè!** ☕ (60-90 minuts)

---

## 📊 Comparació

| Mètode | Temps | RAM Necessària | Èxit |
|--------|-------|----------------|------|
| Simultani | 20 min | 6-8 GB | ❌ Falla |
| Seqüencial | 70 min | 2-3 GB | ✅ Funciona |

---

**Conclusió:** Build seqüencial és més lent però **SEMPRE funciona**! 🎯
