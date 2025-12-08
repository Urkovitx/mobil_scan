# 🛡️ Solució: Tallafocs McAfee Bloqueja Chocolatey

## Problema

McAfee ha detectat que Chocolatey intenta descarregar software i l'ha bloquejat.

```
❌ Error instal·lant Chocolatey
El sistema no puede ejecutar el programa especificado
```

---

## SOLUCIÓ RÀPIDA: Descarrega Manual de Redis

### **Pas 1: Descarrega Redis**

1. **Obre aquest enllaç al navegador:**
   ```
   https://github.com/microsoftarchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.msi
   ```

2. **Descarrega el fitxer:** `Redis-x64-3.0.504.msi`

3. **Si McAfee el bloqueja:**
   - Clica dret al fitxer descarregat
   - Selecciona "Restaurar" o "Permetre"
   - O desactiva McAfee temporalment (veure més avall)

---

### **Pas 2: Instal·la Redis**

1. **Executa el fitxer descarregat:** `Redis-x64-3.0.504.msi`

2. **Segueix l'assistent d'instal·lació:**
   - Clica "Next"
   - Accepta la llicència
   - Deixa la ruta per defecte: `C:\Program Files\Redis`
   - **IMPORTANT:** Marca "Add Redis to PATH"
   - Clica "Install"

3. **Espera que s'instal·li**

---

### **Pas 3: Inicia Redis**

**Obre un terminal (cmd) i executa:**

```bash
redis-server
```

**Hauries de veure:**

```
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 3.0.504 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: xxxx
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

[xxxx] 08 Dec 11:30:00.000 # Server started, Redis version 3.0.504
[xxxx] 08 Dec 11:30:00.000 * The server is now ready to accept connections on port 6379
```

✅ **Redis està funcionant!**

---

### **Pas 4: Verifica Redis (altra terminal)**

**Obre una altra terminal i executa:**

```bash
redis-cli ping
```

**Resposta esperada:** `PONG`

✅ **Redis funciona correctament!**

---

### **Pas 5: Executa el Worker**

**Ara pots executar el worker:**

```bash
EXECUTAR_WORKER_SENSE_DOCKER.bat
```

---

## Desactivar McAfee Temporalment (Opcional)

### **Si necessites desactivar McAfee per instal·lar:**

1. **Clica dret a la icona de McAfee** a la barra de tasques

2. **Selecciona "Canviar configuració" > "Protecció en temps real"**

3. **Desactiva "Protecció en temps real"** durant 15 minuts

4. **Instal·la Redis**

5. **Reactiva McAfee**

---

## Alternativa: WSL2 amb Redis

### **Si no vols desactivar McAfee:**

**Pots usar WSL2 (Windows Subsystem for Linux):**

```bash
# 1. Obre WSL2 (Ubuntu)
wsl

# 2. Instal·la Redis
sudo apt update
sudo apt install redis-server -y

# 3. Inicia Redis
sudo service redis-server start

# 4. Verifica
redis-cli ping
```

**Resposta esperada:** `PONG`

---

## Script Automàtic (Sense Chocolatey)

Creo un script que descarrega Redis directament sense Chocolatey:

**Executa:**

```bash
DESCARREGAR_REDIS_DIRECTE.bat
```

---

## Troubleshooting

### Error: "redis-server no es reconoce"

**Solució:** Redis no està al PATH

```bash
# Afegeix Redis al PATH manualment:
# 1. Cerca "Variables d'entorn" al menú d'inici
# 2. Edita "Path" a les variables del sistema
# 3. Afegeix: C:\Program Files\Redis
# 4. Reinicia el terminal
```

---

### Error: "Creating Server TCP listening socket *:6379: bind: No error"

**Solució:** Redis ja està executant-se

```bash
# Verifica que funciona
redis-cli ping
```

---

### McAfee continua bloquejant

**Solució:** Afegeix excepció a McAfee

1. Obre McAfee
2. Ves a "Configuració" > "Protecció en temps real"
3. Clica "Fitxers exclosos"
4. Afegeix: `C:\Program Files\Redis`
5. Guarda

---

## Recomanació Final

### **Millor opció per tu:**

1. **Descarrega Redis manualment:**
   ```
   https://github.com/microsoftarchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.msi
   ```

2. **Instal·la Redis** (marca "Add to PATH")

3. **Inicia Redis:**
   ```bash
   redis-server
   ```

4. **Executa el worker:**
   ```bash
   EXECUTAR_WORKER_SENSE_DOCKER.bat
   ```

**Això evita completament el problema amb McAfee! 🚀**

---

## Enllaços Directes

- **Redis Windows:** https://github.com/microsoftarchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.msi
- **Documentació Redis:** https://redis.io/docs/getting-started/

---

## Conclusió

**McAfee és massa protector!**

**Solució:**
1. Descarrega Redis manualment
2. Instal·la
3. Inicia `redis-server`
4. Executa el worker

**Això és més simple i evita problemes amb el tallafocs! 🎉**
