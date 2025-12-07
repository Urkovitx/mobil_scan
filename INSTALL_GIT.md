# 🔧 INSTAL·LAR GIT - 3 Minuts

## ⚡ OPCIÓ RÀPIDA: Winget (Recomanat)

Si tens Windows 11 o Windows 10 actualitzat:

```powershell
# A la terminal de VSCode:
winget install --id Git.Git -e --source winget
```

**Després:** Tanca i obre VSCode

---

## 📥 OPCIÓ MANUAL: Descarregar Instal·lador

### 1. Descarregar:
https://git-scm.com/download/win

### 2. Executar instal·lador:
- Click "Next" a tot
- **IMPORTANT:** Seleccionar "Git from the command line and also from 3rd-party software"
- Deixar opcions per defecte

### 3. Verificar:
```powershell
git --version
```

---

## 🚀 DESPRÉS D'INSTAL·LAR

### 1. Configurar Git:
```powershell
git config --global user.name "urkovitx"
git config --global user.email "el_teu_email@gmail.com"
```

### 2. Executar script:
```powershell
.\setup_github_actions.bat
```

---

## ⏱️ TEMPS TOTAL: 3-5 minuts
