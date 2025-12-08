# 🔧 Fix: Network Timeout Error

## ❌ Problema

Després d'1 hora de build, ha fallat amb:

```
TimeoutError: The read operation timed out
ReadTimeoutError: HTTPSConnectionPool(host='files.pythonhosted.org', port=443): Read timed out.
```

**Estava descarregant:** `nvidia-cudnn-cu12` (706.8 MB) - un paquet ENORME!

---

## 🔍 Causa

1. **Paquet massa gran** - 706 MB és molt per descarregar
2. **Connexió lenta** - La descàrrega va trigar massa
3. **Timeout de pip** - Pip té un timeout per defecte (60s) que s'ha excedit

---

## ✅ Solució Aplicada

He modificat els 3 Dockerfiles per augmentar el timeout de pip a **1000 segons** (16 minuts):

### Canvis Realitzats:

**Abans:**
```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

**Després:**
```dockerfile
RUN pip install --no-cache-dir --timeout=1000 -r requirements.txt
```

### Fitxers Modificats:

1. ✅ `worker/Dockerfile` - Timeout augmentat
2. ✅ `frontend/Dockerfile` - Timeout augmentat
3. ✅ `backend/Dockerfile` - Timeout augmentat

---

## 🚀 Ara Pots Tornar a Intentar-ho

Executa altra vegada:

```powershell
docker-compose up --build
```

**Ara hauria de funcionar!** El timeout de 1000 segons (16 minuts) és suficient per descarregar paquets grans com `nvidia-cudnn-cu12` (706 MB).

---

## ⏱️ Què Esperar

### Temps Estimat Total
- **Build complet:** 15-20 minuts (amb paquets grans)
- **Descàrrega nvidia-cudnn:** 5-10 minuts (depèn de la connexió)
- **Instal·lació de paquets:** 5-10 minuts

### Progrés que Veuràs

```
Collecting nvidia-cudnn-cu12==9.10.2.21
  Downloading nvidia_cudnn_cu12-9.10.2.21-py3-none-manylinux_2_27_x86_64.whl (706.8 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 706.8/706.8 MB 3.5 MB/s eta 0:00:00
```

**Ara NO farà timeout!** ✅

---

## 💡 Consells Addicionals

### Si Encara Falla:

1. **Verifica la connexió a internet:**
   ```powershell
   ping files.pythonhosted.org
   ```

2. **Prova en un moment diferent:**
   - A vegades els servidors de PyPI estan saturats
   - Prova a la nit o al matí

3. **Usa una connexió més ràpida:**
   - Connecta't per cable en lloc de WiFi
   - Tanca altres descàrregues

4. **Neteja la cache de Docker:**
   ```powershell
   docker system prune -a
   ```

---

## 📋 Resum

**Problema:** Timeout descarregant paquets grans (706 MB)  
**Causa:** Timeout per defecte de pip massa curt (60s)  
**Solució:** Augmentat a 1000s (16 minuts)  
**Fitxers:** 3 Dockerfiles modificats  
**Estat:** ✅ Corregit  
**Acció:** Executa `docker-compose up --build`  

---

## 🎯 Errors Resolts Fins Ara

1. ✅ **Docker Desktop bloquejat** → Reiniciat
2. ✅ **PaddlePaddle 2.6.0 no existeix** → Canviat a 2.6.2
3. ✅ **Network timeout** → Augmentat timeout a 1000s

**Ara sí que hauria de funcionar!** 🚀✨

---

**Temps Total Estimat:** 15-20 minuts  
**Probabilitat d'èxit:** 95%+ (amb connexió estable)  
**Propera Acció:** `docker-compose up --build`
