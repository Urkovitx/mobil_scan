# 🧹 NETEJA TOTAL DE DOCKER

## 🎯 Instruccions per Derribar i Netejar Tot

### Opció 1: Neteja Completa (RECOMANAT)

```powershell
# 1. Atura i elimina TOTS els contenidors del projecte actual
docker-compose down --volumes --remove-orphans

# 2. Elimina TOTS els contenidors (de tots els projectes)
docker container prune -f

# 3. Elimina TOTES les imatges
docker image prune -a -f

# 4. Elimina TOTS els volums
docker volume prune -f

# 5. Elimina TOTES les xarxes no utilitzades
docker network prune -f

# 6. Neteja TOTAL del sistema (cache de build, etc.)
docker system prune -a --volumes -f
```

**Temps:** 2-3 minuts  
**Resultat:** Docker completament net, com si acabés d'instal·lar-se

---

### Opció 2: Neteja Només d'Aquest Projecte

```powershell
# Atura i elimina només els contenidors de mobil_scan
docker-compose down --volumes --remove-orphans

# Elimina les imatges de mobil_scan
docker rmi mobil_scan-api mobil_scan-frontend mobil_scan-worker -f
```

**Temps:** 30 segons  
**Resultat:** Només mobil_scan eliminat, altres projectes intactes

---

### Opció 3: Script Automàtic (Ja el tens!)

```powershell
.\CLEAN_ALL_DOCKER.bat
```

Aquest script fa:
1. `docker-compose down --volumes --remove-orphans`
2. `docker system prune -a --volumes -f`

---

## 🔥 Neteja NUCLEAR (Si res funciona)

```powershell
# 1. Atura Docker Desktop
# (Tanca l'aplicació)

# 2. Neteja WSL
wsl --shutdown

# 3. Elimina TOTES les dades de Docker
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Docker"

# 4. Reinicia Docker Desktop
# (Obre l'aplicació)
```

⚠️ **ATENCIÓ:** Això elimina TOT de Docker (tots els projectes, imatges, volums, etc.)

---

## 📋 Comandes Útils per Verificar

### Veure què hi ha ara:

```powershell
# Contenidors en execució
docker ps

# TOTS els contenidors (inclosos aturats)
docker ps -a

# Imatges
docker images

# Volums
docker volume ls

# Xarxes
docker network ls

# Espai utilitzat
docker system df
```

---

## 🎯 Workflow Recomanat

### Quan vols començar de zero:

```powershell
# 1. Neteja total
docker-compose down --volumes --remove-orphans
docker system prune -a --volumes -f

# 2. Verifica que està net
docker ps -a
docker images

# 3. Reinicia WSL (opcional però recomanat)
wsl --shutdown

# 4. Reinicia Docker Desktop

# 5. Build de nou
.\build_sequential.bat
```

---

## 🔍 Explicació de les Comandes

### `docker-compose down`
- Atura i elimina contenidors del projecte actual
- `--volumes`: Elimina també els volums
- `--remove-orphans`: Elimina contenidors orfes

### `docker container prune -f`
- Elimina TOTS els contenidors aturats
- `-f`: Force (sense confirmació)

### `docker image prune -a -f`
- Elimina TOTES les imatges no utilitzades
- `-a`: All (totes, no només les "dangling")
- `-f`: Force

### `docker volume prune -f`
- Elimina TOTS els volums no utilitzats

### `docker network prune -f`
- Elimina TOTES les xarxes no utilitzades

### `docker system prune -a --volumes -f`
- Neteja TOTAL del sistema
- Elimina: contenidors, imatges, volums, xarxes, cache
- És la comanda més potent!

---

## 💡 Quan Usar Cada Opció?

### Opció 1 (Neteja Completa):
- ✅ Quan vols començar completament de zero
- ✅ Quan tens problemes de memòria
- ✅ Quan tens molts projectes vells
- ✅ Abans d'un build important

### Opció 2 (Només Aquest Projecte):
- ✅ Quan només vols reconstruir mobil_scan
- ✅ Quan tens altres projectes que vols mantenir
- ✅ Per fer proves ràpides

### Opció 3 (Script):
- ✅ Quan vols automatitzar la neteja
- ✅ Quan no vols recordar comandes

### Opció 4 (Nuclear):
- ⚠️ Només quan res més funciona
- ⚠️ Quan Docker està completament corromput
- ⚠️ Com a últim recurs

---

## 🚀 Exemple Pràctic

### Escenari: Vols reconstruir mobil_scan des de zero

```powershell
# Pas 1: Neteja
cd "C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan"
docker-compose down --volumes --remove-orphans
docker system prune -a --volumes -f

# Pas 2: Verifica
docker ps -a
# (hauria de mostrar: no containers)

docker images
# (hauria de mostrar: no images o molt poques)

# Pas 3: Reinicia (opcional)
wsl --shutdown
# Reinicia Docker Desktop

# Pas 4: Build
.\build_sequential.bat
```

---

## 📊 Espai Alliberat

Després d'una neteja completa, pots alliberar:
- **Contenidors:** 100-500 MB
- **Imatges:** 2-10 GB
- **Volums:** 100 MB - 2 GB
- **Cache de build:** 1-5 GB

**Total:** Fins a 15-20 GB! 🎉

---

## ⚠️ Advertències

1. **Neteja completa elimina TOTS els projectes Docker**
   - Si tens altres projectes, usa Opció 2

2. **Els volums contenen dades**
   - Si tens dades importants, fes backup abans

3. **Les imatges es tornaran a descarregar**
   - La primera build després de netejar serà més lenta

4. **Docker Desktop ha d'estar en execució**
   - Obre Docker Desktop abans de fer neteja

---

## 🎯 Comanda Ràpida (Copia i Enganxa)

Per fer neteja total i començar de zero:

```powershell
docker-compose down --volumes --remove-orphans && docker system prune -a --volumes -f && wsl --shutdown
```

Després reinicia Docker Desktop i executa:

```powershell
.\build_sequential.bat
```

---

## 📝 Checklist de Neteja

- [ ] `docker-compose down --volumes --remove-orphans`
- [ ] `docker system prune -a --volumes -f`
- [ ] `wsl --shutdown`
- [ ] Reiniciar Docker Desktop
- [ ] Verificar amb `docker ps -a` (hauria d'estar buit)
- [ ] Verificar amb `docker images` (hauria d'estar buit o mínim)
- [ ] Build de nou amb `.\build_sequential.bat`

---

## 🎉 Resum

**Neteja Total (Recomanat):**
```powershell
docker-compose down --volumes --remove-orphans
docker system prune -a --volumes -f
wsl --shutdown
# Reinicia Docker Desktop
.\build_sequential.bat
```

**Temps Total:** 5 minuts neteja + 30 minuts build = 35 minuts

**Resultat:** Docker completament net i mobil_scan reconstruït des de zero! ✅
