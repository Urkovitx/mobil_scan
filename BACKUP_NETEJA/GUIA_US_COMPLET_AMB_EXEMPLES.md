# 🎯 GUIA D'ÚS COMPLET - Industrial Video Audit Tool

## 📱 APLICACIÓ JA OBERTA!

Veig que ja tens l'aplicació funcionant a http://localhost:8501

**Interfície actual**:
- ✅ System Status: API Connected
- ✅ Total Jobs: 0
- ✅ Upload Video tab activa
- ✅ Settings configurats

---

## 🚀 EXEMPLE PRÀCTIC 1: Detectar Codis en un Vídeo

### Pas 1: Preparar un Vídeo de Test

**Opció A: Gravar amb el mòbil** (RECOMANAT)
```
1. Obre la càmera del mòbil
2. Grava 10-15 segons d'un producte amb codi de barres
   - Pot ser qualsevol producte: llet, cereals, llibre, etc.
3. Envia't el vídeo per WhatsApp/Email
4. Descarrega'l al PC
```

**Opció B: Utilitzar vídeo d'exemple**
```
1. Busca a YouTube: "barcode scanning video"
2. Descarrega amb: https://www.y2mate.com/
3. Guarda'l al PC
```

**Opció C: Crear vídeo de test ràpid**
```
1. Obre Google Images: "barcode EAN-13"
2. Captura pantalla d'un codi
3. Obre PowerPoint/Paint
4. Enganxa la imatge
5. Grava pantalla 10 segons (Windows + G)
```

### Pas 2: Pujar el Vídeo

**A l'aplicació**:
```
1. Fes clic a "Browse files" o arrossega el vídeo
2. Selecciona el teu vídeo (MP4, MOV, AVI, MKV)
3. Espera que es carregui (veuràs una barra de progrés)
4. Fes clic a "Process Video" (botó verd)
```

### Pas 3: Esperar Processament

**Què passa ara**:
```
✅ El vídeo es puja al servidor
✅ El worker extreu frames (1 cada 30 frames)
✅ YOLOv8 detecta codis de barres
✅ zxing-cpp v2.2.1 decodifica els codis
✅ Els resultats es guarden a PostgreSQL
```

**Temps estimat**:
- Vídeo 10 segons: ~30 segons
- Vídeo 1 minut: ~2 minuts
- Vídeo 5 minuts: ~8 minuts

### Pas 4: Veure Resultats

**Canvia a "Audit Dashboard"**:
```
1. Fes clic a la pestanya "Audit Dashboard"
2. Veuràs:
   - Total de codis detectats
   - Tipus de codis (EAN-13, QR, Code128, etc.)
   - Frames on apareixen
   - Contingut decodificat
```

**Exemple de resultat**:
```
╔════════════════════════════════════════╗
║  Barcode Detection Results            ║
╠════════════════════════════════════════╣
║  📋 Format:     EAN-13                ║
║  📝 Text:       5901234123457         ║
║  📍 Frame:      45 (1.5s)             ║
║  🎯 Confidence: 0.95                  ║
║  📦 Position:   (120,200) → (380,280) ║
╚════════════════════════════════════════╝
```

### Pas 5: Exportar Dades

**Descarregar resultats**:
```
1. Fes clic a "Export data as CSV"
2. S'obrirà un fitxer CSV amb:
   - Timestamp
   - Barcode type
   - Barcode content
   - Frame number
   - Confidence score
   - Position coordinates
```

**Exemple CSV**:
```csv
timestamp,type,content,frame,confidence,x,y,width,height
2024-01-07 18:30:15,EAN-13,5901234123457,45,0.95,120,200,260,80
2024-01-07 18:30:16,QR,https://example.com,78,0.98,300,150,200,200
```

---

## 🤖 EXEMPLE PRÀCTIC 2: Utilitzar Phi-3 (IA Local)

### Cas d'Ús: Analitzar Codis Detectats

**Escenari**: Has detectat 5 codis de barres diferents en un vídeo d'un magatzem.

**Pregunta a Phi-3**:
```
"Analitza aquests codis de barres detectats:
- EAN-13: 5901234123457
- EAN-13: 8712345678901
- QR: https://warehouse.com/item/A123
- Code128: PALLET-2024-001
- DataMatrix: LOT:20240107-B

Què pots dir sobre aquest inventari?"
```

**Resposta de Phi-3** (exemple):
```
Basant-me en els codis detectats:

1. EAN-13 (5901234123457, 8712345678901):
   - Productes de consum amb codi de barres estàndard
   - Probablement articles individuals per venda

2. QR (https://warehouse.com/item/A123):
   - Sistema de tracking intern
   - Enllaç a informació detallada del producte

3. Code128 (PALLET-2024-001):
   - Identificador de palet
   - Format: PALLET-[ANY]-[NÚMERO]
   - Suggereix sistema de gestió de palets

4. DataMatrix (LOT:20240107-B):
   - Número de lot de producció
   - Data: 07/01/2024
   - Batch: B

Conclusió: Magatzem amb sistema mixt de tracking
que combina productes individuals i palets.
```

