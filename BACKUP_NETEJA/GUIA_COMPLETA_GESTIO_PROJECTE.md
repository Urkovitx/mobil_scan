# 🎯 Guia Completa de Gestió del Projecte

## 📋 Índex de Continguts

1. [Provar l'Aplicació](#1-provar-laplicació)
2. [Introduir Canvis i Millores](#2-introduir-canvis-i-millores)
3. [Connectar amb Git/GitHub](#3-connectar-amb-gitgithub)
4. [Neteja de Fitxers](#4-neteja-de-fitxers)
5. [Integració d'IA (Ollama)](#5-integració-dia-ollama)

---

## 1. 🧪 Provar l'Aplicació

### Opció A: Obtenir URL del Frontend

```bash
gcloud run services describe mobil-scan-frontend \
  --region europe-west1 \
  --format="value(status.url)" \
  --project mobil-scan-app
```

### Opció B: Llistar Tots els Serveis

```bash
gcloud run services list --project=mobil-scan-app
```

### Opció C: Consola Web

👉 https://console.cloud.google.com/run?project=mobil-scan-app

### Com Provar:

1. **Obre la URL del frontend** al navegador
2. **Puja un vídeo** amb codis de barres
3. **Espera el processament** (apareixerà a la llista)
4. **Visualitza els resultats** (deteccions i codis)

### Test des del Mòbil:

1. Envia la URL al mòbil (WhatsApp, email)
2. Obre-la al navegador del mòbil
3. Funciona igual que al PC!

---

## 2. 🔄 Introduir Canvis i Millores

### Workflow Recomanat:

#### Pas 1: Fer Canvis Localment

```bash
# Edita els fitxers que necessitis
# Per exemple: frontend/app.py, worker/processor.py, etc.
```

#### Pas 2: Rebuild al Núvol

```bash
cd "C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan"
gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app
```

**Temps:** 15-20 minuts (més ràpid que la primera vegada)

#### Pas 3: Redesplegar Serveis

```bash
# Frontend
gcloud run deploy mobil-scan-frontend \
  --image gcr.io/mobil-scan-app/mobil-scan-frontend:latest \
  --region europe-west1 \
  --project mobil-scan-app

# Backend
gcloud run deploy mobil-scan-backend \
  --image gcr.io/mobil-scan-app/mobil-scan-backend:latest \
  --region europe-west1 \
  --project mobil-scan-app

# Worker
gcloud run deploy mobil-scan-worker \
  --image gcr.io/mobil-scan-app/mobil-scan-worker:latest \
  --region europe-west1 \
  --project mobil-scan-app
```

#### Pas 4: Verificar

Refresca el navegador i comprova els canvis!

### Script Automàtic (Recomanat):

Crea `ACTUALITZAR_APLICACIO.bat`:

```batch
@echo off
echo Actualitzant aplicació...
gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app
if errorlevel 1 exit /b 1

echo Desplegant serveis...
DESPLEGAR_SERVEIS_ARA.bat
```

---

## 3. 🔗 Connectar amb Git/GitHub

### ✅ SÍ, És Molt Recomanable!

**Avantatges:**

- ✅ Control de versions
- ✅ Historial de canvis
- ✅ Rollback fàcil si alguna cosa falla
- ✅ Deploy automàtic amb GitHub Actions
- ✅ Col·laboració (si treballes amb altres)

### Configuració Ràpida:

#### Pas 1: Inicialitzar Git

```bash
cd "C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan"
git init
git add .
git commit -m "Initial commit - Cloud Run deployment"
```

#### Pas 2: Crear Repositori a GitHub

1. Ves a https://github.com/new
2. Nom: `mobil-scan-app`
3. Privat (recomanat)
4. NO inicialitzis amb README

#### Pas 3: Connectar i Pujar

```bash
git remote add origin https://github.com/TU_USUARIO/mobil-scan-app.git
git branch -M main
git push -u origin main
```

#### Pas 4: Connectar Cloud Run amb GitHub

A la consola de Cloud Run:

1. Clica "Connectar al repositori"
2. Selecciona GitHub
3. Autoritza Google Cloud
4. Selecciona el teu repositori
5. Configura:
   - **Branch:** main
   - **Build config:** cloudbuild.yaml
   - **Trigger:** Automàtic en cada push

**Resultat:** Cada cop que facis `git push`, es rebuildarà i redesplegarà automàticament! 🚀

### Workflow amb Git:

```bash
# 1. Fer canvis
# Edita fitxers...

# 2. Commit
git add .
git commit -m "Descripció dels canvis"

# 3. Push (trigger automàtic)
git push

# 4. Espera 15-20 minuts
# Cloud Run rebuildarà i redesplegarà automàticament!
```

---

## 4. 🧹 Neteja de Fitxers

### Fitxers a ELIMINAR (Brutícia):

#### Documentació Temporal:
```
ACLARIMENT_IMPORTANT.md
ALTERNATIVES_PROFESSIONALS.md
APLICACIO_FUNCIONANT.md
ARCHITECTURE.md
BUILD_LOCAL_AMB_IA_EN_PROGRES.md
COM_HO_FAN_ELS_PROFESSIONALS.md
CONFIGURAR_SECRETS_CORRECTAMENT.md
COPY_THIS_YAML.md
CRITICAL_PATH_TEST_RESULTS.md
DOCKER_BUILD_FIX.md
DOCKER_CLOUD_BUILD_SETUP.md
DOCKER_RESOURCE_ERROR.md
EMERGENCY_CHECK.bat
FINAL_PROJECT_SUMMARY.md
FINAL_SOLUTION_MEMORY.md
FINAL_SOLUTION.md
FINAL_YAML_OPTIMIZED.md
FIXED_YAML.md
FORCE_CLOSE_EVERYTHING.md
GITHUB_ACCOUNT_STRATEGY.md
GITHUB_ACTIONS_BUILD.yml
GITHUB_ACTIONS_SETUP.md
INSTALL_GIT.md
INSTRUCCIONS_CLARES_ARA.md
KILL_EVERYTHING_WINDOWS.md
LA_VERITAT_SOBRE_DOCKER.md
MANUAL_GITHUB_SETUP.md
MONITORITZAR_BUILD.md
NETEJA_TOTAL_DOCKER.md
NETWORK_TIMEOUT_FIX.md
PADDLEPADDLE_VERSION_FIX.md
PASSOS_FINALS.md
PLA_CORRECCIONS_FINALS.md
PROBLEMA_STREAMLIT_SOLUCIONAT.md
PROFESSIONAL_SOLUTIONS.md
PROJECT_SUMMARY.md
QUE_ESTA_PASSANT_BUILD.md
QUE_FER_ARA.md
QUE_FER_AVUI_DIUMENGE.md
QUICKSTART.md
REAL_PROBLEM_FOUND.md
REFACTOR_YOLO_SUMMARY.md
RESTART_WSL_AND_BUILD.md
RESUM_FINAL_SOLUCIO.md
SOLUTION_NOW.md
SOLUTION_RPC_ERROR.md
START_BUILD_NOW.md
SYSTEM_EXPLANATION.md
TESTING_REPORT.md
TESTING_RESULTS_YOLO_REFACTOR.md
UI_REDESIGN_SUMMARY.md
VERIFICACIO_REFACTOR_YOLO.md
VERIFICAR_I_SOLUCIONS.md
WAIT_FOR_BUILD.md
WHAT_IS_HAPPENING.md
WHY_NOT_IN_DOCKER_DESKTOP.md
```

#### Scripts Docker (MERDA segons tu 😄):
```
afegir_worker_simple.bat
afegir_worker.bat
ARREGLAR_DOCKER_PRIMER.bat
build_cloud.bat
BUILD_I_PUSH_LOCAL_FIXED.bat
BUILD_I_PUSH_LOCAL.bat
BUILD_NEW_WORKER.bat
build_sequential.bat
check_build_status.ps1
check_docker_status.bat
check_now.bat
check_worker_build.bat
CHECK_WORKER_STATUS.bat
CLEAN_ALL_DOCKER.bat
DEPLOY_DOCKER_HUB_ARA.bat
DEPLOY_FACIL.bat
DIAGNOSTICAR_I_ARREGLAR.bat
docker-compose.cloud.yml
docker-compose.hub-millores.yml
docker-compose.hub.yml
docker-compose.prod.yml
docker-compose.yml (mantenir només per referència local)
EXECUTAR_ARA_FINAL.bat
EXECUTAR_BUILD_GITHUB.md
executar_mobil_scan.bat
EXECUTAR_SENSE_MILLORES.bat
EXECUTE_NOW_OPTION_C.md
GIT_PUSH_WORKER.bat
INICIAR_DOCKER_I_EXECUTAR.bat
INICIAR_I_REBUILD.bat
REBUILD_ALL_NO_CACHE.bat
REBUILD_AMB_WSL2.md
REBUILD_BACKEND_ARA.bat
REBUILD_COMPLET_AMB_IA.bat
REBUILD_FRONTEND_ARA.bat
REBUILD_WORKER_MINIMAL.bat
REBUILD_WORKER_NO_CACHE.bat
REBUILD_WORKER_RETRY.bat
REBUILD_WORKER_SIMPLE.bat
REINICIAR_DOCKER_I_BUILD.bat
run_all_local.bat
run_cloud.bat
run_from_dockerhub.bat
RUN_FROM_HUB_MILLORES.bat
setup_cloud_builder.bat
setup_github_actions.bat
UTILITZAR_DOCKER_DESKTOP.bat
VERIFICAR_APLICACIO.bat
VERIFICAR_ESTAT_ARA.bat
```

#### Fitxers Docker Compose (WSL2):
```
iniciar_amb_llm_wsl.sh
iniciar_amb_ollama_opcional.sh
iniciar_local_simple.sh
iniciar_prod.sh
iniciar_worker_sense_llm.sh
rebuild_worker_cpu.sh
setup_docker_wsl2.sh
tornar_a_intentar.sh
check_llm_status.sh
instal·lar_docker_compose.sh
docker-compose.llm.yml
```

#### Altres:
```
build_log.txt
build_output.txt
worker_logs.txt
audit_results_*.csv
VID_20251204_170312.mp4
visio-stock-1765035550265.png
Barcodes.v1-no-augs.yolov8.zip (si ja tens el model extret)
```

### Fitxers a MANTENIR (Essencials):

```
✅ cloudbuild.yaml                    # Build al núvol
✅ .gitignore                         # Control de versions
✅ README.md                          # Documentació principal
✅ requirements.txt                   # Dependències base
✅ requirements-base.txt              # Dependències base

✅ backend/                           # Codi backend
✅ frontend/                          # Codi frontend
✅ worker/                            # Codi worker
✅ shared/                            # Recursos compartits

✅ DEPLOY_GOOGLE_CLOUD_RUN.md        # Guia deploy
✅ GUIA_RAPIDA_GOOGLE_CLOUD.md       # Guia ràpida
✅ COM_ACCEDIR_APLICACIO.md          # Com accedir
✅ RESUM_FINAL_GOOGLE_CLOUD.md       # Resum final
✅ GUIA_COMPLETA_GESTIO_PROJECTE.md  # Aquesta guia!

✅ DESPLEGAR_SERVEIS_ARA.bat         # Script deploy
✅ deploy_cloud_run.bat              # Script build+deploy
✅ SETUP_GOOGLE_CLOUD.bat            # Setup inicial

✅ GUIA_INTEGRACIO_LLM.md            # Integració IA
✅ GUIA_US_COMPLET_AMB_EXEMPLES.md   # Guia d'ús
```

### Script de Neteja Automàtica:

Crea `NETEJAR_PROJECTE.bat`:

```batch
@echo off
echo ========================================
echo NETEJA DEL PROJECTE
echo ========================================
echo.
echo Aquesta neteja eliminarà:
echo - Documentació temporal
echo - Scripts Docker (locals)
echo - Logs i fitxers temporals
echo.
echo Mantindrà:
echo - Codi font (backend, frontend, worker)
echo - cloudbuild.yaml
echo - Guies essencials
echo.
set /p CONFIRM="Estàs segur? (S/N): "
if /i not "%CONFIRM%"=="S" exit /b 0

echo.
echo Eliminant fitxers...

REM Documentació temporal
del /Q ACLARIMENT_IMPORTANT.md 2>nul
del /Q ALTERNATIVES_PROFESSIONALS.md 2>nul
del /Q APLICACIO_FUNCIONANT.md 2>nul
REM ... (afegir tots els fitxers de la llista)

REM Scripts Docker
del /Q *.bat 2>nul
del /Q *.sh 2>nul
del /Q docker-compose.*.yml 2>nul

REM Logs
del /Q *.log 2>nul
del /Q *.txt 2>nul
del /Q *.csv 2>nul

echo.
echo ✅ Neteja completada!
echo.
pause
```

**⚠️ IMPORTANT:** Revisa la llista abans d'executar!

---

## 5. 🤖 Integració d'IA (Ollama)

### ❌ NO Està Integrat Actualment

El projecte **NO** té Ollama integrat. Els fitxers que veus (`GUIA_INTEGRACIO_LLM.md`, etc.) són **documentació** de com fer-ho, però **no està implementat**.

### Per Què No Està Integrat?

1. **Complexitat:** Ollama requereix GPU o CPU potent
2. **Cost:** A Cloud Run, GPU és car (~100€/mes)
3. **Alternativa:** Millor usar APIs externes (OpenAI, Anthropic, etc.)

### Si Vols Integrar IA:

#### Opció A: API Externa (Recomanat)

**Avantatges:**
- ✅ Fàcil d'integrar
- ✅ Sense gestió d'infraestructura
- ✅ Cost predictible
- ✅ Millor rendiment

**Exemple amb OpenAI:**

```python
# frontend/app.py o worker/processor.py
import openai

openai.api_key = os.getenv("OPENAI_API_KEY")

def analitzar_barcode_amb_ia(barcode_text):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "Ets un expert en codis de barres"},
            {"role": "user", "content": f"Analitza aquest codi: {barcode_text}"}
        ]
    )
    return response.choices[0].message.content
```

**Cost:** ~0.03€ per 1000 requests

#### Opció B: Ollama a Cloud Run (No Recomanat)

**Desavantatges:**
- ❌ Requereix GPU (car)
- ❌ Cold start lent (30-60 segons)
- ❌ Gestió complexa
- ❌ Cost alt (~100€/mes)

**Si encara vols fer-ho:**

1. Afegir Ollama al `worker/Dockerfile`
2. Descarregar model (llama2, mistral, etc.)
3. Configurar GPU a Cloud Run
4. Augmentar memòria (8-16Gi)
5. Augmentar timeout (300s)

**No ho recomano per aquest projecte.**

#### Opció C: Ollama Local (Desenvolupament)

Per provar localment:

```bash
# Instal·lar Ollama
# Windows: https://ollama.ai/download

# Descarregar model
ollama pull llama2

# Executar
ollama run llama2
```

Però això és **només per desenvolupament local**, no per producció.

### Recomanació Final sobre IA:

**Per a aquest projecte (detecció de codis de barres):**

1. **Sense IA:** El projecte funciona perfectament sense IA
2. **Amb IA (si vols):** Usa API externa (OpenAI, Anthropic)
3. **NO usis Ollama** a Cloud Run (massa car i complex)

---

## 📊 Resum Final

### Workflow Recomanat:

```
1. Fer canvis localment
   ↓
2. git add . && git commit -m "..." && git push
   ↓
3. Cloud Run rebuilda automàticament (15-20 min)
   ↓
4. Refresca el navegador i prova!
```

### Estructura Final del Projecte:

```
mobil_scan/
├── backend/              # API FastAPI
├── frontend/             # Interfície Streamlit
├── worker/               # Processament vídeos
│   └── cpp_scanner/      # Test C++ zxing
├── shared/               # Recursos compartits
├── cloudbuild.yaml       # Build al núvol
├── .gitignore            # Git
├── README.md             # Documentació
└── GUIA_*.md             # Guies essencials
```

### Fitxers Essencials:

- ✅ Codi font (backend, frontend, worker)
- ✅ cloudbuild.yaml
- ✅ 4-5 guies .md essencials
- ✅ Scripts deploy (.bat)
- ❌ Tot Docker local (eliminar)
- ❌ Documentació temporal (eliminar)

### Pròxims Passos:

1. ✅ Provar l'aplicació (obtenir URL frontend)
2. ✅ Connectar amb GitHub (recomanat)
3. ✅ Netejar fitxers innecessaris
4. ✅ Fer canvis i millores (workflow Git)
5. ❌ NO integrar Ollama (usa API si vols IA)

---

**Tens alguna pregunta sobre algun d'aquests punts?** 🚀
