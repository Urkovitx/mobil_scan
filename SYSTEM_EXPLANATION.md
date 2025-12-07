# 🎓 Explicació del Sistema - Mobile Industrial Scanner

## 📖 Què fa aquesta aplicació?

Aquesta aplicació és un **sistema d'auditoria industrial basat en vídeo** que utilitza Intel·ligència Artificial per detectar automàticament text en vídeos d'inventari.

---

## 🎯 Cas d'Ús Real

### Escenari
Imagina que treballes en un magatzem i necessites fer inventari. En lloc de:
1. ❌ Anotar manualment cada codi
2. ❌ Fer fotos una per una
3. ❌ Processar-les després

Ara pots:
1. ✅ Gravar un vídeo caminant pel magatzem
2. ✅ Pujar el vídeo a l'aplicació
3. ✅ L'IA detecta TOTS els codis automàticament
4. ✅ Descarregar els resultats en CSV

**Temps estalviat:** De 2 hores a 10 minuts! ⚡

---

## 🏗️ Arquitectura del Sistema

### Vista General
```
┌─────────────┐
│   USUARI    │ (Tu, amb el navegador)
└──────┬──────┘
       │
       ↓
┌─────────────────────────────────────────┐
│         FRONTEND (Streamlit)            │
│  - Interfície web                       │
│  - Puja vídeos                          │
│  - Mostra resultats                     │
│  Port: 8501                             │
└──────┬──────────────────────────────────┘
       │
       ↓
┌─────────────────────────────────────────┐
│         BACKEND (FastAPI)               │
│  - API REST                             │
│  - Gestiona fitxers                     │
│  - Consulta base de dades               │
│  Port: 8000                             │
└──────┬──────────────────────────────────┘
       │
       ├──→ ┌──────────────┐
       │    │    REDIS     │ (Cua de treballs)
       │    │  Port: 6379  │
       │    └──────────────┘
       │           ↓
       │    ┌──────────────────────────┐
       │    │   WORKER (Processador)   │
       │    │  - Extreu frames         │
       │    │  - Detecta text (OCR)    │
       │    │  - Guarda resultats      │
       │    └──────────────────────────┘
       │
       └──→ ┌──────────────┐
            │  PostgreSQL  │ (Base de dades)
            │  Port: 5432  │
            └──────────────┘
```

---

## 🔄 Flux de Treball Complet

### Pas 1: Pujada del Vídeo
```
Usuari → Frontend → Backend
```

**Què passa:**
1. L'usuari selecciona un vídeo (MP4, MOV, AVI, MKV)
2. El frontend l'envia al backend via API
3. El backend guarda el vídeo a `shared/videos/`
4. Es crea un "Job" (feina) a la base de dades
5. El Job s'afegeix a la cua de Redis

**Temps:** ~5 segons

---

### Pas 2: Processament del Vídeo
```
Redis → Worker → Base de Dades
```

**Què passa:**
1. El Worker escolta la cua de Redis
2. Quan arriba un Job, el Worker:
   - Obre el vídeo amb OpenCV
   - Extreu 1 frame per segon (configurable)
   - Guarda cada frame com a imatge JPG
   - Aplica PaddleOCR a cada frame
   - Detecta TOT el text visible
   - Guarda cada detecció a la base de dades
3. Actualitza el progrés cada 10 frames

**Temps:** ~5-10 minuts per vídeo de 1 minut

---

### Pas 3: Visualització de Resultats
```
Frontend → Backend → Base de Dades → Frontend
```

**Què passa:**
1. El frontend consulta l'estat del Job cada 5 segons
2. Quan el Job està completat:
   - Obté totes les deteccions
   - Mostra les mètriques (frames, tags, confiança)
   - Renderitza la galeria d'evidències
   - Permet filtrar per confiança
   - Permet descarregar CSV

**Temps:** Instantani

---

## 🧩 Components Detallats

### 1. Frontend (Streamlit) 🖥️

**Fitxer:** `frontend/app.py`

**Responsabilitats:**
- Mostrar la interfície web
- Gestionar la pujada de vídeos
- Mostrar el progrés en temps real
- Renderitzar la galeria d'evidències
- Exportar resultats a CSV

**Tecnologies:**
- Streamlit (framework web Python)
- Requests (crides HTTP)
- Pandas (manipulació de dades)

**Port:** 8501

**Accés:** http://localhost:8501

---

### 2. Backend (FastAPI) 🔌

**Fitxer:** `backend/main.py`

**Responsabilitats:**
- Proporcionar API REST
- Validar fitxers pujats
- Gestionar Jobs
- Consultar base de dades
- Afegir Jobs a Redis

**Endpoints:**
```
GET  /              → Health check
POST /upload        → Puja vídeo
GET  /job/{id}      → Estat del Job
GET  /results/{id}  → Resultats del Job
GET  /jobs          → Llista tots els Jobs
GET  /stats         → Estadístiques del sistema
```

