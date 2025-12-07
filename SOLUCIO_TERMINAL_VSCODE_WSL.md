# 🔧 Solució: Terminal VSCode Mata WSL

## 🎯 Problema

La terminal de VSCode no pot carregar Ubuntu (WSL) i es tanca/mata constantment.

**Això és un problema conegut de VSCode amb WSL2.**

---

## ✅ SOLUCIÓ: Utilitzar Windows Terminal (NO VSCode)

### Per Què Windows Terminal?

- ✅ **Més estable** amb WSL2
- ✅ **Millor rendiment**
- ✅ **No es tanca inesperadament**
- ✅ **Dissenyat específicament per WSL**
- ✅ **Recomanat per Microsoft**

---

## 🚀 Pas a Pas: Utilitzar Windows Terminal

### Pas 1: Obrir Windows Terminal

**Opció A: Des del Menú d'Inici**
1. Prem `Win` (tecla Windows)
2. Escriu "Terminal"
3. Clica "Windows Terminal"

**Opció B: Amb Drecera**
1. Prem `Win + X`
2. Selecciona "Windows Terminal"

**Opció C: Des de PowerShell/CMD**
1. Obre PowerShell o CMD
2. Escriu: `wt`

### Pas 2: Obrir Pestanya Ubuntu

1. **A Windows Terminal**, clica la **fletxa ▼** a la barra superior
2. Selecciona **"Ubuntu"** o **"Ubuntu-22.04"**
3. Ja tens una terminal Ubuntu funcionant! ✅

### Pas 3: Verificar que Estàs a Ubuntu

```bash
# Hauries de veure:
user@hostname:~$

# Verifica amb:
uname -a
# Hauria de dir "Linux"
```

---

## 🐳 Executar Comandes Docker

Ara que tens Windows Terminal amb Ubuntu, pots executar totes les comandes:

### Diagnòstic Ràpid

```bash
# Copia i enganxa això:
echo "=== DIAGNÒSTIC ==="
docker --version
sudo service docker status
ls ~/mobil_scan_linux
docker ps -a
echo "=== FI ==="
```

### Si Docker No Està Instal·lat

```bash
# Executar script d'instal·lació
cd "/mnt/c/Users/ferra/Projectes/Prova/PROJECTE SCAN AI/INSTALL_DOCKER_FILES/mobil_scan"
cp setup_docker_wsl2.sh ~
cd ~
chmod +x setup_docker_wsl2.sh
./setup_docker_wsl2.sh
```

### Si Docker Està Instal·lat però Contenidors No

```bash
# Iniciar Docker
sudo service docker start

# Anar al projecte
cd ~/mobil_scan_linux

# Build
docker build --no-cache --pull -f worker/Dockerfile.minimal -t mobil_scan-worker .

# Iniciar
docker compose up -d

# Verificar
docker compose ps
```

---

## 🔧 Solucionar Problema de VSCode (Opcional)

Si vols intentar arreglar VSCode (però Windows Terminal és millor):

### Solució 1: Reinstal·lar Extensió WSL

1. A VSCode, ves a Extensions (`Ctrl + Shift + X`)
2. Busca "WSL"
3. Desinstal·la l'extensió "WSL"
4. Reinicia VSCode
5. Torna a instal·lar "WSL"

### Solució 2: Netejar Configuració Terminal

1. Tanca VSCode completament
2. Elimina carpeta: `%APPDATA%\Code\User\workspaceStorage`
3. Torna a obrir VSCode

### Solució 3: Actualitzar WSL

```powershell
# A PowerShell (com a administrador):
wsl --update
wsl --shutdown
```

### Solució 4: Configurar Terminal per Defecte

A VSCode:
1. `Ctrl + ,` (Settings)
2. Busca: `terminal.integrated.defaultProfile.windows`
3. Canvia a "Command Prompt" o "PowerShell"
4. Després executa `wsl` manualment

---

## 💡 Recomanació Final

**NO utilitzis la terminal integrada de VSCode per WSL2.**

**Utilitza Windows Terminal** per:
- Executar comandes Docker
- Treballar amb WSL2
- Gestionar contenidors

