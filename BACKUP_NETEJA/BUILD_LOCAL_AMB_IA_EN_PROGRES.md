# 🔨 Build Local amb IA - En Progrés

## ✅ Què S'està Compilant Ara

El script `REBUILD_COMPLET_AMB_IA.bat` està executant:

### Fase 1: Neteja
- [x] Aturar contenidors antics
- [x] Eliminar imatges antigues
- [x] Netejar caché de Docker

### Fase 2: Build (20-30 minuts)
- [ ] **Worker** - Amb preprocessament avançat + zxing-cpp v2.2.0
  - 6 tècniques de preprocessament
  - Confidence combinada (YOLO + decode)
  - Component C++ natiu (zxing-cpp v2.2.1)
  
- [ ] **Frontend** - Amb pestanya "AI Analysis"
  - Integració amb Ollama
  - 4 preguntes ràpides
  - Chat personalitzat amb Phi-3
  - Historial de converses
  
- [ ] **Backend** - API FastAPI
  - Endpoints per processament
  - Gestió de jobs
  - Base de dades PostgreSQL

### Fase 3: Inici
- [ ] Iniciar tots els serveis
- [ ] Descarregar model Phi-3 (10-15 min addicionals)
- [ ] Verificar que tot funciona

## 📊 Temps Estimat

| Component | Temps |
|-----------|-------|
| Worker | 10-15 min |
| Frontend | 5-8 min |
| Backend | 3-5 min |
| Model Phi-3 | 10-15 min |
| **TOTAL** | **30-45 min** |

## 🎯 Què Tindràs al Final

### Aplicació Completa amb IA:

```
Serveis:
├── Frontend (http://localhost:8501)
│   ├── Pujada de vídeos
│   ├── Visualització de resultats
│   └── 🆕 Pestanya "AI Analysis" amb Phi-3
│
├── Backend (http://localhost:8000)
│   ├── API REST
│   ├── Gestió de jobs
│   └── Base de dades
│
├── Worker
│   ├── Processament de vídeos
│   ├── Detecció YOLO
│   ├── 🆕 Preprocessament avançat (6 tècniques)
│   ├── 🆕 Decodificació amb zxing-cpp v2.2.0
│   └── 🆕 Component C++ natiu (v2.2.1)
│
├── LLM (http://localhost:11434)
│   ├── Ollama
│   └── Model Phi-3
│
├── Database (localhost:5432)
│   └── PostgreSQL
│
└── Redis (localhost:6379)
    └── Message broker
```

## 🚀 Després del Build

### 1. Descarregar Model Phi-3

**IMPORTANT:** Cal descarregar el model la primera vegada:

```bash
docker exec mobil_scan_llm ollama pull phi3
```

Això trigarà **10-15 minuts** però només cal fer-ho una vegada.

### 2. Accedir a l'Aplicació

```
Frontend:  http://localhost:8501
Backend:   http://localhost:8000
LLM:       http://localhost:11434
```

### 3. Provar la Pestanya IA

1. Puja un vídeo (ex: `VID_20251204_170312.mp4`)
2. Espera que es processi
3. Ves a la pestanya **"AI Analysis"**
4. Prova les preguntes ràpides o el chat personalitzat

## 📈 Millores Esperades

### Preprocessament (Worker):
- **Abans:** 25% codis llegibles
- **Després:** 75-100% codis llegibles
- **Millora:** +50-75% detecció

### Anàlisi IA (Frontend):
- Respostes intel·ligents sobre els resultats
- Detecció de problemes de qualitat
- Suggeriments de millora
- Estadístiques contextuals

## 🔍 Monitoritzar el Build

### Veure Logs en Temps Real

```bash
# En una altra terminal
docker-compose -f docker-compose.llm.yml logs -f
```

### Verificar Estat

```bash
docker ps
docker images
```

### Si Hi Ha Errors

```bash
# Veure logs d'un servei específic
docker-compose -f docker-compose.llm.yml logs worker
docker-compose -f docker-compose.llm.yml logs frontend
docker-compose -f docker-compose.llm.yml logs llm
```

## ⚠️ Possibles Problemes

### Error: "No space left on device"

**Solució:**
```bash
docker system prune -af
docker volume prune -f
```

### Error: "Cannot connect to Docker daemon"

**Solució:**
```bash
# Reinicia Docker Desktop
# O executa:
INICIAR_DOCKER_I_EXECUTAR.bat
```

### Error: "Build timeout"

**Solució:**
- Augmenta la memòria de Docker Desktop (Settings > Resources)
- Tanca altres aplicacions
- Torna a intentar-ho

### Error: "Network timeout"

**Solució:**
- Verifica la connexió a Internet
- Prova amb una xarxa diferent
- Torna a intentar-ho

## 📝 Checklist Post-Build

Després que acabi el build:

- [ ] Verificar que tots els contenidors estan actius: `docker ps`
- [ ] Descarregar model Phi-3: `docker exec mobil_scan_llm ollama pull phi3`
- [ ] Accedir al frontend: http://localhost:8501
- [ ] Provar pujada de vídeo
- [ ] Verificar processament
- [ ] Provar pestanya "AI Analysis"
- [ ] Fer preguntes a la IA
- [ ] Verificar que les respostes són coherents

## 🎉 Quan Acabi

Veuràs aquest missatge:

```
========================================
BUILD COMPLETAT AMB EXIT!
========================================

Serveis disponibles:
  Frontend:  http://localhost:8501
  Backend:   http://localhost:8000
  LLM:       http://localhost:11434

IMPORTANT: Descarrega model Phi-3
  docker exec mobil_scan_llm ollama pull phi3

Gaudeix de les millores! 🚀
========================================
```

## 💡 Consells

1. **Sigues pacient:** El build triga, però només cal fer-ho una vegada
2. **No tanquis la terminal:** Deixa que acabi completament
3. **Monitoritza l'ús de recursos:** Docker Desktop > Settings > Resources
4. **Descarrega Phi-3 després:** És un pas separat però necessari
5. **Prova amb el teu vídeo:** `VID_20251204_170312.mp4`

## 🆘 Si Alguna Cosa Falla

1. **Atura tot:**
   ```bash
   docker-compose -f docker-compose.llm.yml down
   ```

2. **Neteja:**
   ```bash
   docker system prune -af
   ```

3. **Torna a intentar:**
   ```bash
   REBUILD_COMPLET_AMB_IA.bat
   ```

4. **Revisa logs:**
   ```bash
   docker-compose -f docker-compose.llm.yml logs
   ```

---

**Estat Actual:** 🔨 Compilant... (Fase 2/3)

**Temps Restant:** ~20-30 minuts

**Següent Pas:** Descarregar model Phi-3 quan acabi
