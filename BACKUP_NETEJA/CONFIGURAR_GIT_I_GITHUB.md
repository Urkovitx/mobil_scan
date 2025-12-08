# 🔧 CONFIGURAR GIT I GITHUB - Guia Pas a Pas

## 📋 INFORMACIÓ DEL TEU COMPTE

Segons la captura de pantalla:

- **Username GitHub**: `Urkovitx` (amb majúscula U)
- **Nom**: `Ferran`
- **Email**: (necessitem configurar-lo)

---

## 🚀 PAS 1: CONFIGURAR GIT (Obligatori)

### Des de WSL2 o Git Bash:

```bash
# Configurar nom (el que vulguis que aparegui als commits)
git config --global user.name "Ferran"

# Configurar email (ha de ser el mateix que a GitHub)
git config --global user.email "ferran@example.com"  # CANVIA AIXÒ!

# Verificar configuració
git config --global --list
```

**IMPORTANT**: Canvia `ferran@example.com` pel teu email real de GitHub.

### Per trobar el teu email de GitHub:

```
1. Ves a: https://github.com/settings/emails
2. Copia el teu email principal
3. Usa'l a la comanda de dalt
```

---

## 🔑 PAS 2: CREAR PERSONAL ACCESS TOKEN (PAT)

GitHub **NO accepta contrasenyes** per Git. Necessites un **Personal Access Token**.

### Crear Token:

```
1. Ves a: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Nom: "Mobil Scan Development"
4. Expiration: "No expiration" (o 90 dies)
5. Selecciona scopes:
   ✅ repo (tots)
   ✅ workflow
   ✅ write:packages
   ✅ read:packages
6. Click "Generate token"
7. COPIA EL TOKEN (només es mostra una vegada!)
```

**Exemple de token**: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## 🔐 PAS 3: GUARDAR CREDENCIALS

### Opció A: Credential Helper (RECOMANAT)

```bash
# Configurar Git per recordar credencials
git config --global credential.helper store

# Ara quan facis push, introdueix:
# Username: Urkovitx
# Password: [EL TEU TOKEN ghp_xxx...]

# Git guardarà les credencials automàticament
```

### Opció B: SSH (Més segur, però més complex)

```bash
# Generar clau SSH
ssh-keygen -t ed25519 -C "ferran@example.com"

# Copiar clau pública
cat ~/.ssh/id_ed25519.pub

# Afegir a GitHub:
# https://github.com/settings/keys
# Click "New SSH key"
# Enganxa la clau

# Canviar remote a SSH
git remote set-url origin git@github.com:Urkovitx/mobil_scan.git
```

---

## ✅ PAS 4: TESTEJAR CONFIGURACIÓ

```bash
# Navegar al projecte
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan

# Verificar remote
git remote -v

# Hauria de mostrar:
# origin  https://github.com/Urkovitx/mobil_scan.git (fetch)
# origin  https://github.com/Urkovitx/mobil_scan.git (push)

# Test commit
git add .
git commit -m "Test configuration"
git push

# Quan demani credencials:
# Username: Urkovitx
# Password: [EL TEU TOKEN ghp_xxx...]
```

---

## 🐛 TROUBLESHOOTING

### Error: "fatal: empty ident name"

```bash
# Solució: Configurar nom i email
git config --global user.name "Ferran"
git config --global user.email "el-teu-email@example.com"
```

### Error: "Invalid username or token"

```bash
# Solució: Utilitzar token, no contrasenya
# Username: Urkovitx (amb U majúscula!)
# Password: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (el token)
```

### Error: "Authentication failed"

```bash
# Verificar que el token té els permisos correctes
# Ves a: https://github.com/settings/tokens
# Edita el token i assegura't que té:
# ✅ repo
# ✅ workflow
# ✅ write:packages
```

### Error: "remote: Invalid username or token"

```bash
# El username ha de ser exactament: Urkovitx (amb U majúscula)
# NO: urkovitx, Ferran, ferran
# SÍ: Urkovitx
```

---

## 📝 RESUM RÀPID

### Configuració Inicial (Una vegada):

```bash
# 1. Configurar Git
git config --global user.name "Ferran"
git config --global user.email "el-teu-email@gmail.com"
git config --global credential.helper store

# 2. Crear token a GitHub
# https://github.com/settings/tokens
# Copia el token: ghp_xxx...

# 3. Primer push (introduir credencials)
git push
# Username: Urkovitx
# Password: ghp_xxx... (el token)

# 4. A partir d'ara, Git recordarà les credencials!
```

---

## 🎯 COMANDES COMPLETES PER COPIAR

```bash
# Navegar al projecte
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan

# Configurar Git (CANVIA L'EMAIL!)
git config --global user.name "Ferran"
git config --global user.email "el-teu-email@gmail.com"
git config --global credential.helper store

# Verificar configuració
git config --global --list

# Afegir canvis
git add .

# Commit
git commit -m "Add preprocessing and AI tab improvements"

# Push (introduir credencials la primera vegada)
git push
# Username: Urkovitx
# Password: [TOKEN de https://github.com/settings/tokens]
```

---

## 🔑 ON TROBAR EL TOKEN

```
1. Ves a: https://github.com/settings/tokens
2. Si ja tens un token:
   - Usa'l (si el tens guardat)
   - O crea'n un de nou
3. Si no tens cap token:
   - Click "Generate new token (classic)"
   - Segueix els passos del PAS 2
```

---

## ✅ CHECKLIST

- [ ] Git configurat (user.name i user.email)
- [ ] Token creat a GitHub
- [ ] Token copiat i guardat
- [ ] Credential helper activat
- [ ] Primer push amb credencials
- [ ] Git recorda credencials
- [ ] Push funciona sense demanar credencials

---

## 🎉 DESPRÉS DE CONFIGURAR

```bash
# Ara ja pots fer push sense problemes!
git add .
git commit -m "Add improvements"
git push

# GitHub Actions farà el build automàticament
# Espera 5-10 min
# Després executa: RUN_FROM_HUB_MILLORES.bat
```

---

🔧 **CONFIGURA GIT UNA VEGADA I OBLIDA'T!** 🔧

📖 **Segueix els passos i estaràs llest en 5 minuts!**