**Utilitza VSCode** només per:
- Editar codi
- Navegar fitxers
- Debugging

---

## 📋 Workflow Recomanat

### 1. Editar Codi
- Obre VSCode
- Edita els fitxers que necessitis
- Guarda canvis

### 2. Executar Comandes
- Obre Windows Terminal
- Selecciona pestanya Ubuntu
- Executa comandes Docker

### 3. Verificar Resultats
- Obre navegador
- Accedeix a http://localhost:8501

---

## 🎯 Comandes Essencials (Windows Terminal)

### Iniciar Docker i Serveis

```bash
# 1. Iniciar Docker
sudo service docker start

# 2. Anar al projecte
cd ~/mobil_scan_linux

# 3. Iniciar serveis
docker compose up -d

# 4. Veure logs
docker compose logs -f worker

# 5. Verificar estat
docker compose ps
```

### Aturar Serveis

```bash
cd ~/mobil_scan_linux
docker compose down
```

### Rebuild

```bash
cd ~/mobil_scan_linux
docker compose build --no-cache worker
docker compose up -d
```

---

## 🔍 Verificar Instal·lació Completa

A Windows Terminal (Ubuntu):

```bash
# 1. Docker instal·lat?
docker --version

# 2. Docker en execució?
sudo service docker status

# 3. Projecte copiat?
ls ~/mobil_scan_linux

# 4. Contenidors actius?
cd ~/mobil_scan_linux
docker compose ps

# 5. zxing-cpp funcionant?
docker compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"
```

---

## 🆘 Si Windows Terminal Tampoc Funciona

### Opció 1: Ubuntu App Directa

1. Prem `Win`
2. Escriu "Ubuntu"
3. Obre "Ubuntu" o "Ubuntu 22.04 LTS"
4. Això obre una finestra Ubuntu nativa

### Opció 2: PowerShell + wsl

1. Obre PowerShell
2. Escriu: `wsl`
3. Ja estàs a Ubuntu

### Opció 3: Verificar WSL

```powershell
# A PowerShell (com a administrador):

# Verificar WSL instal·lat
wsl --list --verbose

# Actualitzar WSL
wsl --update

# Reiniciar WSL
wsl --shutdown

# Tornar a iniciar
wsl
```

---

## 📊 Comparativa de Terminals

| Terminal | WSL2 | Estabilitat | Recomanat |
|----------|------|-------------|-----------|
| **Windows Terminal** | ✅ Excel·lent | ✅ Molt estable | ✅ SÍ |
| VSCode Integrada | ⚠️ Problemes | ❌ Inestable | ❌ NO |
| Ubuntu App | ✅ Bé | ✅ Estable | ✅ SÍ |
| PowerShell + wsl | ✅ Bé | ✅ Estable | ⚠️ OK |

---

## ✅ Checklist

- [ ] Instal·lar Windows Terminal (si no el tens)
- [ ] Obrir Windows Terminal
- [ ] Seleccionar pestanya Ubuntu
- [ ] Verificar que estàs a Ubuntu: `uname -a`
- [ ] Executar diagnòstic Docker
- [ ] Treballar des de Windows Terminal (NO VSCode)

---

## 🎓 Conclusió

**Problema**: VSCode terminal no pot carregar WSL2

**Solució**: Utilitzar Windows Terminal

**Avantatges**:
- ✅ Més estable
- ✅ Millor rendiment
- ✅ Dissenyat per WSL2
- ✅ No es tanca inesperadament

**Workflow**:
1. **VSCode** → Editar codi
2. **Windows Terminal** → Executar comandes
3. **Navegador** → Veure resultats

---

## 🚀 Acció Immediata

1. **Obre Windows Terminal** (no VSCode)
2. **Selecciona Ubuntu**
3. **Executa**:
   ```bash
   cd ~/mobil_scan_linux
   docker compose ps
   ```
4. **Segueix les instruccions** segons el resultat

---

**Oblida la terminal de VSCode per WSL2. Utilitza Windows Terminal!** 🎯
