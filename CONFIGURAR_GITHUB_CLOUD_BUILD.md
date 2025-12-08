# 🔗 Connectar GitHub amb Google Cloud Build

## ✅ Avantatges

Quan connectes GitHub amb Google Cloud:
- ✅ **CI/CD Automàtic**: Cada `git push` desplega automàticament
- ✅ **No més builds manuals**: Google compila al núvol
- ✅ **Historial de deploys**: Veus tots els canvis
- ✅ **Rollback fàcil**: Tornar a versions anteriors
- ✅ **Més ràpid**: Build paral·lel al núvol

---

## 📋 Passos per Configurar

### Pas 1: Connectar Repositori GitHub

```bash
# A la consola de Google Cloud:
1. Ves a: Cloud Build > Triggers
2. Clica "Connect Repository"
3. Selecciona "GitHub"
4. Autoritza Google Cloud a accedir al teu GitHub
5. Selecciona el repositori: Urkovitx/mobil_scan (o el teu)
6. Clica "Connect"
```

### Pas 2: Crear Trigger Automàtic

```bash
# A Cloud Build > Triggers:
1. Clica "Create Trigger"
2. Nom: "deploy-on-push"
3. Event: "Push to a branch"
4. Branch: "^master$" (o "^main$")
5. Configuration: "Cloud Build configuration file (yaml or json)"
6. Location: "cloudbuild.yaml"
7. Clica "Create"
```

### Pas 3: Configurar Variables d'Entorn

```bash
# A Cloud Build > Settings > Service account permissions:
1. Activa "Cloud Run Admin"
2. Activa "Service Account User"

# Afegir secrets (API Keys):
gcloud secrets create GEMINI_API_KEY \
  --data-file=- <<< "AlzaSyBhqEmRPC8n-wsxwyR8nNeQIQIp0LqbYA8" \
  --project mobil-scan-app

# Donar permisos a Cloud Build per accedir als secrets:
gcloud secrets add-iam-policy-binding GEMINI_API_KEY \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor" \
  --project mobil-scan-app
```

### Pas 4: Actualitzar cloudbuild.yaml

El fitxer `cloudbuild.yaml` ja està configurat correctament amb:
- Build de backend, frontend i worker
- Push a Container Registry
- Deploy automàtic a Cloud Run
- Configuració de variables d'entorn

---

## 🚀 Com Funciona Ara

```bash
# 1. Fas canvis al codi
git add .
git commit -m "Nou canvi"
git push origin master

# 2. Google Cloud detecta el push automàticament
# 3. Executa cloudbuild.yaml
# 4. Compila les imatges Docker
# 5. Desplega a Cloud Run
# 6. L'aplicació s'actualitza automàticament!
```

**Temps total: 5-10 minuts** (automàtic)

---

## 📊 Monitoritzar Deploys

```bash
# Veure historial de builds:
gcloud builds list --project mobil-scan-app

# Veure logs d'un build específic:
gcloud builds log BUILD_ID --project mobil-scan-app

# O a la consola web:
https://console.cloud.google.com/cloud-build/builds
```

---

## 🔧 Troubleshooting

### Error: "Permission denied"
```bash
# Dona permisos a Cloud Build:
gcloud projects add-iam-policy-binding mobil-scan-app \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/run.admin"
```

### Error: "Secret not found"
```bash
# Verifica que el secret existeix:
gcloud secrets list --project mobil-scan-app

# Crea'l si no existeix:
gcloud secrets create GEMINI_API_KEY \
  --data-file=- <<< "LA_TEVA_API_KEY" \
  --project mobil-scan-app
```

---

## ✅ Verificar que Funciona

1. Fes un petit canvi (ex: afegeix un comentari al README.md)
2. Fes commit i push:
   ```bash
   git add README.md
   git commit -m "Test CI/CD"
   git push origin master
   ```
3. Ves a Cloud Build > History
4. Hauries de veure un build en procés
5. Quan acabi, l'aplicació estarà actualitzada!

---

## 🎉 Beneficis Finals

- **Abans**: Build manual → 30 minuts
- **Ara**: `git push` → 5-10 minuts automàtics
- **Abans**: Errors locals de Docker
- **Ara**: Build al núvol, sempre funciona
- **Abans**: Configuració manual
- **Ara**: Tot automàtic

**Recomanació: SÍ, connecta GitHub amb Google Cloud!** 🚀
