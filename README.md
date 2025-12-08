# 📱 Mobile Scanner - Detecció de Codis de Barres amb IA

Aplicació web per detectar i decodificar codis de barres en vídeos utilitzant YOLOv8 i zxing-cpp.

## 🚀 Característiques

- ✅ **Detecció automàtica** de codis de barres en vídeos
- ✅ **Múltiples formats** suportats (EAN-13, QR Code, Code128, etc.)
- ✅ **Interfície web** intuïtiva amb Streamlit
- ✅ **Processament en background** amb workers
- ✅ **Desplegament al núvol** amb Google Cloud Run
- ✅ **Escalabilitat automàtica** sense gestió de servidors
- ✅ **HTTPS automàtic** i accessible des de qualsevol lloc

## 🏗️ Arquitectura

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Frontend   │─────▶│   Backend   │─────▶│   Worker    │
│  Streamlit  │      │   FastAPI   │      │   YOLOv8    │
│  (Port 8501)│      │  (Port 8000)│      │  + zxing    │
└─────────────┘      └─────────────┘      └─────────────┘
       │                    │                     │
       └────────────────────┴─────────────────────┘
                            │
                     ┌──────▼──────┐
                     │  PostgreSQL │
                     │   + Redis   │
                     └─────────────┘
```

## 📦 Components

### Frontend (Streamlit)
- Interfície d'usuari per pujar vídeos
- Visualització de resultats
- Gestió de deteccions

### Backend (FastAPI)
- API REST per gestionar vídeos
- Gestió de base de dades
- Cua de tasques amb Redis

### Worker (Python + YOLOv8 + zxing-cpp)
- Processament de vídeos
- Detecció amb YOLOv8
- Decodificació amb zxing-cpp v2.2.1

## 🛠️ Tecnologies

- **ML/CV:** YOLOv8, zxing-cpp, OpenCV, Supervision
- **Backend:** FastAPI, SQLAlchemy, Redis
- **Frontend:** Streamlit
- **Base de dades:** PostgreSQL
- **Deploy:** Google Cloud Run
- **Build:** Google Cloud Build

## 🚀 Desplegament

### Requisits

- Google Cloud SDK instal·lat
- Compte de Google Cloud amb facturació activada
- Projecte creat: `mobil-scan-app`

### Passos

1. **Build al núvol:**
```bash
gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app
```

2. **Desplegar serveis:**
```bash
DESPLEGAR_SERVEIS_ARA.bat
```

3. **Obtenir URL:**
```bash
OBTENIR_URL.bat
```

## 📱 Ús

1. Obre la URL del frontend al navegador
2. Puja un vídeo amb codis de barres
3. Espera el processament (apareixerà a la llista)
4. Visualitza els resultats amb deteccions i codis

### Des del Mòbil

1. Comparteix la URL al mòbil
2. Obre-la al navegador
3. Funciona igual que al PC!

## 🔄 Actualitzar l'Aplicació

Després de fer canvis al codi:

```bash
ACTUALITZAR_APLICACIO.bat
```

Això rebuildarà i redesplegarà automàticament (15-20 minuts).

## 🔗 Integració amb Git/GitHub

### Configuració

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TU_USUARIO/mobil-scan-app.git
git push -u origin main
```

### Deploy Automàtic

Connecta Cloud Run amb GitHub per deploy automàtic en cada `git push`:

1. Consola Cloud Run → "Connectar al repositori"
2. Selecciona GitHub i autoritza
3. Configura branch `main` i `cloudbuild.yaml`
4. Cada push rebuildarà automàticament!

## 📊 Monitorització

### Veure Logs

```bash
# Frontend
gcloud run services logs read mobil-scan-frontend --project mobil-scan-app

# Backend
gcloud run services logs read mobil-scan-backend --project mobil-scan-app

# Worker
gcloud run services logs read mobil-scan-worker --project mobil-scan-app
```

### Consola Web

👉 https://console.cloud.google.com/run?project=mobil-scan-app

## 💰 Costos

- **300$ gratis** per començar (Google Cloud)
- **~10€/mes** amb tràfic baix
- **0€** quan no s'usa (escala a 0 automàticament)

## 📚 Documentació

- [Guia Completa de Gestió](GUIA_COMPLETA_GESTIO_PROJECTE.md)
- [Deploy a Google Cloud Run](DEPLOY_GOOGLE_CLOUD_RUN.md)
- [Guia Ràpida](GUIA_RAPIDA_GOOGLE_CLOUD.md)
- [Com Accedir](COM_ACCEDIR_APLICACIO.md)

## 🧹 Neteja del Projecte

Per eliminar fitxers temporals i documentació antiga:

```bash
NETEJAR_PROJECTE.bat
```

## 🔧 Desenvolupament Local

### Requisits

- Python 3.10+
- PostgreSQL
- Redis

### Instal·lació

```bash
# Backend
cd backend
pip install -r requirements.txt
python main.py

# Frontend
cd frontend
pip install -r requirements.txt
streamlit run app.py

# Worker
cd worker
pip install -r requirements-worker.txt
python processor.py
```

## 📝 Estructura del Projecte

```
mobil_scan/
├── backend/              # API FastAPI
│   ├── main.py
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/             # Interfície Streamlit
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── worker/               # Processament vídeos
│   ├── processor.py
│   ├── Dockerfile
│   ├── requirements-worker.txt
│   └── cpp_scanner/      # Test C++ zxing
│       ├── CMakeLists.txt
│       └── src/
│           └── barcode_test.cpp
├── shared/               # Recursos compartits
│   ├── database.py
│   ├── videos/
│   ├── frames/
│   └── results/
├── cloudbuild.yaml       # Build al núvol
├── .gitignore
└── README.md
```

## 🤝 Contribuir

1. Fork el projecte
2. Crea una branca (`git checkout -b feature/nova-funcionalitat`)
3. Commit els canvis (`git commit -m 'Afegir nova funcionalitat'`)
4. Push a la branca (`git push origin feature/nova-funcionalitat`)
5. Obre un Pull Request

## 📄 Llicència

Aquest projecte està sota llicència MIT.

## 👤 Autor

Ferran Palacín - [ferranpalacin@gmail.com](mailto:ferranpalacin@gmail.com)

## 🙏 Agraïments

- [YOLOv8](https://github.com/ultralytics/ultralytics) per la detecció d'objectes
- [zxing-cpp](https://github.com/zxing-cpp/zxing-cpp) per la decodificació de codis
- [Google Cloud Run](https://cloud.google.com/run) per l'hosting

---

**Fet amb ❤️ i desplegat al núvol ☁️**
