# 🧠 Guia d'Integració LLM (Ollama + Phi-3)

## 📋 Resum

Integració d'un LLM local (Edge AI) al projecte Mobile Scanner per proporcionar respostes en llenguatge natural sobre productes detectats.

---

## 🎯 Arquitectura

```
┌─────────────┐
│   Frontend  │ ← Usuari veu respostes LLM
└──────┬──────┘
       │
┌──────▼──────┐
│     API     │ ← Pot consultar LLM
└──────┬──────┘
       │
┌──────▼──────┐     ┌─────────────┐
│   Worker    │────→│  Ollama LLM │ ← Phi-3 Model
└──────┬──────┘     └─────────────┘
       │
┌──────▼──────┐
│  PostgreSQL │ ← Taula products
└─────────────┘
```

### Flux de Treball:

1. **Detecció**: YOLOv8 detecta codi de barres
2. **Decodificació**: zxing-cpp llegeix el codi
3. **Consulta DB**: Busca producte a PostgreSQL
4. **Query LLM**: Envia info producte a Ollama
5. **Resposta**: LLM genera text en català
6. **Guardar**: Resultat es guarda amb la detecció

---

## 📦 Components Creats

### 1. **docker-compose.llm.yml** ⭐

Docker Compose actualitzat amb:
- Servei `llm` (Ollama)
- Servei `llm_init` (descarrega model Phi-3)
- Volum persistent `ollama_data`
- Variables d'entorn LLM_URL

### 2. **shared/init_db.sql**

Script SQL que crea:
- Taula `products` amb camps:
  - barcode (EAN-13)
  - name, description, category
  - price, stock, manufacturer
- 3 productes de prova:
  - Coca-Cola (5901234123457)
  - Danone Activia (8410076472106)
  - Oli d'Oliva (8480000123459)
- Índexs i triggers

### 3. **shared/llm_client.py**

Client Python per Ollama amb:
- Classe `LLMClient`
- Funció `consultar_llm(product_info, user_question)`
- Prompts RAG-style
- Fallback si LLM no disponible
- Configuració temperatura, tokens, etc.

### 4. **worker/processor_llm.py**

Worker actualitzat que:
- Detecta codis amb YOLO + zxing-cpp
- Consulta DB per info producte
- Crida LLM per resposta natural
- Guarda resposta LLM en fitxers .txt
- Manté compatibilitat amb worker original

---

## 🚀 Posada en Marxa

### Pas 1: Arreglar Docker Desktop

**IMPORTANT**: Primer assegura't que Docker funciona:

```cmd
ARREGLAR_DOCKER_PRIMER.bat
```

Si Docker està mort (error 500):
1. Tanca Docker Desktop (icona → Quit)
2. Obre Task Manager (Ctrl+Shift+Esc)
3. Mata processos Docker si existeixen
4. Reobre Docker Desktop
5. Espera "Docker Desktop is running"

### Pas 2: Iniciar Serveis amb LLM

```cmd
docker-compose -f docker-compose.llm.yml up -d
```

**Temps estimat**: 
- Primera vegada: 15-20 minuts (descarrega model Phi-3 ~2.3GB)
- Següents vegades: 2-3 minuts (model ja descarregat)

### Pas 3: Verificar Estat

```cmd
docker-compose -f docker-compose.llm.yml ps
```

Hauries de veure:
- ✅ mobil_scan_redis (Up)
- ✅ mobil_scan_db (Up)
- ✅ mobil_scan_llm (Up)
- ✅ mobil_scan_api (Up)
- ✅ mobil_scan_worker (Up)
- ✅ mobil_scan_frontend (Up)
- ⏹️ mobil_scan_llm_init (Exited 0) ← Normal, només descarrega model

### Pas 4: Verificar LLM

```cmd
curl http://localhost:11434/api/tags
```

Hauria de mostrar el model `phi3` instal·lat.

### Pas 5: Verificar Base de Dades

```cmd
docker-compose -f docker-compose.llm.yml exec db psql -U mobilscan -d mobilscan_db -c "SELECT * FROM products;"
```

Hauria de mostrar els 3 productes de prova.

### Pas 6: Accedir a l'Aplicació

Obre: http://localhost:8501

---

## 🧪 Provar la Integració

### Test 1: LLM Directe

```cmd
docker-compose -f docker-compose.llm.yml exec worker python -c "
from llm_client import LLMClient
client = LLMClient()
print('LLM Available:', client.is_available())

product = {
    'name': 'Coca-Cola 330ml',
    'description': 'Beguda refrescant',
    'price': 1.50,
    'stock': 150
}

response = client.consultar_llm(product)
print('Response:', response)
"
```

### Test 2: Consulta Producte

```cmd
docker-compose -f docker-compose.llm.yml exec worker python -c "
from database import SessionLocal
from sqlalchemy import text

db = SessionLocal()
result = db.execute(text('SELECT * FROM products WHERE barcode = :bc'), {'bc': '5901234123457'}).fetchone()
print('Product:', result)
db.close()
"
```

### Test 3: Pipeline Complet

