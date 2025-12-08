# 🤖 Integrar IA a l'Aplicació - Guia Pràctica

## Opció 1: OpenAI API (RECOMANAT - Fàcil i Ràpid)

### Pas 1: Obtenir API Key

1. Ves a https://platform.openai.com/api-keys
2. Crea un compte (si no en tens)
3. Crea una API key
4. Copia-la (ex: `sk-proj-xxxxx`)

### Pas 2: Afegir al Backend

Edita `backend/main.py`:

```python
import openai
import os

# Configurar OpenAI
openai.api_key = os.getenv("OPENAI_API_KEY", "")

@app.post("/api/analyze-barcode")
async def analyze_barcode(barcode_text: str):
    """Analitza un codi de barres amb IA"""
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o-mini",  # Model econòmic
            messages=[
                {
                    "role": "system",
                    "content": "Ets un expert en codis de barres. Analitza el codi i proporciona informació útil sobre el producte."
                },
                {
                    "role": "user",
                    "content": f"Analitza aquest codi de barres: {barcode_text}"
                }
            ],
            max_tokens=200
        )
        
        analysis = response.choices[0].message.content
        return {"barcode": barcode_text, "analysis": analysis}
    
    except Exception as e:
        return {"error": str(e)}
```

### Pas 3: Afegir Dependència

Edita `backend/requirements.txt`:

```txt
openai>=1.0.0
```

### Pas 4: Configurar Variable d'Entorn

```bash
gcloud run services update mobil-scan-backend \
  --set-env-vars "OPENAI_API_KEY=sk-proj-xxxxx" \
  --region europe-west1 \
  --project mobil-scan-app
```

### Pas 5: Actualitzar Frontend

Edita `frontend/app.py` per mostrar l'anàlisi IA:

```python
import requests

# Després de detectar un codi
if barcode_detected:
    st.subheader("🤖 Anàlisi amb IA")
    
    with st.spinner("Analitzant amb IA..."):
        response = requests.post(
            f"{API_URL}/api/analyze-barcode",
            json={"barcode_text": barcode_text}
        )
        
        if response.ok:
            analysis = response.json()["analysis"]
            st.success(analysis)
        else:
            st.error("Error analitzant amb IA")
```

### Pas 6: Rebuild i Redeploy

```bash
ACTUALITZAR_APLICACIO.bat
```

**Cost:** ~0.001€ per anàlisi (molt econòmic!)

---

## Opció 2: Anthropic Claude (Alternativa)

Similar a OpenAI però amb Claude:

```python
import anthropic

client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

message = client.messages.create(
    model="claude-3-haiku-20240307",  # Model econòmic
    max_tokens=200,
    messages=[
        {
            "role": "user",
            "content": f"Analitza aquest codi de barres: {barcode_text}"
        }
    ]
)

analysis = message.content[0].text
```

**Dependència:** `anthropic>=0.18.0`

---

## Opció 3: Ollama Local (Desenvolupament)

**NOMÉS per provar localment, NO per producció:**

### Instal·lar Ollama

1. Descarrega: https://ollama.ai/download
2. Instal·la al Windows
3. Obre terminal i executa:

```bash
ollama pull llama3.2:1b  # Model petit i ràpid
```

### Usar Ollama

```python
import requests

def analyze_with_ollama(barcode_text):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "llama3.2:1b",
            "prompt": f"Analitza aquest codi de barres: {barcode_text}",
            "stream": False
        }
    )
    return response.json()["response"]
```

**⚠️ IMPORTANT:** Això només funciona localment, NO a Cloud Run!

---

## Opció 4: Google Gemini (Gratis!)

**MILLOR OPCIÓ SI VOLS GRATIS:**

### Pas 1: Obtenir API Key

1. Ves a https://makersuite.google.com/app/apikey
2. Crea una API key
3. Copia-la

### Pas 2: Afegir al Backend

```python
import google.generativeai as genai

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel('gemini-pro')

@app.post("/api/analyze-barcode")
async def analyze_barcode(barcode_text: str):
    try:
        response = model.generate_content(
            f"Analitza aquest codi de barres i proporciona informació útil: {barcode_text}"
        )
        return {"barcode": barcode_text, "analysis": response.text}
    except Exception as e:
        return {"error": str(e)}
```

### Pas 3: Dependència

```txt
google-generativeai>=0.3.0
```

### Pas 4: Configurar

```bash
gcloud run services update mobil-scan-backend \
  --set-env-vars "GEMINI_API_KEY=xxxxx" \
  --region europe-west1 \
  --project mobil-scan-app
```

**Cost:** GRATIS (fins a 60 requests/minut)

---

## Comparació d'Opcions

| Opció | Cost | Velocitat | Qualitat | Dificultat |
|-------|------|-----------|----------|------------|
| **OpenAI GPT-4o-mini** | 0.001€/req | Ràpid | Excel·lent | Fàcil |
| **Anthropic Claude** | 0.001€/req | Ràpid | Excel·lent | Fàcil |
| **Google Gemini** | GRATIS | Ràpid | Molt bona | Fàcil |
| **Ollama Local** | GRATIS | Lent | Bona | Difícil |

---

## Recomanació Final

**Per a tu, recomano Google Gemini:**
- ✅ GRATIS
- ✅ Fàcil d'integrar
- ✅ Bona qualitat
- ✅ Funciona a Cloud Run

**Passos:**
1. Obté API key de Gemini
2. Edita `backend/main.py` (codi de dalt)
3. Edita `backend/requirements.txt`
4. Configura variable d'entorn
5. Edita `frontend/app.py`
6. Executa `ACTUALITZAR_APLICACIO.bat`

**Temps:** 30 minuts (15 min codi + 15 min rebuild)

---

## Vols que ho implementi ara?

Digues-me quina opció vols (Gemini, OpenAI, Claude) i t'ho implemento directament!
