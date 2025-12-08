# 🚨 TANCA TOT I REINICIA - Guia Definitiva

## 😄 Sí, Tanca-ho Tot amb la Creu!

Docker està completament bloquejat. Aquí tens com arreglar-ho:

---

## 🎯 PAS A PAS (Segueix en Ordre!)

### Pas 1: Tanca TOTES les Finestres

1. ✅ **Tanca amb la creu (X):**
   - Terminal amb `docker-compose up` → ❌ Creu
   - Terminal amb `docker-compose logs` → ❌ Creu
   - Terminal amb `EMERGENCY_CHECK.bat` → ❌ Creu
   - VSCode → ❌ Creu (si cal)

2. ✅ **No et preocupis si no responen:**
   - És normal que estiguin bloquejades
   - Només fes clic a la creu i espera
   - Si no es tanquen, passa al següent pas

### Pas 2: Obre el Gestor de Tasques

1. Prem `Ctrl + Shift + Esc`
2. O fes clic dret a la barra de tasques → "Task Manager"

### Pas 3: Mata TOTS els Processos Docker

A la pestanya "Processes", busca i mata (End Task):

1. ✅ **Docker Desktop**
2. ✅ **com.docker.backend**
3. ✅ **com.docker.service**
4. ✅ **dockerd**
5. ✅ **docker-compose**
6. ✅ Qualsevol cosa que digui "docker"

**Com matar un procés:**
- Fes clic dret sobre el procés
- Selecciona **"End Task"**
- Espera 5 segons

### Pas 4: Mata Terminals Bloquejades (si cal)

Si les terminals no es tanquen:

1. A Task Manager, busca:
   - **cmd.exe**
   - **powershell.exe**
   - **WindowsTerminal.exe**
2. Fes clic dret → **"End Task"**

### Pas 5: Espera 10 Segons

Deixa que Windows netegi tot.

### Pas 6: Reinicia Docker Desktop

1. Obre el menú d'inici
2. Cerca **"Docker Desktop"**
3. Fes clic per obrir-lo
4. **Espera 30-60 segons** que s'iniciï completament
5. Veuràs "Docker Desktop is running" a la icona

### Pas 7: Verifica que Funciona

Obre una **NOVA** PowerShell i executa:

```powershell
docker info
```

**Si veus informació → ✅ Docker funciona!**  
**Si es queda penjat → Passa al Pas 8**

### Pas 8: Si Encara No Funciona → Reinicia el PC

1. Guarda tot el teu treball
2. Reinicia el PC
3. Obre Docker Desktop
4. Espera que s'iniciï completament
5. Verifica amb `docker info`

---

## 🚀 Després de Reiniciar Docker

### Pas 1: Atura robot_app (Important!)

```powershell
cd C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\robot_app
docker-compose stop
```

Això evita conflictes de ports.

### Pas 2: Neteja mobil_scan

```powershell
cd C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan
docker-compose down
docker system prune -f
```

### Pas 3: Build SENSE -d (per veure progrés)

```powershell
docker-compose up --build
```

**Ara VEURÀS tot el progrés en temps real!**

### Pas 4: Espera 12-15 Minuts

Veuràs missatges com:
```
Step 1/10 : FROM python:3.10
Step 2/10 : WORKDIR /app
...
Creating mobil_scan_db_1 ... done
Creating mobil_scan_redis_1 ... done
Creating mobil_scan_api_1 ... done
Creating mobil_scan_worker_1 ... done
Creating mobil_scan_frontend_1 ... done
```

### Pas 5: Quan Acabi

Veuràs:
```
mobil_scan_frontend_1  | You can now view your Streamlit app in your browser.
mobil_scan_frontend_1  | URL: http://0.0.0.0:8501
```

**✅ ACABAT!**

### Pas 6: Deixa-ho en Segon Pla (Opcional)

Si vols deixar-ho funcionant en segon pla:

1. Prem `Ctrl + C` per aturar
2. Executa: `docker-compose up -d`

---

## 📋 Resum Ràpid

1. ❌ Tanca tot amb la creu
2. 🔧 Obre Task Manager (`Ctrl + Shift + Esc`)
3. ❌ Mata tots els processos Docker (End Task)
4. ⏳ Espera 10 segons
5. ✅ Obre Docker Desktop
6. ⏳ Espera 30-60 segons
7. ✅ Verifica: `docker info`
8. 🚀 Torna a començar: `docker-compose up --build`

---

## 💡 Per Què Ha Passat?

Docker Desktop s'ha bloquejat perquè:

1. **Massa comandos simultanis** - docker-compose up + logs + scripts
2. **Conflicte amb robot_app** - Ambdós usen els mateixos ports (8501, 8000)
3. **Flag `-d` va amagar els errors** - No vam veure què anava malament

---

## ✅ Prevenció per la Propera Vegada

### SEMPRE Fes Això Primer:

1. **Atura robot_app:**
   ```powershell
   cd robot_app
   docker-compose stop
   ```

2. **Usa `docker-compose up --build`** (sense `-d`) la primera vegada

3. **NO executis múltiples comandos Docker simultàniament**

4. **Verifica que Docker funciona:**
   ```powershell
   docker info
   ```

---

## 🎯 Estat Actual

**Problema:** Docker Desktop completament bloquejat  
**Solució:** Mata processos + Reinicia Docker Desktop  
**Temps:** 2-3 minuts per reiniciar + 12-15 minuts per build  
**Total:** ~15-18 minuts  

---

## 🎉 Conclusió

**Passos Clars:**

1. ❌ Tanca tot amb la creu
2. 🔧 Task Manager → Mata processos Docker
3. ✅ Reinicia Docker Desktop
4. 🚀 `docker-compose up --build` (sense `-d`)
5. ⏳ Espera 12-15 minuts
6. ✅ Funciona!

**Ara sí que ho tenim tot clar!** 🎯✨

---

**P.S.** Si després de reiniciar el PC encara no funciona, pot ser que Docker Desktop tingui un problema més greu. En aquest cas, considera reinstal·lar Docker Desktop.
