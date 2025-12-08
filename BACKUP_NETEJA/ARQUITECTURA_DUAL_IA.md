# 🤖 Arquitectura Dual: Cloud + Raspberry Pi

## 🎯 Objectiu

Tenir **dues versions** de l'aplicació:

### Versió 1: Cloud Run (Producció)
- ✅ Accessible des de qualsevol lloc
- ✅ Gemini API (gratis)
- ✅ Escalabilitat automàtica
- 🌐 URL pública

### Versió 2: Raspberry Pi (Local)
- ✅ Ollama local (sense costos API)
- ✅ Privacitat total
- ✅ Sense dependències externes
- 🏠 Xarxa local

---

## 📦 Implementació

### PART 1: Cloud Run amb Gemini (Ja està fet!)

Ara implemento Gemini a la versió Cloud Run.

### PART 2: Raspberry Pi amb Ollama

Crearé:
1. `docker-compose.raspberry.yml` - Per executar a la Raspberry
2. Scripts d'instal·lació per Raspberry
3. Configuració Ollama
4. Documentació completa

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────┐
│         USUARI EXTERN (Internet)            │
│                                             │
│  Accedeix a: Cloud Run + Gemini API        │
│  URL: https://mobil-scan-frontend-xxx.app  │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│         USUARI LOCAL (Casa/Empresa)         │
│                                             │
│  Accedeix a: Raspberry Pi + Ollama         │
│  URL: http://192.168.1.X:8501              │
└─────────────────────────────────────────────┘
```

---

## 🚀 Avantatges

### Cloud Run + Gemini:
- ✅ Accés des de qualsevol lloc
- ✅ Sense manteniment
- ✅ Gratis (60 req/min)
- ✅ HTTPS automàtic

### Raspberry Pi + Ollama:
- ✅ Privacitat total
- ✅ Sense costos API
- ✅ Funciona offline
- ✅ Control total

---

## 📝 Pròxims Passos

1. **Ara mateix:** Implemento Gemini a Cloud Run
2. **Després:** Creo configuració per Raspberry Pi
3. **Final:** Tens dues versions funcionant!

Començo ara?
