# 🔧 Solució Error Cloud Build: "Dockerfile not found"

## ❌ Error Rebut

```
unable to prepare context: unable to evaluate symlinks in Dockerfile path: 
lstat /workspace/Dockerfile: no such file or directory
```

## 🎯 Causa del Problema

Cloud Build està intentant fer un **"source deploy" automàtic** en lloc d'usar el fitxer `cloudbuild.yaml`. Això passa quan:

1. Connectes el repositori GitHub a Cloud Build
2. Cloud Build intenta detectar automàticament com compilar
3. Busca un `Dockerfile` a l'arrel (però els teus estan a `backend/`, `frontend/`, `worker/`)

## ✅ Solució Implementada

He creat dos fitxers per solucionar-ho:

### 1. `.gcloudignore` ✅
- Indica a Cloud Build quins fitxers ignorar
- Evita pujar fitxers innecessaris
- Millora la velocitat del build

### 2. Configuració del Trigger

Quan configuris el trigger a Cloud Build, **IMPORTANT**:

```yaml
# A Cloud Build > Triggers > Create Trigger:

Nom: deploy-on-push
Event: Push to branch
Branch: ^master$

# ⚠️ IMPORTANT: Selecciona aquesta opció:
Configuration: Cloud Build configuration file (yaml or json)
Location: cloudbuild.yaml  # ← AIXÒ ÉS CLAU!

# NO seleccionis "Autodetect" o "Dockerfile"
```

## 🚀 Passos per Configurar Correctament

### Opció A: Via Consola Web (RECOMANAT)

1. Ves a: https://console.cloud.google.com/cloud-build/triggers
2. Clica "CREATE TRIGGER"
3. Configura:
   - **Name**: `deploy-on-push`
   - **Event**: Push to a branch
   - **Source**: Selecciona el teu repositori GitHub
   - **Branch**: `^master$` (o `^main$`)
   - **Configuration**: 
     - ✅ Selecciona: **Cloud Build configuration file (yaml or json)**
     - ✅ Location: `cloudbuild.yaml`
     - ❌ NO seleccionis "Autodetect" o "Dockerfile"
4. Clica "CREATE"

### Opció B: Via CLI

```bash
gcloud builds triggers create github \
  --name="deploy-on-push" \
  --repo-name="mobil_scan" \
  --repo-owner="Urkovitx" \
  --branch-pattern="^master$" \
  --build-config="cloudbuild.yaml" \
  --project="mobil-scan-app"
```

## 📋 Verificar que Funciona

1. Fes un petit canvi al codi:
   ```bash
   echo "# Test CI/CD" >> README.md
   git add README.md
   git commit -m "Test: Verificar CI/CD"
   git push origin master
   ```

2. Ves a Cloud Build > History
3. Hauries de veure un build en procés
4. El build hauria d'usar `cloudbuild.yaml` (veuràs 3 steps: backend, frontend, worker)

## 🔍 Com Saber si Està Correcte

**Build CORRECTE** (usa cloudbuild.yaml):
```
✅ Step 1: build-backend
✅ Step 2: build-frontend  
✅ Step 3: build-worker
✅ Step 4: push-backend-latest
✅ Step 5: push-frontend-latest
✅ Step 6: push-worker-latest
```

**Build INCORRECTE** (autodetect):
```
❌ Step 1: Dockerfile not found
```

## 🆘 Si Encara Falla

### Solució 1: Elimina i Recrea el Trigger

```bash
# Llista triggers
gcloud builds triggers list --project mobil-scan-app

# Elimina el trigger incorrecte
gcloud builds triggers delete TRIGGER_ID --project mobil-scan-app

# Crea'l de nou amb la configuració correcta (Opció B de dalt)
```

### Solució 2: Verifica el cloudbuild.yaml

```bash
# Assegura't que cloudbuild.yaml està al repositori:
git ls-files | grep cloudbuild.yaml

# Si no apareix, afegeix-lo:
git add cloudbuild.yaml
git commit -m "Add cloudbuild.yaml"
git push origin master
```

### Solució 3: Build Manual per Testar

```bash
# Prova el build manualment:
gcloud builds submit --config=cloudbuild.yaml --project mobil-scan-app

# Si funciona manualment, el problema és la configuració del trigger
```

## ✅ Checklist Final

- [ ] Fitxer `cloudbuild.yaml` existeix a l'arrel del repositori
- [ ] Fitxer `.gcloudignore` creat
- [ ] Trigger configurat amb "Cloud Build configuration file"
- [ ] Location del trigger: `cloudbuild.yaml`
- [ ] NO està en mode "Autodetect"
- [ ] Build manual funciona: `gcloud builds submit --config=cloudbuild.yaml`

## 🎉 Resultat Esperat

Després de configurar correctament:
- Cada `git push` → Build automàtic
- Build usa `cloudbuild.yaml`
- Compila backend, frontend i worker
- Desplega automàticament a Cloud Run
- Temps: 5-10 minuts

**Ara sí que tens CI/CD automàtic! 🚀**
