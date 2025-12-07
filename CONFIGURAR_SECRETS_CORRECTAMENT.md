# 🔐 CONFIGURAR SECRETS CORRECTAMENT

## ❌ PROBLEMA IDENTIFICAT

Error: "Username and password required"

**Causa:** Els secrets estan buits o incorrectes.

---

## ✅ SOLUCIÓ: Configurar els Secrets Correctament

### 📋 QUÈ HAS DE FER

Necessites 2 secrets:
1. **DOCKER_USERNAME** → El teu nom d'usuari de Docker Hub
2. **DOCKER_PASSWORD** → Un token d'accés de Docker Hub

---

## 🔑 PAS 1: CREAR TOKEN A DOCKER HUB

### 1. Anar a Docker Hub:
```
https://hub.docker.com/settings/security
```

### 2. Login amb el teu compte:
- Username: **urkovitx**
- Password: [la teva contrasenya]

### 3. Crear Access Token:
- Click botó **"New Access Token"**
- Access Token Description: `github-actions`
- Access permissions: **Read, Write, Delete**
- Click **"Generate"**

### 4. COPIAR EL TOKEN:
```
⚠️ IMPORTANT: Apareixerà un cop només!
Exemple: dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz

📋 COPIA'L IMMEDIATAMENT!
```

---

## 🔐 PAS 2: CONFIGURAR SECRETS A GITHUB

### Secret 1: DOCKER_USERNAME

1. **Anar a:**
   ```
   https://github.com/urkovitx/mobil_scan/settings/secrets/actions
   ```

2. **Si ja existeix DOCKER_USERNAME:**
   - Click al llapis (Edit) al costat de DOCKER_USERNAME
   - O esborrar-lo i crear-lo de nou

3. **Al camp "Value" escriu EXACTAMENT:**
   ```
   urkovitx
   ```
   ⚠️ Sense espais, sense cometes, només: urkovitx

4. **Click "Update secret"**

---

### Secret 2: DOCKER_PASSWORD

1. **Click "New repository secret"**

2. **Name:**
   ```
   DOCKER_PASSWORD
   ```

3. **Value:**
   ```
   [ENGANXA AQUÍ EL TOKEN QUE HAS COPIAT DE DOCKER HUB]
   ```
   
   Exemple (el teu serà diferent):
   ```
   dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz
   ```
   
   ⚠️ IMPORTANT:
   - Sense espais abans ni després
   - Tot el token complet
   - Sense cometes

4. **Click "Add secret"**

---

## ✅ VERIFICAR QUE ESTÀ BÉ

Hauries de veure:

```
Repository secrets

DOCKER_USERNAME     Updated now
DOCKER_PASSWORD     Updated now
```

---

## 🚀 PAS 3: RE-EXECUTAR EL WORKFLOW

### 1. Anar a Actions:
```
https://github.com/urkovitx/mobil_scan/actions
```

### 2. Click al workflow que ha fallat

### 3. Click botó "Re-run all jobs" (dreta)

### 4. Esperar 15-20 minuts

---

## 📝 EXEMPLE VISUAL

### ❌ INCORRECTE:
```
Name: DOCKER_USERNAME
Value: ${{ secrets.DOCKER_USERNAME }}  ← MAL!
```

### ✅ CORRECTE:
```
Name: DOCKER_USERNAME
Value: urkovitx  ← BÉ!
```

---

### ❌ INCORRECTE:
```
Name: DOCKER_PASSWORD
Value: [buit]  ← MAL!
```

### ✅ CORRECTE:
```
Name: DOCKER_PASSWORD
Value: dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz  ← BÉ!
```

---

## 🔍 ERRORS COMUNS

### Error 1: Copiar el nom del secret en lloc del valor
```
❌ MAL:
Value: DOCKER_USERNAME

✅ BÉ:
Value: urkovitx
```

### Error 2: Copiar la sintaxi del YAML
```
❌ MAL:
Value: ${{ secrets.DOCKER_PASSWORD }}

✅ BÉ:
Value: dckr_pat_abc123...
```

### Error 3: Espais extra
```
❌ MAL:
Value: " urkovitx "

✅ BÉ:
Value: urkovitx
```

### Error 4: Token incomplet
```
❌ MAL:
Value: dckr_pat_123...  (truncat)

✅ BÉ:
Value: dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz  (complet)
```

---

## 📋 CHECKLIST

- [ ] Anar a Docker Hub Security
- [ ] Crear Access Token
- [ ] COPIAR el token complet
- [ ] Anar a GitHub Secrets
- [ ] Editar/Crear DOCKER_USERNAME
- [ ] Value: `urkovitx` (sense res més)
- [ ] Editar/Crear DOCKER_PASSWORD
- [ ] Value: [token complet de Docker Hub]
- [ ] Verificar que els 2 secrets existeixen
- [ ] Re-executar el workflow
- [ ] Esperar 15-20 minuts

---

## 🎯 RESUM RÀPID

### Què has de posar:

**DOCKER_USERNAME:**
```
urkovitx
```

**DOCKER_PASSWORD:**
```
[El token que obtens de Docker Hub]
Exemple: dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz
```

---

## 🆘 SI ENCARA FALLA

### Verificar:
1. ✅ Token de Docker Hub vàlid (no caducat)
2. ✅ Permisos: Read, Write, Delete
3. ✅ Username exacte: `urkovitx` (sense majúscules)
4. ✅ Token complet (sense truncar)
5. ✅ Sense espais extra

---

**🔑 Segueix aquests passos i el build funcionarà!**
