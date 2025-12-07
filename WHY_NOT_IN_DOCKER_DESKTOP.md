# ❓ Per què no veig mobil_scan a Docker Desktop?

## 🔍 Resposta Ràpida

**`mobil_scan` NO apareix a Docker Desktop perquè els contenidors encara NO s'han creat.**

Quan vas executar `docker-compose up -d --build`, el build va començar però:
1. ⏳ Encara està construint les imatges, O
2. ❌ El build ha fallat silenciosament, O
3. ⏸️ El build s'ha aturat esperant alguna cosa

---

## 📊 Comparació: robot_app vs mobil_scan

### robot_app (VISIBLE a Docker Desktop)

```
Status: ✅ RUNNING
Contenidors creats: ✅ SÍ
Apareix a Docker Desktop: ✅ SÍ

Contenidors:
- robot_app-frontend-1
- robot_app-api-1
- robot_app-worker-1
- robot_app-db-1
- robot_app-redis-1
```

**Per què es veu?**
- Els contenidors estan **creats i en execució**
- Docker Desktop mostra tots els contenidors actius
- Apareix com un grup amb el nom del projecte

### mobil_scan (NO VISIBLE a Docker Desktop)

```
Status: ❌ NOT RUNNING
Contenidors creats: ❌ NO
Apareix a Docker Desktop: ❌ NO

Contenidors esperats (però no creats):
- mobil_scan-frontend-1
- mobil_scan-api-1
- mobil_scan-worker-1
- mobil_scan-db-1
- mobil_scan-redis-1
```

**Per què NO es veu?**
- Els contenidors **NO s'han creat encara**
- Docker Desktop només mostra contenidors que existeixen
- El build està en procés o ha fallat

---

## 🎯 Com Funciona Docker Desktop

### Què Mostra Docker Desktop?

Docker Desktop mostra:
1. ✅ Contenidors **creats** (running, stopped, exited)
2. ✅ Imatges **construïdes**
3. ✅ Volums **creats**
4. ✅ Xarxes **creades**

Docker Desktop **NO** mostra:
1. ❌ Projectes que encara no han creat contenidors
2. ❌ Builds en procés
3. ❌ Configuracions docker-compose.yml sense executar

### Cicle de Vida d'un Projecte Docker

```
1. Codi escrit (docker-compose.yml, Dockerfiles)
   ↓
   [NO VISIBLE a Docker Desktop]
   
2. docker-compose up -d --build
   ↓
   [BUILDING... encara NO VISIBLE]
   
3. Imatges construïdes
   ↓
   [Imatges VISIBLES a "Images" tab]
   
4. Contenidors creats
   ↓
   [Contenidors VISIBLES a "Containers" tab] ✅
   
5. Contenidors en execució
   ↓
   [Apareix com a grup a Docker Desktop] ✅
```

**mobil_scan està entre el pas 2 i 3** (building)  
**robot_app està al pas 5** (running)

---

## 🔧 Com Verificar l'Estat Real

### Opció 1: Comanda Docker (Recomanat)

```bash
# Veure TOTS els contenidors (inclosos els que no estan en execució)
docker ps -a

# Veure només contenidors de mobil_scan
docker ps -a --filter "name=mobil"

# Veure imatges construïdes
docker images | findstr mobil

# Veure estat del docker-compose
cd mobil_scan
docker-compose ps
```

### Opció 2: Docker Desktop

1. Obre Docker Desktop
2. Ves a **"Containers"** tab
3. Busca "mobil" a la barra de cerca
4. Si NO apareix res → contenidors no creats

### Opció 3: Logs del Build

```bash
cd mobil_scan
docker-compose logs
```

Si no hi ha logs → build no ha començat o ha fallat

---

## 🚀 Com Fer que Aparegui a Docker Desktop

### Pas 1: Atura qualsevol build anterior

```bash
cd mobil_scan
docker-compose down
```

### Pas 2: Neteja imatges parcials (opcional)

```bash
docker system prune -f
```

### Pas 3: Construeix i arrenca

```bash
docker-compose up -d --build
```

### Pas 4: Monitoritza el build

```bash
# En una altra terminal
docker-compose logs -f
```

### Pas 5: Espera 5-10 minuts

El build del worker triga perquè ha de:
- Descarregar Python 3.10 (~900 MB)
- Instal·lar PaddleOCR (~500 MB)
- Instal·lar OpenCV (~300 MB)

### Pas 6: Verifica que ha funcionat

```bash
docker-compose ps
```

**Sortida esperada:**
```
NAME                    STATUS              PORTS
mobil_scan-db-1         Up (healthy)        5432/tcp
mobil_scan-redis-1      Up (healthy)        6379/tcp
mobil_scan-api-1        Up (healthy)        0.0.0.0:8000->8000/tcp
mobil_scan-worker-1     Up                  
mobil_scan-frontend-1   Up                  0.0.0.0:8501->8501/tcp
```

### Pas 7: Refresca Docker Desktop

1. Obre Docker Desktop
2. Ves a "Containers"
3. Hauries de veure **mobil_scan** com a grup
4. Expandeix-lo per veure els 5 contenidors

---

## 🐛 Possibles Problemes

### Problema 1: Build Infinit

**Símptomes:**
- `docker-compose up` no acaba mai
- No apareix res a Docker Desktop
- Terminal bloquejat

