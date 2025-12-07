# 💀 MATAR TOT DES DE L'ADMINISTRADOR DE TASQUES

## 🎯 SOLUCIÓ BRUTAL (Funciona Sempre!)

### Pas 1: Obre l'Administrador de Tasques

Prem: **Ctrl + Shift + Esc**

---

### Pas 2: Mata Aquests Processos (Un per Un)

Busca i mata (clic dret → "Finalitzar tasca"):

1. **Docker Desktop**
2. **com.docker.backend**
3. **com.docker.service**
4. **dockerd**
5. **docker-compose**
6. **vmmem** (WSL2)
7. **wslhost**
8. **wsl**

**IMPORTANT:** Mata'ls TOTS! No deixis cap!

---

### Pas 3: Reinicia WSL des de PowerShell (Admin)

```powershell
wsl --shutdown
```

---

### Pas 4: Obre Docker Desktop

Simplement obre Docker Desktop i espera 2 minuts.

---

### Pas 5: Build Net

```powershell
cd C:\Users\ferra\Projectes\Prova\PROJECTE` SCAN` AI\INSTALL_DOCKER_FILES\mobil_scan
docker-compose up --build
```

---

## 🎯 Resum Ultra-Ràpid

1. **Ctrl + Shift + Esc** (Administrador de Tasques)
2. **Mata:** Docker Desktop, com.docker.*, vmmem, wsl*
3. **PowerShell Admin:** `wsl --shutdown`
4. **Obre Docker Desktop** (espera 2 min)
5. **Build:** `docker-compose up --build`

---

## ⏱️ Temps: 25 minuts

- Matar processos: 2 min
- Reiniciar: 3 min
- Build: 20 min

---

## 💡 Per Què Això Funciona?

Mata TOTS els processos de Docker i WSL2, forçant un reinici complet.

És la solució més brutal però **SEMPRE funciona**.

---

## 🎯 Estat del Projecte

✅ Codi complet  
✅ `.wslconfig` amb 8 GB RAM  
✅ Dockerfiles amb timeout 1000s  
✅ Dependencies correctes  

**Ara només falta matar-ho tot i començar de zero!** 💀🚀
