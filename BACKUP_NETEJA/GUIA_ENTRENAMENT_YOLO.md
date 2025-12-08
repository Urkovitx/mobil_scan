# 🎯 Guia Completa: Entrenar YOLO per Detectar Codis de Barres

## 📋 Índex
1. [Què és YOLO i per què l'utilitzem](#què-és-yolo)
2. [Preparació de Dades amb Roboflow](#preparació-de-dades)
3. [Entrenament del Model](#entrenament)
4. [Integració amb l'Aplicació](#integració)
5. [Optimització i Millores](#optimització)

---

## 🤖 Què és YOLO i per què l'utilitzem

### YOLO (You Only Look Once)

**YOLO** és un model de detecció d'objectes en temps real que:
- ✅ Detecta objectes en una sola passada (molt ràpid)
- ✅ Funciona bé amb vídeos (30+ FPS)
- ✅ Pot detectar múltiples objectes simultàniament
- ✅ És fàcil d'entrenar amb dades personalitzades

### Per què YOLO per codis de barres?

En el teu cas, YOLO detectarà:
1. **Codis de barres** en els vídeos industrials
2. **Zones d'interès** (ROI) on buscar els codis
3. **Múltiples codis** en el mateix frame

**Avantatge:** Processa vídeos en temps real sense haver d'analitzar cada píxel.

---

## 📸 Preparació de Dades amb Roboflow

### Pas 1: Crear Compte a Roboflow

1. Ves a [roboflow.com](https://roboflow.com)
2. Crea un compte gratuït
3. Crea un nou projecte: **"Barcode Detection"**
4. Tipus de projecte: **Object Detection**

### Pas 2: Recopilar Imatges

**Necessites ~100-500 imatges** amb codis de barres:

#### Fonts d'Imatges:
1. **Vídeos existents** (els teus vídeos industrials)
   - Extreu frames amb codis de barres visibles
   - Usa diferents angles i il·luminacions
   
2. **Fotos amb el mòbil**
   - Fes fotos de codis de barres reals
   - Varia la distància i l'angle
   
3. **Dataset públic** (opcional)
   - Roboflow Universe té datasets de codis de barres
   - Pots combinar-los amb les teves dades

#### Com Extreure Frames d'un Vídeo:

```python
# Script per extreure frames d'un vídeo
import cv2
import os

def extract_frames(video_path, output_folder, frame_interval=30):
    """
    Extreu frames d'un vídeo cada X frames
    
    Args:
        video_path: Ruta al vídeo
        output_folder: Carpeta on desar els frames
        frame_interval: Extreure 1 frame cada X frames
    """
    os.makedirs(output_folder, exist_ok=True)
    
    cap = cv2.VideoCapture(video_path)
    frame_count = 0
    saved_count = 0
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Desa 1 frame cada frame_interval
        if frame_count % frame_interval == 0:
            output_path = os.path.join(output_folder, f"frame_{saved_count:04d}.jpg")
            cv2.imwrite(output_path, frame)
            saved_count += 1
            print(f"Desat: {output_path}")
        
        frame_count += 1
    
    cap.release()
    print(f"\n✅ Extrets {saved_count} frames de {frame_count} frames totals")

# Exemple d'ús
extract_frames("video_industrial.mp4", "frames_output", frame_interval=30)
```

### Pas 3: Anotar Imatges a Roboflow

1. **Puja les imatges** a Roboflow
   - Drag & drop o puja en lot
   
2. **Anota els codis de barres**
   - Dibuixa rectangles al voltant de cada codi de barres
   - Etiqueta: "barcode" o "code128", "qr_code", etc.
   
3. **Consells d'anotació:**
   - ✅ Inclou tot el codi de barres dins del rectangle
   - ✅ No deixis espai extra al voltant
   - ✅ Anota TOTS els codis visibles en cada imatge
   - ✅ Inclou codis parcials o borrosos (per robustesa)

**Exemple d'anotació:**
```
Imatge: frame_0001.jpg
Anotacions:
  - Rectangle 1: [x=100, y=200, w=150, h=50] → "barcode"
  - Rectangle 2: [x=300, y=400, w=120, h=40] → "qr_code"
```

### Pas 4: Augmentació de Dades (Data Augmentation)

Roboflow pot generar més imatges automàticament:

**Augmentacions recomanades:**
- ✅ **Flip horizontal** (50%)
- ✅ **Rotació** (±15°)
- ✅ **Brightness** (±20%)
- ✅ **Blur** (fins a 1.5px)
- ✅ **Noise** (fins a 2%)

**Resultat:** 100 imatges → 300-500 imatges augmentades

### Pas 5: Dividir Dataset

Roboflow divideix automàticament:
- **70% Train** (entrenament)
- **20% Valid** (validació)
- **10% Test** (test)

### Pas 6: Exportar Dataset

1. Ves a **"Generate"** → **"Export"**
2. Format: **YOLOv8** (o YOLOv5)
3. Descarrega el ZIP
4. Obtindràs:
   ```
   dataset/
   ├── train/
   │   ├── images/
   │   └── labels/
   ├── valid/
   │   ├── images/
   │   └── labels/
   ├── test/
   │   ├── images/
   │   └── labels/
   └── data.yaml
   ```

---

## 🏋️ Entrenament del Model

### Opció A: Entrenar a Roboflow (Recomanat per Principiants)

**Avantatges:**
- ✅ No necessites GPU local
- ✅ Entrenament automàtic
- ✅ Interfície visual

**Passos:**
1. A Roboflow, ves a **"Train"**
2. Selecciona **"Fast"** (gratuït) o **"Accurate"** (de pagament)
3. Espera 10-30 minuts
4. Descarrega el model entrenat

### Opció B: Entrenar Localment amb Google Colab (Gratuït)

**Avantatges:**
- ✅ GPU gratuïta de Google
- ✅ Control total sobre l'entrenament
- ✅ Pots ajustar hiperparàmetres

**Notebook de Google Colab:**

```python
# 1. Instal·lar Ultralytics (YOLOv8)
!pip install ultralytics roboflow

# 2. Descarregar dataset de Roboflow
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")  # Obtén l'API key de Roboflow
project = rf.workspace("YOUR_WORKSPACE").project("barcode-detection")
dataset = project.version(1).download("yolov8")

# 3. Entrenar el model
from ultralytics import YOLO

# Carregar model pre-entrenat
model = YOLO('yolov8n.pt')  # n=nano (ràpid), s=small, m=medium, l=large

# Entrenar
results = model.train(
    data='dataset/data.yaml',
    epochs=50,              # Nombre d'èpoques (50-100 recomanat)
    imgsz=640,              # Mida d'imatge
    batch=16,               # Batch size (ajusta segons GPU)
    patience=10,            # Early stopping
    save=True,
    project='barcode_yolo',
    name='train_v1'
)

# 4. Validar el model
metrics = model.val()
print(f"mAP50: {metrics.box.map50}")
print(f"mAP50-95: {metrics.box.map}")

# 5. Exportar el model
model.export(format='onnx')  # Per producció
```

**Temps d'entrenament:** 30-60 minuts amb GPU gratuïta de Colab

### Opció C: Entrenar Localment (Si tens GPU)

```bash
# Instal·lar Ultralytics
pip install ultralytics

# Entrenar
yolo train data=dataset/data.yaml model=yolov8n.pt epochs=50 imgsz=640
```

---

## 🔌 Integració amb l'Aplicació

### Pas 1: Descarregar el Model Entrenat

Després de l'entrenament, obtindràs:
- `best.pt` - Millor model (usa aquest)
- `last.pt` - Últim checkpoint
- `best.onnx` - Model optimitzat per producció

### Pas 2: Afegir el Model al Projecte

```bash
# Crea carpeta per models
mkdir -p backend/models

# Copia el model
cp best.pt backend/models/barcode_yolo.pt
```

### Pas 3: Actualitzar el Codi del Backend

**Fitxer:** `backend/app/services/video_processor.py`

```python
from ultralytics import YOLO
import cv2

class VideoProcessor:
    def __init__(self):
        # Carregar model YOLO entrenat
        self.model = YOLO('models/barcode_yolo.pt')
        self.confidence_threshold = 0.5
    
    def detect_barcodes(self, frame):
        """
        Detecta codis de barres en un frame
        
        Returns:
            List[Dict]: Llista de deteccions amb bbox i confidence
        """
        # Executar detecció
        results = self.model(frame, conf=self.confidence_threshold)
        
        detections = []
        for result in results:
            for box in result.boxes:
                # Extreure informació
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                confidence = box.conf[0].cpu().numpy()
                class_id = int(box.cls[0].cpu().numpy())
                
                detections.append({
                    'bbox': [int(x1), int(y1), int(x2), int(y2)],
                    'confidence': float(confidence),
                    'class': self.model.names[class_id]
                })
        
        return detections
    
    def process_video(self, video_path):
        """
        Processa un vídeo complet
        """
        cap = cv2.VideoCapture(video_path)
        all_detections = []
        
        frame_count = 0
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Detectar codis cada 10 frames (optimització)
            if frame_count % 10 == 0:
                detections = self.detect_barcodes(frame)
                
                if detections:
                    all_detections.append({
                        'frame': frame_count,
                        'timestamp': frame_count / cap.get(cv2.CAP_PROP_FPS),
                        'detections': detections
                    })
            
            frame_count += 1
        
        cap.release()
        return all_detections
```

### Pas 4: Actualitzar el Dockerfile del Backend

```dockerfile
# Afegir al backend/Dockerfile

# Copiar models
COPY backend/models /app/models

# Instal·lar Ultralytics
RUN pip install ultralytics
```

### Pas 5: Rebuild i Deploy

```bash
# Rebuild backend amb el nou model
docker build -t urkovitx/mobil-scan-backend:latest -f backend/Dockerfile .

# Push a Docker Hub
docker push urkovitx/mobil-scan-backend:latest

# Restart
docker-compose -f docker-compose.hub.yml pull backend
docker-compose -f docker-compose.hub.yml up -d backend
```

---

## 📊 Optimització i Millores

### 1. Millorar la Precisió

**Si el model no detecta bé:**

#### A. Més Dades
- Afegeix més imatges amb codis de barres
- Inclou més variacions (angles, il·luminació, distàncies)

#### B. Millor Anotació
- Revisa les anotacions existents
- Assegura't que tots els codis estan anotats

#### C. Augmentació Més Agressiva
- Augmenta el blur i el noise
- Afegeix més rotacions

#### D. Model Més Gran
- Canvia de `yolov8n` a `yolov8s` o `yolov8m`
- Més lent però més precís

### 2. Millorar la Velocitat

**Si el processament és massa lent:**

#### A. Model Més Petit
- Usa `yolov8n` (nano) en lloc de `yolov8m`
- Redueix `imgsz` a 416 o 320

#### B. Processar Menys Frames
- Analitza 1 frame cada 15-30 frames
- Només processa quan hi ha moviment

#### C. Usar ONNX
- Exporta el model a ONNX per més velocitat
```python
model.export(format='onnx')
```

### 3. Post-Processament

**Després de la detecció YOLO:**

```python
def post_process_detections(detections):
    """
    Millora les deteccions amb post-processament
    """
    # 1. Filtrar deteccions amb baixa confidence
    detections = [d for d in detections if d['confidence'] > 0.6]
    
    # 2. Non-Maximum Suppression (eliminar duplicats)
    detections = apply_nms(detections, iou_threshold=0.5)
    
    # 3. Tracking (seguir el mateix codi entre frames)
    detections = track_barcodes(detections)
    
    return detections
```

### 4. Combinar amb OCR

**Millor estratègia:**

1. **YOLO detecta** la zona del codi de barres
2. **Retalla** la regió detectada
3. **OCR/Barcode reader** llegeix el codi dins la regió

```python
def extract_barcode_value(frame, bbox):
    """
    Extreu el valor del codi de barres de la regió detectada
    """
    x1, y1, x2, y2 = bbox
    roi = frame[y1:y2, x1:x2]
    
    # Intentar llegir amb pyzbar
    from pyzbar.pyzbar import decode
    barcodes = decode(roi)
    
    if barcodes:
        return barcodes[0].data.decode('utf-8')
    
    # Si falla, usar OCR
    import pytesseract
    text = pytesseract.image_to_string(roi)
    return extract_code_from_text(text)
```

---

## 🎯 Workflow Complet Recomanat

### 1. Preparació (1-2 dies)
- [ ] Recopilar 100-200 imatges amb codis de barres
- [ ] Anotar-les a Roboflow
- [ ] Aplicar augmentació (→ 300-500 imatges)

### 2. Entrenament (1-2 hores)
- [ ] Entrenar model a Roboflow o Google Colab
- [ ] Validar amb test set (mAP > 0.8)
- [ ] Exportar model (`best.pt`)

### 3. Integració (2-4 hores)
- [ ] Afegir model al backend
- [ ] Actualitzar codi de processament
- [ ] Rebuild i deploy

### 4. Testing (1 dia)
- [ ] Provar amb vídeos reals
- [ ] Ajustar threshold de confidence
- [ ] Optimitzar velocitat

### 5. Producció
- [ ] Monitoritzar rendiment
- [ ] Recopilar més dades si cal
- [ ] Re-entrenar periòdicament

---

## 📈 Mètriques d'Èxit

### Objectius Recomanats:

| Mètrica | Objectiu | Excel·lent |
|---------|----------|------------|
| **mAP50** | > 0.80 | > 0.90 |
| **Precision** | > 0.85 | > 0.95 |
| **Recall** | > 0.80 | > 0.90 |
| **FPS** | > 15 | > 30 |
| **False Positives** | < 5% | < 2% |

### Com Interpretar:

- **mAP50**: Precisió general (0.80 = 80% de deteccions correctes)
- **Precision**: % de deteccions que són correctes
- **Recall**: % de codis reals que es detecten
- **FPS**: Frames per segon (velocitat)

---

## 🆘 Troubleshooting

### Problema: Model no detecta res

**Solucions:**
1. Baixa el threshold: `conf=0.3` en lloc de `0.5`
2. Comprova que les imatges d'entrenament són similars als vídeos reals
3. Afegeix més dades d'entrenament

### Problema: Massa false positives

**Solucions:**
1. Puja el threshold: `conf=0.7`
2. Millora les anotacions (més precises)
3. Afegeix exemples negatius (imatges sense codis)

### Problema: Model massa lent

**Solucions:**
1. Usa `yolov8n` en lloc de `yolov8m`
2. Redueix `imgsz` a 416
3. Processa menys frames (1 cada 20)
4. Exporta a ONNX

---

## 📚 Recursos Addicionals

### Documentació:
- [Ultralytics YOLOv8](https://docs.ultralytics.com/)
- [Roboflow Docs](https://docs.roboflow.com/)
- [Google Colab](https://colab.research.google.com/)

### Tutorials:
- [YOLOv8 Training Tutorial](https://www.youtube.com/watch?v=wuZtUMEiKWY)
- [Roboflow Annotation Guide](https://blog.roboflow.com/how-to-annotate/)

### Datasets Públics:
- [Roboflow Universe - Barcodes](https://universe.roboflow.com/search?q=barcode)
- [Kaggle Barcode Datasets](https://www.kaggle.com/search?q=barcode)

---

## ✅ Checklist Final

Abans de posar en producció:

- [ ] Model entrenat amb mAP > 0.80
- [ ] Testat amb vídeos reals
- [ ] Velocitat acceptable (> 15 FPS)
- [ ] False positives < 5%
- [ ] Integrat al backend
- [ ] Docker image actualitzada
- [ ] Documentació actualitzada

---

**🎉 Amb aquesta guia, tindràs un sistema de detecció de codis de barres completament funcional!**

**Temps estimat total:** 3-5 dies (incloent aprenentatge)

**Resultat:** Sistema automàtic que detecta i llegeix codis de barres en vídeos industrials amb alta precisió i velocitat.
