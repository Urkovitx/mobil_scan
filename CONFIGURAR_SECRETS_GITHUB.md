# 🔐 Configurar Secrets de GitHub per Docker Hub

## ❌ ERROR ACTUAL

```
Error: Username and password required
```

**Causa:** Els secrets `DOCKER_HUB_USERNAME` i `DOCKER_HUB_TOKEN` no estan configurats al repositori de GitHub.

---

## ✅ SOLUCIÓ: Configurar Secrets

### Pas 1: Obtenir Docker Hub Token

1. **Obre Docker Hub:**
   ```
   https://hub.docker.com/settings/security
   ```

2. **Login** amb el teu compte (urkovitx)

3. **Crea un Access Token:**
   - Click "New Access Token"
   - Description: `GitHub Actions - mobil_scan`
   - Access permissions: `Read, Write, Delete`
   - Click "Generate"

4. **COPIA EL TOKEN** (només es mostra una vegada!)
   ```
   Exemple: dckr_pat_abc123xyz789...
   ```

---

### Pas 2: Afegir Secrets a GitHub

1. **Obre el teu repositori:**
   ```
   https://github.com/Urkovitx/mobil_scan/settings/secrets/actions
   ```

2. **Click "New repository secret"**

3. **Afegeix el primer secret:**
   - Name: `DOCKER_HUB_USERNAME`
   - Value: `urkovitx`
   - Click "Add secret"

4. **Afegeix el segon secret:**
   - Click "New repository secret" de nou
   - Name: `DOCKER_HUB_TOKEN`
   - Value: `[el token que has copiat al Pas 1]`
   - Click "Add secret"

---

### Pas 3: Verificar Secrets

Hauries de veure 2 secrets:
```
✅ DOCKER_HUB_USERNAME
✅ DOCKER_HUB_TOKEN
```

---

### Pas 4: Tornar a executar el Workflow

1. **Obre GitHub Actions:**
   ```
   https://github.com/Urkovitx/mobil_scan/actions/workflows/build-all-images.yml
   ```

2. **Click "Run workflow":**
   - Branch: master
   - Click "Run workflow"

3. **Ara hauria de funcionar!** ✅

---

## 🎯 GUIA VISUAL

### 1. Docker Hub - Crear Token

```
Docker Hub → Settings → Security → New Access Token
↓
Description: GitHub Actions - mobil_scan
Permissions: Read, Write, Delete
↓
Generate → COPIA EL TOKEN!
```

### 2. GitHub - Afegir Secrets

```
GitHub Repo → Settings → Secrets and variables → Actions
↓
New repository secret
↓
Name: DOCKER_HUB_USERNAME
Value: urkovitx
↓
Add secret
↓
New repository secret
↓
Name: DOCKER_HUB_TOKEN
Value: [token de Docker Hub]
↓
Add secret
```

---

## 📝 CHECKLIST

- [ ] Login a Docker Hub
- [ ] Crear Access Token
- [ ] Copiar el token
- [ ] Anar a GitHub Settings → Secrets
- [ ] Afegir DOCKER_HUB_USERNAME
- [ ] Afegir DOCKER_HUB_TOKEN
- [ ] Verificar que els 2 secrets existeixen
- [ ] Tornar a executar el workflow

---

## ⚠️ IMPORTANT

**El token només es mostra UNA VEGADA!**

Si el perds:
1. Revoca el token antic
2. Crea un token nou
3. Actualitza el secret a GitHub

---

## 🔗 ENLLAÇOS DIRECTES

**Docker Hub Security:**
https://hub.docker.com/settings/security

**GitHub Secrets:**
https://github.com/Urkovitx/mobil_scan/settings/secrets/actions

**GitHub Actions:**
https://github.com/Urkovitx/mobil_scan/actions/workflows/build-all-images.yml

---

## ❓ PROBLEMES COMUNS

### "No puc accedir a Settings"
- Necessites ser owner/admin del repositori
- Si és un fork, necessites configurar-ho al teu fork

### "El token no funciona"
- Verifica que has copiat el token complet
- Verifica que el token té permisos Read, Write, Delete
- Prova de crear un token nou

### "Username incorrecte"
- Verifica que `DOCKER_HUB_USERNAME` és exactament: `urkovitx`
- Sense espais ni majúscules incorrectes

---

## 🎉 DESPRÉS DE CONFIGURAR

Un cop configurats els secrets:

1. ✅ El workflow funcionarà correctament
2. ✅ Les imatges es pujaran al Docker Hub
3. ✅ Podràs usar `run_from_dockerhub.bat`

---

**CONFIGURA ELS SECRETS ARA I TORNA A EXECUTAR EL WORKFLOW!** 🚀