### Com Fer-ho:

**Opció A: Des de l'aplicació** (si està integrat):
```
1. Ves a la secció "AI Analysis"
2. Escriu la teva pregunta
3. Fes clic a "Ask Phi-3"
4. Espera la resposta (5-10 segons)
```

**Opció B: Des de terminal**:
```bash
# Pregunta directa
docker exec mobil_scan_llm ollama run phi3 "Analitza aquest codi: EAN-13 5901234123457"

# Conversa interactiva
docker exec -it mobil_scan_llm ollama run phi3
>>> Hola! Pots ajudar-me amb codis de barres?
>>> [Phi-3 respon]
>>> Què significa EAN-13?
>>> [Phi-3 respon]
>>> /bye
```

---

## 📊 EXEMPLE PRÀCTIC 3: Auditoria d'Inventari

### Escenari Real: Magatzem Industrial

**Objectiu**: Verificar que tots els productes tenen codi de barres visible.

### Pas 1: Gravar Vídeo del Magatzem

```
1. Camina pel magatzem amb el mòbil
2. Grava les prestatgeries (10-15 segons cada)
3. Assegura't que els codis són visibles
4. Grava 5-10 vídeos diferents
```

### Pas 2: Processar Tots els Vídeos

```
1. Puja el primer vídeo → Process
2. Mentre processa, prepara el segon
3. Puja el segon → Process
4. Repeteix per tots els vídeos
```

### Pas 3: Analitzar Resultats

**A "Job History"**:
```
✅ Video 1: 15 codis detectats
✅ Video 2: 12 codis detectats
✅ Video 3: 8 codis detectats
⚠️ Video 4: 3 codis detectats (PROBLEMA!)
✅ Video 5: 14 codis detectats
```

**Interpretació**:
- Vídeo 4 té menys deteccions
- Possibles causes:
  - Codis tapats
  - Mala il·luminació
  - Codis danyats
  - Productes sense codi

### Pas 4: Generar Informe

**Exporta tots els resultats**:
```
1. Ves a "Job History"
2. Selecciona tots els jobs
3. "Export All as CSV"
4. Obre amb Excel/Google Sheets
```

**Crea gràfics**:
```
- Gràfic de barres: Codis per vídeo
- Gràfic circular: Tipus de codis
- Taula: Productes sense codi
```

---

## 🔧 EXEMPLE PRÀCTIC 4: Configurar Settings

### Ajustar Sensibilitat

**Minimum Confidence** (ara: 0.50):
```
- 0.30-0.50: Més deteccions, més falsos positius
- 0.50-0.70: Equilibrat (RECOMANAT)
- 0.70-0.90: Menys deteccions, més precisió
```

**Quan ajustar**:
- **Baixar** (0.30): Codis petits o danyats
- **Pujar** (0.80): Només codis molt clars

### Ajustar Images per Row

**Images per Row** (ara: 4):
```
- 2-3: Veure codis més grans
- 4-6: Vista general (RECOMANAT)
- 6-8: Molts codis, vista compacta
```

**Exemple**:
```
Si tens 100 codis detectats:
- 4 per fila = 25 files
- 6 per fila = 17 files
- 8 per fila = 13 files
```

---

## 💡 CASOS D'ÚS REALS

### 1. Control de Qualitat

**Problema**: Verificar que tots els productes tenen etiqueta.

**Solució**:
```
1. Grava línia de producció
2. Processa vídeo
3. Compte codis detectats vs productes
4. Identifica productes sense etiqueta
```

### 2. Gestió d'Inventari

**Problema**: Comptar stock ràpidament.

**Solució**:
```
1. Grava prestatgeries
2. Processa vídeos
3. Exporta llista de codis
4. Compara amb base de dades
5. Identifica discrepàncies
```

### 3. Recepció de Mercaderies

**Problema**: Verificar comanda rebuda.

**Solució**:
```
1. Grava palets rebuts
2. Detecta codis
3. Compara amb albarà
4. Identifica errors o faltants
```

### 4. Auditoria de Seguretat

**Problema**: Verificar traçabilitat de lots.

**Solució**:
```
1. Grava productes amb lot
2. Detecta DataMatrix/QR
3. Verifica dates de caducitat
4. Identifica lots caducats
```

---

## 🎓 CONSELLS PROFESSIONALS

### Per Millors Resultats:

