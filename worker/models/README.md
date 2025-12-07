# YOLO Model Folder

## 📦 Place Your Trained Model Here

This folder should contain your trained YOLOv8 model for barcode detection.

### Expected File:
```
worker/models/best_barcode_model.pt
```

### How to Add:

1. **Copy your trained model:**
   ```bash
   # Windows
   copy "C:\path\to\your\best.pt" "worker\models\best_barcode_model.pt"
   
   # Linux/Mac
   cp /path/to/your/best.pt worker/models/best_barcode_model.pt
   ```

2. **Or download from Roboflow/Colab:**
   - Download your trained model
   - Rename to `best_barcode_model.pt`
   - Place in this folder

### What if I don't have a model yet?

**No problem!** The worker will automatically use YOLOv8n (default model) if no custom model is found.

However, the default model is NOT trained for barcodes, so detection accuracy will be low.

**To train your own model, see:** `GUIA_ENTRENAMENT_YOLO.md`

### File Size:

Typical model sizes:
- YOLOv8n: ~6 MB (fast, less accurate)
- YOLOv8s: ~22 MB (balanced)
- YOLOv8m: ~52 MB (accurate, slower)

Your trained model will be similar in size depending on which base model you used.

### Verification:

After adding the model, rebuild the worker:
```bash
BUILD_NEW_WORKER.bat
```

Check logs:
```bash
docker logs mobilscan-worker
```

You should see:
```
✅ YOLOv8 model loaded from: /app/models/best_barcode_model.pt
