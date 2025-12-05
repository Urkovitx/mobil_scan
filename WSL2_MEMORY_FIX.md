# 🔧 Augmentar Memòria Docker WSL2

## 📍 Estàs Aquí

Docker Desktop usa **WSL2** (Windows Subsystem for Linux).

Per augmentar la memòria, has de crear un fitxer `.wslconfig`.

---

## ✅ PASSOS SIMPLES

### 1. Obre el Bloc de Notes com Administrador

- Prem tecla Windows
- Escriu "Notepad"
- Fes clic dret → "Run as administrator"

### 2. Copia Aquest Text

```
[wsl2]
memory=8GB
processors=4
swap=2GB
```

### 3. Desa el Fitxer

- File → Save As
- **Ubicació:** `C:\Users\ferra\.wslconfig`
- **Nom del fitxer:** `.wslconfig` (amb el punt al principi!)
- **Tipus:** All Files (*)
- Fes clic a "Save"

### 4. Tanca Tot WSL

Obre PowerShell com Administrador i executa:

```powershell
wsl --shutdown
```

Espera 10 segons.

### 5. Reinicia Docker Desktop

- Tanca Docker Desktop completament
- Obre Docker Desktop altra vegada
- Espera que s'iniciï (1-2 minuts)

### 6. Verifica

Obre PowerShell i executa:

```powershell
wsl -l -v
```

Hauries de veure que WSL està funcionant.

### 7. Torna a Intentar el Build

```powershell
cd C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan
docker-compose up --build
```

---

## 📝 Contingut del Fitxer .wslconfig

```ini
[wsl2]
memory=8GB          # Memòria màxima per WSL2
processors=4        # Nombre de CPUs
swap=2GB           # Memòria swap
localhostForwarding=true
```

---

## 📍 Ubicació Exacta del Fitxer

```
C:\Users\ferra\.wslconfig
```

**Important:** El fitxer comença amb un punt (`.wslconfig`)

---

## 🎯 Alternativa: Usa l'Script Seqüencial

Si no vols tocar WSL, usa:

```powershell
.\build_sequential.bat
```

Això farà build un contenidor cada vegada (més lent però funciona amb menys RAM).

---

## ⚠️ Si el Fitxer Ja Existeix

Si ja tens un `.wslconfig`, obre'l i modifica només aquestes línies:

```ini
memory=8GB
processors=4
swap=2GB
```

---

## 🔍 Com Verificar que Funciona

Després de reiniciar Docker, obre PowerShell:

```powershell
# Verifica WSL
wsl -l -v

# Verifica Docker
docker info
```

Si veus informació sense errors → ✅ Funciona!

---

## 📋 Resum Ràpid

1. Crea `C:\Users\ferra\.wslconfig`
2. Afegeix:
   ```
   [wsl2]
   memory=8GB
   processors=4
   swap=2GB
   ```
3. `wsl --shutdown`
4. Reinicia Docker Desktop
5. `docker-compose up --build`

---

## 💡 Per Què WSL2?

Docker Desktop a Windows usa WSL2 (Linux virtual) per executar contenidors.

WSL2 té els seus propis límits de memòria, separats de Docker Desktop.

Per això has de configurar `.wslconfig` en lloc de Docker Desktop Settings.

---

## 🎯 Temps Estimat

- Crear fitxer: 2 minuts
- Reiniciar: 2 minuts
- Build: 20 minuts
- **Total: 24 minuts**

---

**Propera Acció:** Crea el fitxer `.wslconfig` seguint els passos! 🚀
