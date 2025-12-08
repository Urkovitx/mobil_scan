# 🔧 Instal·lar docker-compose Manualment

## El Problema

L'script detecta docker-compose però no funciona. Cal instal·lar-lo manualment.

---

## ✅ SOLUCIÓ (Copia i enganxa a la terminal Ubuntu)

### Opció A: Amb apt (RECOMANAT)

```bash
sudo apt update
sudo apt install docker-compose -y
docker-compose --version
```

### Opció B: Descàrrega directa (si Opció A falla)

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

---

## 🚀 Després d'Instal·lar

```bash
./iniciar_amb_llm_wsl.sh
```

---

## 🎯 COMANDES COMPLETES (Tot en una)

```bash
# Instal·lar docker-compose
sudo apt update && sudo apt install docker-compose -y

# Verificar
docker-compose --version

# Iniciar aplicació
./iniciar_amb_llm_wsl.sh
```

---

## ✅ Verificar que Funciona

Després d'instal·lar, hauries de veure:

```bash
$ docker-compose --version
Docker Compose version v2.x.x
```

**NO hauria de dir**: "The command 'docker-compose' could not be found"

---

## 💡 Si Encara No Funciona

Prova amb Docker Compose V2 (nou format):

```bash
# Instal·lar plugin
sudo apt update
sudo apt install docker-compose-plugin -y

# Utilitzar amb "docker compose" (sense guió)
docker compose version
```

Després canvia els scripts per utilitzar `docker compose` en lloc de `docker-compose`.

---

## 🎓 Diferència

- `docker-compose` → Versió antiga (standalone)
- `docker compose` → Versió nova (plugin)

Ambdues funcionen, però la nova és millor.
