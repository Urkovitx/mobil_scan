# 📦 Com Afegir el Model YOLO Entrenat

## 🎯 Objectiu

Afegir el teu model YOLO entrenat (`best_barcode_model.pt`) al worker per detectar codis de barres.

---

## 📋 Passos

### 1. Crear Carpeta de Models

```bash
# A la carpeta del projecte
mkdir worker/models
```

O manualment:
- Ves a la carpeta `worker/`
- Crea una nova carpeta anomenada `models`

---

### 2. Copiar el Model Entrenat

**Opció A: Copiar manualment**
1. Localitza el teu fitxer `best_barcode_model.pt` (o `best.pt`)
2. Copia'l a `worker/models/`
3. Renombra'l a `best_barcode_model.pt` si cal

**Opció B: Amb comanda**
```bash
# Windows
copy "C:\path\to\your\best.pt" "worker\models\best_barcode_model.pt"

# Linux/Mac
cp /path/to/your/best.pt worker/models/best_barcode_model.pt
```

---

### 3. Verificar Estructura

La teva carpeta hauria de tenir aquesta estructura:

```
mobil_scan/
├── worker/
│   ├── models/
│   │   └── best_barcode_model.pt  ← El teu model aquí
│   ├── processor.py
│   ├── Dockerfile
│   └── requirements-worker.txt
├── backend/
├── frontend/
└── ...
```

---

### 4. Build i Deploy

**Opció A: Usar el script automàtic (Recomanat)**
```bash
BUILD_NEW_WORKER.bat
```

**Opció B: Manual**
```bash
# 1. Build
docker build -t urkovitx/mobil-scan-worker:latest -f worker/Dockerfile .

# 2. Push
docker push urkovitx/mobil-scan-worker:latest

# 3. Deploy
docker-compose -f docker-compose.hub.yml pull worker
docker-compose -f docker-compose.hub.yml up -d worker
```

---

### 5. Verificar

```bash
# Veure logs del worker
docker logs mobilscan-worker

# Hauries de veure:
# ✅ YOLOv8 model loaded from: /app/models/best_barcode_model.pt
# ✅ Supervision annotators initialized
# 📦 YOLO available: True
# 📦 zxing-cpp available: True
```

---

## ❓ Què passa si NO tinc el model encara?

**No passa res!** El worker funcionarà igualment:

1. El codi detecta que no hi ha model a `/app/models/best_barcode_model.pt`
2. Descarrega automàticament `yolov8n.pt` (model genèric de YOLOv8)
3. Usa aquest model per defecte

**Logs esperats:**
```
⚠️ Model not found at /app/models/best_barcode_model.pt, using default YOLOv8n
✅ YOLOv8 model loaded (default)
```

**Nota:** El model per defecte NO està entrenat per codis de barres, així que la precisió serà baixa. És millor entrenar el teu propi model seguint `GUIA_ENTRENAMENT_YOLO.md`.

---

## 🔧 Configuració Avançada

### Canviar el Path del Model

Si vols usar un nom diferent o múltiples models:

**1. Actualitza `docker-compose.hub.yml`:**
```yaml
worker:
  environment:
    MODEL_PATH: /app/models/my_custom_model.pt
```

**2. Copia el model amb el nom correcte:**
```bash
copy "best.pt" "worker\models\my_custom_model.pt"
```

**3. Rebuild i deploy**

---

### Usar Múltiples Models

Si tens diferents models per diferents tipus de codis:

**1. Copia tots els models:**
```
worker/models/
├── barcode_code128.pt
├── barcode_qr.pt
└── barcode_datamatrix.pt
```

**2. Modifica `processor.py` per carregar el model adequat segons el tipus**

---

## 📊 Mida del Model

**Models típics:**
- `yolov8n.pt` (nano): ~6 MB - Ràpid, menys precís
- `yolov8s.pt` (small): ~22 MB - Equilibrat
- `yolov8m.pt` (medium): ~52 MB - Més precís, més lent
- `yolov8l.pt` (large): ~87 MB - Molt precís, lent

**El teu model entrenat:**
- Depèn de la mida base que vas usar per entrenar
- Normalment entre 6-50 MB

---

## ✅ Checklist

Abans de fer el build:

- [ ] Carpeta `worker/models/` creada
- [ ] Model `best_barcode_model.pt` copiat a `worker/models/`
- [ ] Model té el nom correcte
- [ ] Mida del model és raonable (< 100 MB)

Després del deploy:

- [ ] Worker container està UP
- [ ] Logs mostren "YOLOv8 model loaded"
- [ ] No hi ha errors en els logs
- [ ] Test amb un vídeo funciona

---

## 🆘 Troubleshooting

### Error: Model not found

**Problema:**
```
⚠️ Model not found at /app/models/best_barcode_model.pt
```

**Solució:**
1. Verifica que el fitxer existeix a `worker/models/`
2. Comprova el nom del fitxer (ha de ser exactament `best_barcode_model.pt`)
3. Rebuild la imatge Docker

---

### Error: Model corrupted

**Problema:**
```
❌ Failed to load model: ...
```

**Solució:**
1. Verifica que el fitxer no està corrupte
2. Re-descarrega el model des de Roboflow/Colab
3. Comprova que és un model YOLOv8 (no v5 o v7)

---

### Error: Out of memory

**Problema:**
```
RuntimeError: CUDA out of memory
```

**Solució:**
1. Usa un model més petit (yolov8n en lloc de yolov8l)
2. Redueix el batch size
3. Augmenta la memòria del contenidor Docker

---

## 📚 Recursos

- **Entrenar model:** `GUIA_ENTRENAMENT_YOLO.md`
- **Refactor complet:** `REFACTOR_YOLO_SUMMARY.md`
- **Build worker:** `BUILD_NEW_WORKER.bat`

---

## 🎉 Resum

1. ✅ Crea `worker/models/`
2. ✅ Copia `best_barcode_model.pt` a `worker/models/`
3. ✅ Executa `BUILD_NEW_WORKER.bat`
4. ✅ Verifica logs
5. ✅ Prova amb un vídeo

**Temps estimat:** 5-10 minuts (+ temps de build/push)