**Il·luminació**:
```
✅ Llum natural o LED blanc
❌ Llum groga o ombres
❌ Reflexos directes
```

**Distància**:
```
✅ 30-50 cm del codi
❌ Massa a prop (desenfocament)
❌ Massa lluny (codi petit)
```

**Moviment**:
```
✅ Moviment lent i suau
❌ Moviments bruscos
❌ Càmera tremolosa
```

**Angle**:
```
✅ Perpendicular al codi
❌ Angle massa pronunciat
❌ Codi de costat
```

### Optimitzar Rendiment:

**Vídeos curts**:
```
✅ 10-30 segons per vídeo
❌ Vídeos de 5+ minuts
```

**Resolució**:
```
✅ 720p o 1080p
❌ 4K (massa gran)
❌ 480p (massa petit)
```

**Format**:
```
✅ MP4 (H.264)
✅ MOV
⚠️ AVI (més gran)
❌ Formats exòtics
```

---

## 🐛 TROUBLESHOOTING

### No Detecta Codis

**Possibles causes**:
```
1. Codi massa petit → Apropa't més
2. Codi desenfocament → Moviment més lent
3. Mala il·luminació → Millora llum
4. Codi danyat → Neteja o reemplaça
5. Confidence massa alt → Baixa a 0.30
```

### Massa Falsos Positius

**Solució**:
```
1. Puja Minimum Confidence a 0.70
2. Millora qualitat del vídeo
3. Evita fons amb patrons
```

### Processament Lent

**Solució**:
```
1. Vídeos més curts (10-30 seg)
2. Resolució més baixa (720p)
3. Menys frames per segon
```

---

## 📱 EXEMPLE COMPLET PAS A PAS

### Escenari: Primera Prova

**Ara mateix, fes això**:

1. **Busca un producte amb codi de barres**
   - Qualsevol cosa: llet, cereals, llibre
   - Assegura't que el codi és visible

2. **Grava 10 segons amb el mòbil**
   - Enfoca el codi de barres
   - Moviment lent
   - Bona il·luminació

3. **Envia't el vídeo**
   - WhatsApp a tu mateix
   - O Email
   - Descarrega al PC

4. **A l'aplicació** (ja oberta):
   - Fes clic "Browse files"
   - Selecciona el vídeo
   - "Process Video"

5. **Espera 30 segons**
   - Veuràs el progrés
   - Total Jobs: 1
   - Processing...

6. **Veure resultats**:
   - "Audit Dashboard"
   - Veuràs el codi detectat!
   - Format, contingut, posició

7. **Exportar**:
   - "Export as CSV"
   - Obre amb Excel
   - Veuràs les dades!

---

## 🎯 PRÒXIMS PASSOS

### Avui (Diumenge):
```
✅ Prova amb 1 vídeo simple
✅ Familiaritza't amb la interfície
✅ Experimenta amb Settings
✅ Prova exportar CSV
```

### Aquesta Setmana:
```
□ Prova amb vídeos més llargs
□ Diferents tipus de codis
□ Utilitza Phi-3 per anàlisi
□ Crea el teu primer informe
```

### Aquest Mes:
```
□ Implementa en producció
□ Forma l'equip
□ Crea procediments
□ Optimitza workflow
```

---

## 📚 RECURSOS ADDICIONALS

**Documentació**:
- `GUIA_US_APLICACIO.md` - Guia bàsica
- `worker/cpp_scanner/README.md` - Component C++
- `GUIA_ACTUALITZACIO_ZXING.md` - Detalls tècnics

**Suport**:
- Logs: `docker-compose logs -f worker`
- Estat: `docker-compose ps`
- Reiniciar: `docker-compose restart`

**Comunitat**:
- zxing-cpp: https://github.com/zxing-cpp/zxing-cpp
- YOLOv8: https://docs.ultralytics.com/
- Ollama: https://ollama.ai/

---

## ✅ CHECKLIST PRIMERA PROVA

```
□ Aplicació oberta (http://localhost:8501)
□ System Status: API Connected
□ Vídeo preparat (10-30 segons)
□ Vídeo pujat
□ "Process Video" clicat
□ Esperat processament
□ Resultats visibles a Dashboard
□ CSV exportat
□ Dades obertes amb Excel
□ ÈXIT! 🎉
```

---

## 🎉 CONCLUSIÓ

**Tens una eina professional per**:
- ✅ Detectar codis automàticament
- ✅ Processar vídeos ràpidament
- ✅ Analitzar amb IA local
- ✅ Exportar dades fàcilment
- ✅ Integrar en workflows

**Comença ara mateix**:
1. Grava 10 segons d'un codi
2. Puja'l a l'aplicació
3. Veure la màgia! ✨

**GAUDEIX DE LA TEVA APLICACIÓ!** 🚀
