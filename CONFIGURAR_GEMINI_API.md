# 🤖 Configurar Gemini AI - Guia Ràpida

## ✅ Pas 1: Obtenir API Key de Gemini (GRATIS)

1. Ves a: https://makersuite.google.com/app/apikey
2. Inicia sessió amb el teu compte de Google
3. Clica "Create API Key"
4. Copia la clau (comença amb `AIza...`)

**Important:** Guarda aquesta clau en un lloc segur!

---

## 🚀 Pas 2: Configurar per Cloud Run

### Opció A: Configurar Variable d'Entorn (RECOMANAT)

```bash
# Configura la clau al servei backend
gcloud run services update mobil-scan-backend \
  --set-env-vars "GEMINI_API_KEY=AIzaXXXXXXXXXXXXXXXXXXXXXXXX" \
  --region europe-west1 \
  --project mobil-scan-app
```

### Opció B: Afegir al docker-compose.yml (per local)

Edita `docker-compose.yml` i afegeix a la secció `api`:

```yaml
api:
  environment:
    - GEMINI_API_KEY=AIzaXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## 🧪 Pas 3: Provar la Integració

### Test Local:

```bash
# Inicia els serveis
docker-compose up -d

# Prova l'endpoint d'IA
curl -X POST http://localhost:8000/ai/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "YOUR_JOB_ID",
    "question": "Quins codis de barres has detectat?"
  }'
```

### Test a Cloud Run:

1. Puja un vídeo amb codis de barres
2. Ves a la pestanya "🤖 AI Analysis"
3. Introdueix el Job ID
4. Fes una pregunta sobre les deteccions
5. Hauries de veure una resposta de Gemini!

---

## 💡 Exemples de Preguntes

- "Quins codis de barres has detectat?"
- "Valida aquests codis per inventari"
- "Quina és la qualitat de les deteccions?"
- "Genera un informe de les deteccions"
- "On hauria de col·locar aquests productes?"
- "Quins SKUs corresponen a aquests codis?"

---

## 🔧 Troubleshooting

### Error: "AI service not available"

**Solució:**
```bash
# Verifica que la variable està configurada
gcloud run services describe mobil-scan-backend \
  --region europe-west1 \
  --format="value(spec.template.spec.containers[0].env)"
```

### Error: "Invalid API key"

**Solució:**
1. Verifica que la clau és correcta
2. Assegura't que l'API de Gemini està activada:
   - Ves a: https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com
   - Clica "Enable"

### Error: "Quota exceeded"

**Solució:**
- Gemini té un límit de 60 requests/minut (gratis)
- Espera 1 minut i torna a provar
- O considera actualitzar a un pla de pagament

---

## 📊 Límits i Costos

### Nivell Gratuït:
- ✅ 60 requests per minut
- ✅ 1,500 requests per dia
- ✅ GRATIS per sempre

### Si necessites més:
- Pla de pagament: ~$0.001 per request
- Molt econòmic per ús professional

---

## 🎯 Pròxims Passos

1. ✅ Configura GEMINI_API_KEY
2. ✅ Desplega a Cloud Run
3. ✅ Prova l'anàlisi amb IA
4. 🔜 (Futur) Integra reconeixement de veu
5. 🔜 (Futur) Afegeix Ollama per Raspberry Pi

---

## 📚 Documentació Addicional

- [Gemini API Docs](https://ai.google.dev/docs)
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [INTEGRAR_IA_ARA.md](./INTEGRAR_IA_ARA.md) - Guia completa

---

**Ara tens IA integrada al teu projecte! 🎉**
