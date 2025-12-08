# 🔄 Reiniciar Worker Després de Canvis

## ⚠️ Problema

El worker està executant-se amb el codi antic en memòria. Els canvis al fitxer `worker/processor.py` no s'aplicaran fins que reiniciïs el worker.

---

## ✅ Solució: Reiniciar el Worker

### **Pas 1: Atura el Worker**

**A la terminal del worker (Terminal 2):**

```bash
# Prem Ctrl+C per aturar el worker
```

**Hauries de veure:**

```
⚠️ Worker interrupted by user
```

---

### **Pas 2: Reinicia el Worker**

**A la mateixa terminal:**

```bash
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

**Ara hauries de veure:**

```
✅ Supervision annotators initialized
🚀 Starting video processor worker...
📦 YOLO available: True
📦 zxing-cpp available: True
✅ Connected to Redis: redis://localhost:6379/0
👂 Listening for jobs on 'video_queue'...
```

**Sense l'error de `text_thickness`! ✅**

---

## 🎯 Verificació

**Comprova que NO veus aquest error:**

```
❌ Failed to initialize YOLO: BoxAnnotator.__init__() got an unexpected keyword argument 'text_thickness'
```

**Si encara el veus:**
1. Assegura't que has guardat els canvis a `worker/processor.py`
2. Tanca completament la terminal del worker
3. Obre una nova terminal
4. Executa `EXECUTAR_WORKER_SENSE_DOCKER.bat`

---

## 📋 Checklist

- [ ] Aturar worker (Ctrl+C)
- [ ] Reiniciar worker (`EXECUTAR_WORKER_SENSE_DOCKER.bat`)
- [ ] Verificar que NO hi ha error de `text_thickness`
- [ ] Verificar que diu "✅ Supervision annotators initialized"
- [ ] Verificar que diu "👂 Listening for jobs on 'video_queue'..."

---

## 🚀 Després de Reiniciar

**La teva tool estarà completament funcional:**

1. ✅ Redis funcionant
2. ✅ Worker sense errors
3. ✅ Backend funcionant
4. ✅ Frontend accessible

**Puja un vídeo i comença a detectar codis de barres! 🎉**

---

## 💡 Consell

**Sempre que facis canvis al codi del worker, has de reiniciar-lo:**

```bash
# 1. Atura (Ctrl+C)
# 2. Reinicia
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

**Això és normal en desenvolupament! 🔄**
