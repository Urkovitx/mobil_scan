# 🐧 Utilitzar Docker des de WSL2 (Ubuntu)

## 🎯 Situació Actual

Tens **Docker natiu a WSL2/Ubuntu** funcionant correctament!

```bash
ferra@LAPTOP-TUJ7Q8GO$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

✅ Això vol dir que Docker funciona dins de WSL2.

---

## ❌ El Problema

Els scripts `.bat` (Windows) **NO poden veure** el Docker de WSL2.

```
Windows (CMD/PowerShell)
    ↓
    ❌ NO pot accedir
    ↓
Docker dins WSL2/Ubuntu
```

**Solució**: Utilitza scripts `.sh` dins de la terminal Ubuntu.

---

## ✅ COM FER-HO CORRECTAMENT

### Pas 1: A la Terminal Ubuntu de VSCode

Ja tens Docker iniciat:
```bash
sudo service docker start
```

### Pas 2: Donar Permisos a l'Script

```bash
chmod +x iniciar_amb_llm_wsl.sh
```

### Pas 3: Executar l'Script

```bash
./iniciar_amb_llm_wsl.sh
```

**Això iniciarà**:
1. Redis + PostgreSQL
2. Ollama LLM
3. Descarregarà Phi-3 (primera vegada)
4. API + Worker + Frontend

---

## 📋 Comandes Útils (WSL2)

### Iniciar Docker
```bash
sudo service docker start
```

### Verificar Docker
```bash
docker ps
```

### Iniciar Aplicació amb LLM
```bash
./iniciar_amb_llm_wsl.sh
```

### Veure Estat
```bash
docker-compose -f docker-compose.llm.yml ps
```

### Veure Logs
```bash
docker-compose -f docker-compose.llm.yml logs -f
docker-compose -f docker-compose.llm.yml logs -f worker
docker-compose -f docker-compose.llm.yml logs -f llm
```

### Aturar Tot
```bash
docker-compose -f docker-compose.llm.yml down
```

### Reiniciar un Servei
```bash
docker-compose -f docker-compose.llm.yml restart worker
```

---

## 🌐 Accedir a l'Aplicació

Després d'executar l'script, obre el navegador a:

- **Frontend**: http://localhost:8501
- **API**: http://localhost:8000
- **Ollama**: http://localhost:11434

**Nota**: Funciona des de Windows perquè els ports estan exposats!

---

## 🔄 Diferències WSL2 vs Docker Desktop

| Aspecte | Docker Desktop | Docker WSL2 Natiu |
|---------|----------------|-------------------|
| **Ubicació** | Windows | Ubuntu (WSL2) |
| **Scripts** | `.bat` | `.sh` ✅ |
| **Rendiment** | Més lent | Més ràpid ✅ |
| **Memòria** | 4-6GB | 2-3GB ✅ |
| **Estabilitat** | Problemes | Millor ✅ |
| **Accés ports** | ✅ | ✅ |

**Recomanació**: Utilitza Docker WSL2 natiu (el que tens ara)!

---

## 🚀 GUIA RÀPIDA

### Primera Vegada

```bash
# 1. Assegura't que Docker està actiu
sudo service docker start

# 2. Dona permisos
chmod +x iniciar_amb_llm_wsl.sh

# 3. Executa
./iniciar_amb_llm_wsl.sh

# 4. Espera 15-20 minuts (descarrega Phi-3)

# 5. Obre navegador
# http://localhost:8501
```

### Següents Vegades

```bash
# 1. Docker actiu
sudo service docker start

# 2. Executa
./iniciar_amb_llm_wsl.sh

# 3. Espera 2-3 minuts

# 4. Obre navegador
# http://localhost:8501
```

---

## 🐛 Troubleshooting

### Error: "permission denied"

```bash
chmod +x iniciar_amb_llm_wsl.sh
```

### Error: "docker: command not found"

```bash
sudo service docker start
```

### Error: "Cannot connect to Docker daemon"

```bash
# Reiniciar Docker
sudo service docker stop
sudo service docker start

# Verificar
docker ps
```

### Ports ja en ús

```bash
# Aturar tot
docker-compose -f docker-compose.llm.yml down

# Veure què està utilitzant el port
sudo lsof -i :8501
sudo lsof -i :8000

# Matar procés si cal
sudo kill -9 <PID>
```

---

## 💡 Consells

### 1. Sempre des de WSL2

**NO utilitzis**:
- ❌ CMD de Windows
- ❌ PowerShell de Windows
- ❌ Scripts `.bat`

**Utilitza**:
- ✅ Terminal Ubuntu a VSCode
- ✅ Scripts `.sh`
- ✅ Comandes `docker-compose`

### 2. Iniciar Docker Automàticament

Afegeix al `~/.bashrc`:

```bash
# Auto-start Docker
if ! docker ps &> /dev/null; then
    sudo service docker start
fi
```

Després:
```bash
source ~/.bashrc
```

### 3. Docker sense sudo (Opcional)

```bash
sudo usermod -aG docker $USER
```

Després reinicia la terminal.

---

## 📊 Verificar que Tot Funciona

```bash
# 1. Docker actiu
docker ps

# 2. Serveis funcionant
docker-compose -f docker-compose.llm.yml ps

# 3. LLM disponible
curl http://localhost:11434/api/tags

# 4. Base de dades
docker-compose -f docker-compose.llm.yml exec db psql -U mobilscan -d mobilscan_db -c "SELECT COUNT(*) FROM products;"

# 5. Aplicació accessible
curl http://localhost:8501
```

---

## ✅ Resum

**El que has de fer**:

1. **Obrir terminal Ubuntu** a VSCode (ja ho tens)
2. **Iniciar Docker**: `sudo service docker start` (ja ho tens)
3. **Donar permisos**: `chmod +x iniciar_amb_llm_wsl.sh`
4. **Executar**: `./iniciar_amb_llm_wsl.sh`
5. **Esperar** 15-20 minuts (primera vegada)
6. **Accedir**: http://localhost:8501

**NO utilitzis scripts `.bat` de Windows!**

**Utilitza sempre la terminal Ubuntu de WSL2!** ✅

---

## 🎓 Per Què Això És Millor?

- ✅ Docker natiu a Linux (més ràpid)
- ✅ Menys memòria
- ✅ Més estable
- ✅ No depèn de Docker Desktop
- ✅ Millor rendiment

**Tens la millor configuració possible!** 🚀