**Tecnologies:**
- FastAPI (framework API)
- SQLAlchemy (ORM base de dades)
- Redis (client Python)

**Port:** 8000

**Accés:** http://localhost:8000/docs (Swagger UI)

---

### 3. Worker (Processador) ⚙️

**Fitxer:** `worker/processor.py`

**Responsabilitats:**
- Escoltar cua de Redis
- Processar vídeos
- Extreure frames
- Detectar text amb OCR
- Guardar resultats

**Procés Detallat:**
```python
1. Connectar a Redis
2. Esperar Job (BRPOP video_queue)
3. Quan arriba Job:
   a. Obrir vídeo amb OpenCV
   b. Per cada segon del vídeo:
      - Extreure frame
      - Guardar com JPG
      - Aplicar PaddleOCR
      - Per cada text detectat:
        * Guardar text
        * Guardar coordenades (bbox)
        * Guardar confiança
        * Guardar a base de dades
   c. Actualitzar progrés
   d. Marcar Job com completat
4. Tornar al pas 2
```

**Tecnologies:**
- OpenCV (processament vídeo)
- PaddleOCR (detecció de text)
- SQLAlchemy (base de dades)
- Redis (cua de treballs)

**No té port** (procés en background)

---

### 4. Redis (Cua de Missatges) 📬

**Imatge Docker:** redis:7-alpine

**Responsabilitats:**
- Gestionar cua de Jobs
- Comunicació asíncrona Backend ↔ Worker

**Com funciona:**
```
Backend:  LPUSH video_queue {"job_id": "...", "video_path": "..."}
Worker:   BRPOP video_queue 0  (espera fins que hi ha un Job)
```

**Port:** 6379

**Accés:** `redis-cli` (dins del contenidor)

---

### 5. PostgreSQL (Base de Dades) 🗄️

**Imatge Docker:** postgres:15-alpine

**Responsabilitats:**
- Emmagatzemar Jobs
- Emmagatzemar Deteccions
- Proporcionar consultes ràpides

**Taules:**

#### `video_jobs`
```sql
- job_id (UUID, PK)
- video_name (TEXT)
- video_path (TEXT)
- status (TEXT: pending, processing, completed, failed)
- total_frames (INT)
- processed_frames (INT)
- detections_count (INT)
- progress (FLOAT)
- created_at (TIMESTAMP)
- started_at (TIMESTAMP)
- completed_at (TIMESTAMP)
- error_message (TEXT)
```

#### `detections`
```sql
- id (INT, PK, AUTO)
- job_id (UUID, FK → video_jobs)
- frame_number (INT)
- timestamp (FLOAT)
- detected_text (TEXT)
- confidence (FLOAT)
- bbox_x1, bbox_y1, bbox_x2, bbox_y2 (INT)
- frame_path (TEXT)
- created_at (TIMESTAMP)
```

**Port:** 5432

**Accés:** 
- User: `mobilscan`
- Password: `mobilscan123`
- Database: `mobilscan_db`

---

## 🔍 Exemple Pràctic

### Escenari: Inventari de Magatzem

**Vídeo:** 30 segons, 30 FPS = 900 frames totals

#### Pas 1: Pujada (5 segons)
```
Usuari puja video.mp4 (50 MB)
↓
Backend guarda a shared/videos/abc123.mp4
↓
Crea Job: job_id = "abc123-def456-..."
↓
Afegeix a Redis: {"job_id": "abc123...", "video_path": "/app/videos/abc123.mp4"}
```

#### Pas 2: Processament (5 minuts)
```
Worker rep Job de Redis
↓
Obre video.mp4 amb OpenCV
↓
Extreu 30 frames (1 per segon)
↓
Per cada frame:
  - Guarda frame_000000.jpg, frame_000030.jpg, ...
  - Aplica PaddleOCR
  - Detecta: "B80-X", "A123", "C456", ...
  - Guarda a base de dades:
    * frame_number: 0, 30, 60, ...
    * timestamp: 0.0, 1.0, 2.0, ...
    * detected_text: "B80-X"
    * confidence: 0.95
    * bbox: (100, 200, 300, 250)
↓
Actualitza progrés: 10/30, 20/30, 30/30
↓
Marca Job com "completed"
```

#### Pas 3: Visualització (instantani)
```
Frontend consulta /results/abc123...
↓
Backend retorna 42 deteccions
↓
Frontend mostra:
  - Mètriques: 30 frames, 42 tags, 87% confiança
  - Galeria: 42 imatges en graella 4x11
  - Cada imatge mostra:
    * Frame del vídeo
    * Text detectat (gran i negreta)
    * Badge de confiança (🟢 95%)
↓
Usuari descarrega CSV amb 42 files
```

---

## 🎨 Interfície d'Usuari

### Pantalla 1: Pujada
```
┌─────────────────────────────────────┐
│  📤 Upload Video                    │
├─────────────────────────────────────┤
│                                     │
│  [Drag & Drop Video Here]          │
│                                     │
│  📹 video.mp4 (50.2 MB)            │
│                                     │
│  [🚀 Process Video]                │
│                                     │
└─────────────────────────────────────┘
```

