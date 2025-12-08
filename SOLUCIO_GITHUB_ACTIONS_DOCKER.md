# 🔧 Solució Error GitHub Actions: Docker Login

## ⚠️ Problema

GitHub Actions falla amb:
```
Error: Username and password required
```

**Causa:** El workflow `.github/workflows/docker-build.yml` intenta fer login a Docker Hub però no tens els secrets configurats.

---

## ✅ Solució Ràpida (Recomanada)

**Desactiva el workflow de Docker Hub** ja que estàs usant Google Cloud Run:

### Opció A: Renombrar el fitxer (Desactivar temporalment)

```bash
# Renombra el fitxer per desactivar-lo
cd .github/workflows
mv docker-build.yml docker-build.yml.disabled
```

### Opció B: Eliminar el fitxer

```bash
# Elimina el fitxer si no el necessites
rm .github/workflows/docker-build.yml
```

---

## 🔄 Solució Alternativa (Si vols usar Docker Hub)

Si vols mantenir Docker Hub, configura els secrets:

### Pas 1: Crear compte Docker Hub

1. Ves a https://hub.docker.com/
2. Crea un compte (si no en tens)
3. Verifica el teu email

### Pas 2: Crear Access Token

1. Ves a https://hub.docker.com/settings/security
2. Clica "New Access Token"
3. Nom: `github-actions`
4. Permisos: `Read, Write, Delete`
5. Copia el token (només es mostra una vegada!)

### Pas 3: Configurar Secrets a GitHub

1. Ves al teu repositori: https://github.com/Urkovitx/mobil_scan
2. Clica "Settings" > "Secrets and variables" > "Actions"
3. Clica "New repository secret"

**Secret 1:**
- Name: `DOCKER_USERNAME`
- Value: El teu username de Docker Hub (ex: `urkovitx`)

**Secret 2:**
- Name: `DOCKER_PASSWORD`
- Value: El token que has copiat

### Pas 4: Re-executar el Workflow

1. Ves a "Actions"
2. Selecciona el workflow fallat
3. Clica "Re-run all jobs"

---

## 🎯 Recomanació

**Per al teu cas (Google Cloud Run):**

✅ **Desactiva el workflow de Docker Hub**
- No el necessites
- Google Cloud Build ja compila les imatges
- Estalvies temps i recursos

**Comanda ràpida:**

```bash
cd "c:/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"
mv .github/workflows/docker-build.yml .github/workflows/docker-build.yml.disabled
git add .github/workflows/
git commit -m "🔧 Desactiva workflow Docker Hub (no necessari per Cloud Run)"
git push origin master
```

---

## 📊 Comparació

| Opció | Avantatges | Desavantatges |
|-------|------------|---------------|
| **Desactivar Docker Hub** | ✅ Ràpid<br>✅ Sense configuració<br>✅ Sense costos | ❌ No tens imatges a Docker Hub |
| **Configurar Docker Hub** | ✅ Imatges públiques<br>✅ Backup | ❌ Configuració extra<br>❌ Temps de build duplicat |

---

## 🚀 Executa Ara

**Per desactivar el workflow:**

```bash
# 1. Renombra el fitxer
mv .github/workflows/docker-build.yml .github/workflows/docker-build.yml.disabled

# 2. Commit i push
git add .github/workflows/
git commit -m "🔧 Desactiva workflow Docker Hub"
git push origin master
```

**Això resoldrà l'error immediatament!**

---

## 🆘 Troubleshooting

### Error persisteix després de desactivar

**Solució:** Assegura't que el fitxer està realment desactivat:

```bash
ls -la .github/workflows/
# Hauria de mostrar: docker-build.yml.disabled
```

### Vull usar Docker Hub en el futur

**Solució:** Simplement renombra el fitxer de nou:

```bash
mv .github/workflows/docker-build.yml.disabled .github/workflows/docker-build.yml
```

I configura els secrets com s'explica a la "Solució Alternativa".

---

## ✅ Verificació

Després de desactivar el workflow:

1. Ves a GitHub Actions
2. No hauria d'aparèixer "Build and Push Docker Images"
3. Només hauries de veure els workflows de Cloud Build (si n'hi ha)

**Problema resolt! 🎉**