1. Puja un vídeo amb un codi de barres EAN-13
2. El worker detectarà el codi
3. Consultarà la DB
4. Cridarà el LLM
5. Guardarà la resposta a `/app/results/{job_id}/llm_response_*.txt`

---

## 📊 Configuració del Model

### Model Utilitzat: **Phi-3** (Microsoft)

**Per què Phi-3?**
- ✅ Optimitzat per CPU/Edge
- ✅ Només 2.3GB (vs 4-7GB d'altres models)
- ✅ Ràpid en inferència
- ✅ Bon rendiment en català
- ✅ Baix consum de memòria

### Alternatives:

Si vols canviar de model, edita `docker-compose.llm.yml`:

```yaml
llm_init:
  command: >
    sh -c "
    curl -X POST http://llm:11434/api/pull -d '{\"name\":\"llama3\"}';
    "
```

**Models recomanats**:
- `phi3` - 2.3GB, ràpid, CPU-friendly ⭐
- `llama3` - 4.7GB, més potent, necessita més RAM
- `mistral` - 4.1GB, bon balanç
- `gemma` - 2.5GB, similar a Phi-3

### Configuració GPU (Opcional)

Si tens NVIDIA GPU, descomenta al `docker-compose.llm.yml`:

```yaml
llm:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

---

## 🔧 Personalització

### Canviar el Prompt

Edita `shared/llm_client.py`, funció `_build_prompt()`:

```python
prompt = f"""Actua com un expert en productes.

PRODUCTE: {name}
PREU: {price}€
STOCK: {stock}

Proporciona una recomanació professional.
"""
```

### Ajustar Paràmetres LLM

A `shared/llm_client.py`, funció `consultar_llm()`:

```python
"options": {
    "temperature": 0.7,  # 0.0 = determinista, 1.0 = creatiu
    "top_p": 0.9,        # Diversitat de resposta
    "max_tokens": 300    # Longitud màxima
}
```

### Afegir Més Productes

```sql
INSERT INTO products (barcode, name, description, category, price, stock, manufacturer) 
VALUES (
    '1234567890123',
    'Nom Producte',
    'Descripció detallada',
    'Categoria',
    9.99,
    100,
    'Fabricant'
);
```

---

## 📈 Rendiment

### Recursos Necessaris:

| Component | CPU | RAM | Disc |
|-----------|-----|-----|------|
| Ollama + Phi-3 | 2 cores | 4GB | 3GB |
| Worker | 2 cores | 4GB | 1GB |
| PostgreSQL | 1 core | 512MB | 1GB |
| Redis | 1 core | 256MB | 100MB |
| **TOTAL** | **4-6 cores** | **8-10GB** | **5GB** |

### Temps de Resposta:

- **Detecció barcode**: ~100ms
- **Consulta DB**: ~10ms
- **Query LLM**: ~2-5 segons (CPU) / ~500ms (GPU)
- **Total per frame**: ~3-6 segons

### Optimitzacions:

1. **Caché de respostes**: Guarda respostes LLM per barcodes repetits
2. **Batch processing**: Processa múltiples deteccions juntes
3. **GPU**: Redueix temps LLM de 5s a 500ms
4. **Model més petit**: Usa `phi3:mini` (1.5GB) si cal

---

## 🐛 Troubleshooting

### Error: "LLM service not available"

```cmd
# Verificar que Ollama està actiu
docker-compose -f docker-compose.llm.yml ps llm

# Veure logs
docker-compose -f docker-compose.llm.yml logs llm

# Reiniciar servei
docker-compose -f docker-compose.llm.yml restart llm
```

### Error: "Model not found"

```cmd
# Descarregar model manualment
docker-compose -f docker-compose.llm.yml exec llm ollama pull phi3

# Verificar models instal·lats
docker-compose -f docker-compose.llm.yml exec llm ollama list
```

### Error: "Out of memory"

Opcions:
1. Reduir `max_tokens` a 150
2. Usar model més petit (`phi3:mini`)
3. Augmentar RAM de Docker Desktop (Settings → Resources)
4. Tancar altres aplicacions

### Respostes LLM en anglès

Edita el prompt a `llm_client.py`:

```python
prompt += "\nIMPORTANT: Respon SEMPRE en català, mai en anglès.\n"
```

---

## 📚 Referències

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Phi-3 Model Card](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)
- [RAG Best Practices](https://www.pinecone.io/learn/retrieval-augmented-generation/)

---

## ✅ Checklist Final

- [ ] Docker Desktop funcionant
- [ ] `docker-compose.llm.yml` creat
- [ ] `shared/init_db.sql` creat
- [ ] `shared/llm_client.py` creat
- [ ] `worker/processor_llm.py` creat
- [ ] Serveis iniciats amb `docker-compose -f docker-compose.llm.yml up -d`
- [ ] Model Phi-3 descarregat (verificar amb `curl http://localhost:11434/api/tags`)
- [ ] Productes a la DB (verificar amb psql)
- [ ] LLM respon correctament (test amb llm_client.py)
- [ ] Aplicació accessible a http://localhost:8501

---

**Ara tens un sistema complet amb IA Edge integrada!** 🚀🧠