### Pantalla 2: Dashboard
```
┌─────────────────────────────────────┐
│  📊 Audit Dashboard                 │
├─────────────────────────────────────┤
│  Job: abc123... [✅ COMPLETED]      │
├─────────────────────────────────────┤
│  🎞️ 30 Frames  🏷️ 42 Tags  📊 87%  │
├─────────────────────────────────────┤
│  🖼️ Evidence Gallery                │
│                                     │
│  ┌────┬────┬────┬────┐             │
│  │IMG │IMG │IMG │IMG │             │
│  │B80X│A123│C456│D789│             │
│  │🟢95│🟢88│🟡72│🔴55│             │
│  └────┴────┴────┴────┘             │
│                                     │
│  [📥 Download CSV]                  │
└─────────────────────────────────────┘
```

---

## 🚀 Avantatges del Sistema

### 1. **Asíncron**
- El frontend no es bloqueja
- Pots pujar múltiples vídeos
- El Worker processa en background

### 2. **Escalable**
- Pots afegir més Workers
- 1 Worker = 1 vídeo alhora
- 3 Workers = 3 vídeos en paral·lel

### 3. **Robust**
- Si el Worker falla, el Job es marca com "failed"
- Pots reiniciar el Worker sense perdre dades
- La base de dades persisteix tot

### 4. **Flexible**
- Canvia FRAME_INTERVAL per extreure més/menys frames
- Filtra per confiança a la UI
- Exporta a CSV per anàlisi posterior

---

## 🔧 Configuració

### Variables d'Entorn (.env)
```bash
# Redis
REDIS_URL=redis://redis:6379/0

# Base de Dades
DATABASE_URL=postgresql://mobilscan:mobilscan123@db:5432/mobilscan_db

# API
API_URL=http://api:8000

# Carpetes
UPLOAD_FOLDER=/app/videos
FRAMES_FOLDER=/app/frames
RESULTS_FOLDER=/app/results

# Processament
FRAME_INTERVAL=30  # 1 frame cada 30 frames (1 per segon a 30 FPS)
```

### Ports
```
8501 → Frontend (Streamlit)
8000 → Backend (FastAPI)
6379 → Redis
5432 → PostgreSQL
```

---

## 📊 Rendiment Esperat

### Temps de Processament
```
Vídeo de 30 segons (30 FPS):
- Frames totals: 900
- Frames extrets: 30 (1 per segon)
- Temps OCR: ~2-3 segons per frame
- Temps total: ~2-3 minuts

Vídeo de 5 minuts (30 FPS):
- Frames totals: 9000
- Frames extrets: 300
- Temps total: ~15-20 minuts
```

### Recursos
```
RAM:
- Frontend: ~300 MB
- Backend: ~500 MB
- Worker: ~2 GB (durant processament)
- Redis: ~100 MB
- PostgreSQL: ~500 MB
Total: ~4 GB

CPU:
- Frontend: ~5%
- Backend: ~10%
- Worker: ~50% (durant processament)
- Redis: ~2%
- PostgreSQL: ~5%
```

---

## 🎓 Tecnologies Utilitzades

### Frontend
- **Streamlit** - Framework web Python
- **Pandas** - Manipulació de dades
- **Requests** - Crides HTTP

### Backend
- **FastAPI** - Framework API REST
- **SQLAlchemy** - ORM base de dades
- **Redis** - Client Python

### Worker
- **OpenCV** - Processament vídeo
- **PaddleOCR** - Detecció de text (IA)
- **PaddlePaddle** - Framework deep learning

### Infraestructura
- **Docker** - Contenidors
- **Docker Compose** - Orquestració
- **Redis** - Cua de missatges
- **PostgreSQL** - Base de dades

---

## 🎯 Resum

Aquest sistema és com tenir un **assistent d'IA que mira vídeos i anota tot el text que veu**.

**Input:** Vídeo de magatzem  
**Output:** Llista de tots els codis detectats amb timestamps

**Benefici:** Estalvia hores de treball manual! ⚡

---

**Preguntes Freqüents:**

**P: Quant triga a processar un vídeo?**  
R: ~2-3 minuts per cada minut de vídeo.

**P: Quants vídeos puc processar alhora?**  
R: Amb 1 Worker, 1 vídeo. Pots afegir més Workers per processar més vídeos en paral·lel.

**P: Quina precisió té l'OCR?**  
R: PaddleOCR té ~90-95% de precisió en condicions normals. Millor que Tesseract en entorns industrials.

**P: Puc processar vídeos de drons?**  
R: Sí! Funciona amb qualsevol vídeo MP4, MOV, AVI o MKV.

**P: On es guarden els resultats?**  
R: A la base de dades PostgreSQL. Pots exportar-los a CSV.

---

**Versió:** 2.0.0  
**Data:** 2024-12-03  
**Estat:** ✅ Operatiu
