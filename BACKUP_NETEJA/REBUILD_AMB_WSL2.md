# 🐧 REBUILD AMB WSL2 (Sense Docker Desktop)

## ⚠️ PROBLEMA

Docker Desktop no funciona a Windows, però **WSL2 amb Docker natiu sí**.

## ✅ SOLUCIÓ

Utilitzar WSL2 directament (com has fet abans amb èxit).

---

## 🚀 PAS A PAS

### Pas 1: Obrir Terminal WSL2

**Opció A: Des de VSCode**
```
1. Ctrl+Shift+P
2. Escriu "WSL"
3. Selecciona "WSL: Connect to WSL"
4. Obre terminal integrat
```

**Opció B: Des de Windows Terminal**
```
1. Obre Windows Terminal
2. Selecciona pestanya "Ubuntu" o "WSL"
```

**Opció C: Des de cmd**
```cmd
wsl
```

### Pas 2: Navegar al Projecte

```bash
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan
```

### Pas 3: Verificar Docker (WSL2)

```bash
docker --version
docker-compose --version
```

**Si funciona**: Continua al Pas 4

**Si no funciona**: Executa primer:
```bash
sudo service docker start
```

### Pas 4: Rebuild Worker

```bash
docker-compose build --no-cache worker
```

**Temps**: 5-8 minuts

### Pas 5: Rebuild Frontend

```bash
docker-compose build --no-cache frontend
```

**Temps**: 2-3 minuts

### Pas 6: Reiniciar Serveis

```bash
docker-compose down
docker-compose up -d
```

### Pas 7: Verificar

```bash
docker-compose ps
```

**Hauries de veure**:
```
NAME                    STATUS
mobil_scan_redis        Up
mobil_scan_db           Up
mobil_scan_api          Up
mobil_scan_worker       Up  ← AMB MILLORES!
mobil_scan_frontend     Up  ← AMB PESTANYA IA!
mobil_scan_llm          Up
```

---

## 📝 COMANDES COMPLETES (COPIAR I ENGANXAR)

```bash
# 1. Navegar
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan

# 2. Verificar Docker
docker --version

# 3. Rebuild worker
docker-compose build --no-cache worker

# 4. Rebuild frontend
docker-compose build --no-cache frontend

# 5. Reiniciar
docker-compose down
docker-compose up -d

# 6. Verificar
docker-compose ps

# 7. Veure logs (opcional)
docker-compose logs -f worker
```

---

## 🧪 TESTEJAR MILLORES

### Test 1: Accedir Aplicació

```
1. Obre navegador
2. Ves a: http://localhost:8501
3. Hauries de veure 4 pestanyes:
   - Upload Video
   - Audit Dashboard
   - AI Analysis  ← NOVA!
   - Job History
```

### Test 2: Processar Vídeo

```
1. Pestanya "Upload Video"
2. Puja: VID_20251204_170312.mp4
3. Fes clic "Process Video"
4. Espera processament
5. Ves a "Audit Dashboard"
6. Compara resultats:
   Abans: 1/4 llegibles (25%)
   Després: 3-4/4 llegibles (75-100%)
```

### Test 3: Provar IA

```
1. Pestanya "AI Analysis"
2. Introdueix Job ID
3. Veure resum deteccions
4. Prova preguntes ràpides
5. Fes pregunta personalitzada
6. Veure resposta Phi-3
```

---

## 🐛 TROUBLESHOOTING

### Error: "docker: command not found"

```bash
# Iniciar Docker a WSL2
sudo service docker start

# Verificar
docker ps
```

### Error: "permission denied"

```bash
# Afegir usuari a grup docker
sudo usermod -aG docker $USER

# Reiniciar WSL2
exit
# Torna a obrir WSL2
```

### Error: "Cannot connect to Docker daemon"

```bash
# Reiniciar Docker
sudo service docker restart

# Verificar estat
sudo service docker status
```

### Build massa lent

```bash
# Utilitzar menys paral·lelisme
docker-compose build --parallel 1 worker

# O sense caché només per worker
docker-compose build worker
```

---

## 📊 VERIFICAR MILLORES

### Comprovar Worker Actualitzat

```bash
# Veure logs worker
docker-compose logs worker | grep "preprocess"

# Hauries de veure:
# "✅ Decoded: [CODI] (format: EAN13, confidence: 0.85)"
```

### Comprovar Frontend Actualitzat

```bash
# Veure logs frontend
docker-compose logs frontend | grep "AI"

# O simplement obre http://localhost:8501
# I comprova que hi ha pestanya "AI Analysis"
```

---

## ⏱️ TEMPS ESTIMAT

| Pas | Temps |
|-----|-------|
| Rebuild worker | 5-8 min |
| Rebuild frontend | 2-3 min |
| Reiniciar serveis | 1 min |
| Verificar | 1 min |
| **TOTAL** | **9-13 min** |

---

## ✅ CHECKLIST

```bash
□ Obrir WSL2
□ Navegar al projecte
□ Verificar Docker funciona
□ Rebuild worker (--no-cache)
□ Rebuild frontend (--no-cache)
□ Reiniciar serveis (down + up -d)
□ Verificar estat (ps)
□ Accedir http://localhost:8501
□ Veure 4 pestanyes (incloent IA)
□ Processar vídeo test
□ Comparar resultats
□ Provar pestanya IA
□ ÈXIT! 🎉
```

---

## 🎯 RESUM

**Problema**: Docker Desktop no funciona

**Solució**: Utilitzar WSL2 amb Docker natiu

**Comandes clau**:
```bash
cd /mnt/c/Users/ferra/Projectes/Prova/PROJECTE\ SCAN\ AI/INSTALL_DOCKER_FILES/mobil_scan
docker-compose build --no-cache worker
docker-compose build --no-cache frontend
docker-compose down && docker-compose up -d
docker-compose ps
```

**Resultat esperat**:
- ✅ Worker amb preprocessament avançat
- ✅ Frontend amb pestanya IA
- ✅ 7/7 serveis Up
- ✅ Millora 25% → 75-100% llegibles

---

🐧 **UTILITZA WSL2 - FUNCIONA MILLOR QUE DOCKER DESKTOP!** 🚀
