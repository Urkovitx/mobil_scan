# 📋 Fitxers Essencials del Projecte

## ✅ MANTENIR AQUESTS FITXERS

### 📚 Documentació Principal
- `README.md` - Documentació principal del projecte
- `ARQUITECTURA_DUAL_IA.md` - Arquitectura Cloud + Raspberry
- `CONFIGURAR_GEMINI_API.md` - Configuració Gemini API
- `RESUM_INTEGRACIO_IA.md` - Resum integració IA
- `GUIA_INTEGRACIO_LLM.md` - Guia LLM/Ollama
- `DEPLOY_GOOGLE_CLOUD_RUN.md` - Guia deploy Cloud Run
- `ACCEDIR_DES_DEL_MOBIL.md` - Accés des del mòbil

### 🚀 Scripts de Desplegament
- `DEPLOY_AMB_IA.bat` - Deploy amb IA a Cloud Run
- `ACTUALITZAR_APLICACIO.bat` - Actualitzar aplicació
- `NETEJAR_PROJECTE.bat` - Neteja Docker
- `OBTENIR_URL.bat` - Obtenir URLs dels serveis

### 🐳 Docker
- `docker-compose.yml` - Configuració Docker principal
- `docker-compose.llm.yml` - Configuració amb Ollama
- `cloudbuild.yaml` - Build a Google Cloud

### 📁 Codi Font
- `backend/` - Tot el directori
- `frontend/` - Tot el directori
- `worker/` - Tot el directori
- `shared/` - Tot el directori
- `.github/workflows/` - Només mantenir un workflow principal

### ⚙️ Configuració
- `.gitignore`
- `requirements.txt`
- `requirements-base.txt`

---

## ❌ ELIMINAR AQUESTS FITXERS

### Documentació de Proves/Tests
- Tots els `SOLUCIO_*.md`
- Tots els `BUILD_*.md`
- Tots els `REBUILD_*.md`
- Tots els `PROBLEMA_*.md`
- Tots els `ERROR_*.md`
- Tots els `TEST_*.md`
- Tots els `VERIFICAR_*.md`
- Tots els `DIAGNOSTICAR_*.md`

### Scripts Duplicats
- `build_*.bat` (excepte els essencials)
- `rebuild_*.bat`
- `check_*.bat`
- `test_*.bat`
- Scripts `.sh` de proves

### Docker Compose Duplicats
- `docker-compose.cloud.yml`
- `docker-compose.hub.yml`
- `docker-compose.hub-millores.yml`
- `docker-compose.prod.yml`

### Logs i Temporals
- `build_log.txt`
- `build_output.txt`
- `*.csv` (resultats de tests)
- `*.mp4` (vídeos de prova)

---

## 🎯 Resultat Final

Després de la neteja hauràs de tenir:
- ~10-15 fitxers .md (documentació essencial)
- ~5-10 fitxers .bat (scripts essencials)
- 2 docker-compose (principal + llm)
- 1 cloudbuild.yaml
- Directoris de codi font intactes

**Total:** ~90% menys fitxers innecessaris!
