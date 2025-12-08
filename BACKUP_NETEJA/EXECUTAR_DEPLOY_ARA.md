# 🚀 Executar Deploy a Google Cloud Run - ARA

## ✅ Estat Actual

- ✅ Google Cloud SDK instal·lat
- ✅ Sessió iniciada (ferranpalacin@gmail.com)
- ✅ Projecte creat i configurat (mobil-scan-app)
- ✅ Facturació activada
- ✅ cloudbuild.yaml corregit

## 🎯 Comanda per Executar ARA

Obre un **PowerShell o CMD nou** i executa:

```bash
cd "C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan"

gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app
```

## ⏱️ Què Passarà

1. **Puja el codi** (30 segons)
   - Comprimeix els fitxers
   - Puja a Google Cloud Storage

2. **Compila Backend** (10-15 minuts)
   - Descarrega dependències Python
   - Crea imatge Docker

3. **Compila Frontend** (10-15 minuts)
   - Descarrega dependències Streamlit
   - Crea imatge Docker

4. **Compila Worker** (15-20 minuts)
   - Descarrega zxing-cpp v2.2.0
   - Descarrega YOLOv8
   - Crea imatge Docker

5. **Puja imatges** (2-3 minuts)
   - Guarda al Container Registry

**TEMPS TOTAL: 40-50 minuts**

## 📊 Seguiment del Build

Mentre es compila, pots veure el progrés a:

👉 https://console.cloud.google.com/cloud-build/builds?project=mobil-scan-app

## ✅ Quan Acabi

Veuràs un missatge com:

```
DONE
--------------------------------------------------------------------------------
ID                                    CREATE_TIME                DURATION  SOURCE
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  2024-XX-XXTXX:XX:XX+00:00  XXmXXs    gs://...

IMAGES
gcr.io/mobil-scan-app/mobil-scan-backend:latest
gcr.io/mobil-scan-app/mobil-scan-frontend:latest
gcr.io/mobil-scan-app/mobil-scan-worker:latest
```

## 🚀 Després del Build

Un cop compilades les imatges, desplega els serveis:

```bash
# Backend
gcloud run deploy mobil-scan-backend \
  --image gcr.io/mobil-scan-app/mobil-scan-backend:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --port 8000 \
  --project mobil-scan-app

# Frontend
gcloud run deploy mobil-scan-frontend \
  --image gcr.io/mobil-scan-app/mobil-scan-frontend:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --port 8501 \
  --project mobil-scan-app

# Worker
gcloud run deploy mobil-scan-worker \
  --image gcr.io/mobil-scan-app/mobil-scan-worker:latest \
  --platform managed \
  --region europe-west1 \
  --no-allow-unauthenticated \
  --memory 4Gi \
  --cpu 2 \
  --project mobil-scan-app
```

## 🆘 Si Hi Ha Errors

### Error: "API not enabled"
```bash
gcloud services enable run.googleapis.com cloudbuild.googleapis.com --project=mobil-scan-app
```

### Error: "Permission denied"
```bash
gcloud auth login
gcloud auth application-default login
```

### Error: "Billing not enabled"
Verifica a: https://console.cloud.google.com/billing

## 📝 Notes Importants

1. **Primera vegada:** Trigarà 40-50 minuts
2. **Següents vegades:** 10-15 minuts (utilitza caché)
3. **Pots tancar la terminal:** El build continua al núvol
4. **Seguiment:** https://console.cloud.google.com/cloud-build/builds

## ✅ Checklist

- [ ] Obrir PowerShell/CMD nou
- [ ] Navegar al directori del projecte
- [ ] Executar `gcloud builds submit`
- [ ] Esperar 40-50 minuts
- [ ] Verificar que acaba amb èxit
- [ ] Desplegar serveis amb `gcloud run deploy`
- [ ] Obtenir URLs públiques
- [ ] Provar l'aplicació

---

**Ara executa la comanda i espera! El build es fa tot sol al núvol.** 🚀