**Solució:**
```bash
# Atura el build
Ctrl+C

# Neteja
docker-compose down
docker system prune -f

# Torna a intentar
docker-compose up -d --build
```

### Problema 2: Build Falla Silenciosament

**Símptomes:**
- `docker-compose up` acaba ràpid
- No hi ha contenidors
- No hi ha errors visibles

**Solució:**
```bash
# Veure logs d'error
docker-compose logs

# Build amb més detall
docker-compose build --no-cache --progress=plain
```

### Problema 3: Port Ja en Ús

**Símptomes:**
- Error: "port is already allocated"
- Contenidors no s'inicien

**Solució:**
```bash
# Veure què usa el port 8501
netstat -ano | findstr :8501

# Opció 1: Atura robot_app temporalment
cd ../robot_app
docker-compose stop

# Opció 2: Canvia els ports a mobil_scan/docker-compose.yml
# 8501 → 8502 (frontend)
# 8000 → 8001 (api)
```

### Problema 4: Falta d'Espai en Disc

**Símptomes:**
- Error: "no space left on device"
- Build falla

**Solució:**
```bash
# Neteja imatges antigues
docker system prune -a

# Veure espai utilitzat
docker system df
```

---

## 📋 Checklist de Verificació

Abans de preguntar "per què no apareix?", verifica:

- [ ] He executat `docker-compose up -d --build`?
- [ ] He esperat almenys 10 minuts?
- [ ] He verificat amb `docker ps -a`?
- [ ] He mirat els logs amb `docker-compose logs`?
- [ ] He refrescat Docker Desktop?
- [ ] Els ports 8501 i 8000 estan lliures?
- [ ] Tinc prou espai en disc (>5 GB)?
- [ ] Docker Desktop està en execució?

---

## 🎓 Conceptes Clau

### Docker Desktop només mostra contenidors CREATS

```
Fitxers de configuració → NO VISIBLE
Imatges en construcció → NO VISIBLE
Imatges construïdes → VISIBLE (Images tab)
Contenidors creats → VISIBLE (Containers tab) ✅
```

### Diferència entre Projecte i Contenidors

**Projecte** = Carpeta amb docker-compose.yml
- mobil_scan/ (projecte)
- robot_app/ (projecte)

**Contenidors** = Instàncies en execució
- mobil_scan-frontend-1 (contenidor)
- mobil_scan-api-1 (contenidor)
- etc.

**Docker Desktop mostra CONTENIDORS, no projectes**

---

## 🔄 Comparació Visual

### robot_app (Visible)

```
Docker Desktop
├── Containers
│   └── robot_app ✅ (grup visible)
│       ├── robot_app-frontend-1 (Up)
│       ├── robot_app-api-1 (Up)
│       ├── robot_app-worker-1 (Up)
│       ├── robot_app-db-1 (Up)
│       └── robot_app-redis-1 (Up)
```

### mobil_scan (No Visible)

```
Docker Desktop
├── Containers
│   └── (buit) ❌ (no hi ha contenidors)
```

**Per què?** Perquè els contenidors de mobil_scan encara no s'han creat.

---

## ✅ Solució Final

### Pas a Pas per Fer-lo Visible

1. **Obre una terminal**
   ```bash
   cd C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan
   ```

2. **Neteja qualsevol intent anterior**
   ```bash
   docker-compose down
   ```

3. **Construeix i arrenca**
   ```bash
   docker-compose up -d --build
   ```

4. **Espera 10 minuts** ⏳
   - Ves a fer un cafè ☕
   - El build triga perquè ha de descarregar moltes coses

5. **Verifica que ha funcionat**
   ```bash
   docker-compose ps
   ```
   
   Hauries de veure 5 contenidors "Up"

6. **Refresca Docker Desktop**
   - Obre Docker Desktop
   - Ves a "Containers"
   - Hauries de veure **mobil_scan** ✅

7. **Accedeix a l'aplicació**
   - Frontend: http://localhost:8501
   - API: http://localhost:8000/docs

---

## 📞 Si Encara No Apareix

Si després de seguir tots els passos encara no apareix:

1. **Comparteix els logs**
   ```bash
   docker-compose logs > logs.txt
   ```

2. **Verifica errors**
   ```bash
   docker-compose ps
   docker ps -a
   ```

3. **Comprova ports**
   ```bash
   netstat -ano | findstr :8501
   netstat -ano | findstr :8000
   ```

4. **Revisa espai en disc**
   ```bash
   docker system df
   ```

---

## 🎯 Resum

**Per què no veus mobil_scan a Docker Desktop?**

➡️ Perquè els contenidors **encara no s'han creat**.

**Com fer que aparegui?**

➡️ Executa `docker-compose up -d --build` i espera 10 minuts.

**Quan apareixerà?**

➡️ Quan els 5 contenidors estiguin creats i en execució.

**Com saber si ha funcionat?**

➡️ Executa `docker-compose ps` i hauries de veure 5 contenidors "Up".

---

**Estat Actual:**
- robot_app: ✅ Visible (contenidors creats i en execució)
- mobil_scan: ❌ No visible (contenidors encara no creats)

**Acció Necessària:**
- Executar `docker-compose up -d --build` a mobil_scan
- Esperar 10 minuts
- Verificar amb `docker-compose ps`
- Refrescar Docker Desktop

---

**Última Actualització:** 2024-12-03  
**Estat:** Esperant que es completin els builds
