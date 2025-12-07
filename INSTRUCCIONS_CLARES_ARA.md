# 🎯 QUÈ HAS DE FER ARA - PAS A PAS

## ✅ OPCIÓ RECOMANADA: Utilitzar Imatges Pre-Built

**Temps**: 2-3 minuts (vs 20+ construint)

---

## 📋 PAS A PAS (COPIA I ENGANXA)

### A la Terminal Ubuntu de VSCode:

```bash
# Pas 1: Donar permisos a l'script
chmod +x iniciar_prod.sh

# Pas 2: Executar
./iniciar_prod.sh
```

**Això farà**:
1. Descarregarà imatges de Docker Hub (2-3 min)
2. Iniciarà Redis + PostgreSQL
3. Iniciarà Ollama
4. Iniciarà API, Worker, Frontend
5. Descarregarà Phi-3 en background

---

## ❓ I SI NO FUNCIONA?

### Error: "Imatges no disponibles"

**Significa**: Les imatges al teu Docker Hub són antigues.

**Solució**: Utilitzar el sistema sense LLM (funciona perfectament):

```bash
# A la terminal Ubuntu
chmod +x iniciar_worker_sense_llm.sh
./iniciar_worker_sense_llm.sh

# Després iniciar API i Frontend
docker-compose up -d api frontend
```

---

## 🎯 RESUM SUPER CLAR

### Què escrius a la terminal:

```bash
chmod +x iniciar_prod.sh && ./iniciar_prod.sh
```

### Què passa:

1. ⏬ Descarrega imatges (2-3 min)
2. 🚀 Inicia tot
3. ✅ Aplicació llesta

### On vas després:

```
http://localhost:8501
```

---

## 💡 NO HAS DE FER RES A DOCKER HUB

**Docker Hub**: Només per veure les imatges que ja tens.

**NO cal**:
- ❌ Pujar res
- ❌ Crear res
- ❌ Configurar res

**Només cal**:
- ✅ Executar l'script
- ✅ Esperar 2-3 minuts
- ✅ Accedir a localhost:8501

---

## 🚨 SI ENCARA TENS DUBTES

### Pregunta: "Què escric exactament?"

**Resposta**:
```bash
chmod +x iniciar_prod.sh && ./iniciar_prod.sh
```

### Pregunta: "On ho escric?"

**Resposta**: Terminal Ubuntu de VSCode (la que ja tens oberta)

### Pregunta: "Què fa això?"

**Resposta**: Descarrega i inicia tot en 2-3 minuts

### Pregunta: "I Ollama?"

**Resposta**: S'inicia automàticament, Phi-3 es descarrega en background

---

## ✅ COMANDA FINAL

**Copia això i enganxa a la terminal Ubuntu**:

```bash
chmod +x iniciar_prod.sh && ./iniciar_prod.sh
```

**Espera 2-3 minuts i obre**:
```
http://localhost:8501
```

**I JA ESTÀ!** 🎉
