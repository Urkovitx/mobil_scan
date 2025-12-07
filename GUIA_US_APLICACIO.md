# 📱 Guia d'Ús: Mobile Industrial Scanner

## 🚀 Accés a l'Aplicació

**URL:** http://localhost:8501

---

## 📋 Interfície Principal

L'aplicació té **3 pestanyes principals**:

### 1. 📤 Upload Video (Pujar Vídeo)

**Funció:** Processar un vídeo per detectar codis de barres

#### Passos:

1. **Puja un vídeo**
   - Clica "Browse files" o arrossega el vídeo
   - Formats acceptats: MP4, AVI, MOV
   - Mida màxima: 200 MB

2. **Configura opcions** (opcional)
   - **Frame Interval**: Cada quants frames analitzar (per defecte: 10)
     - Més baix = més precís però més lent
     - Més alt = més ràpid però pot perdre codis
   
   - **Confidence Threshold**: Confiança mínima per acceptar detecció (per defecte: 0.5)
     - Més baix = detecta més però més false positives
     - Més alt = més precís però pot perdre codis

3. **Clica "Process Video"**
   - El vídeo s'envia al backend
   - Es crea un job de processament
   - Pots veure el progrés en temps real

4. **Resultats**
   - Veuràs una taula amb tots els codis detectats
   - Cada fila mostra:
     - **Frame**: Número de frame on es va detectar
     - **Timestamp**: Moment exacte del vídeo (segons)
     - **Barcode**: Valor del codi detectat
     - **Confidence**: Confiança de la detecció (0-1)
     - **Type**: Tipus de codi (CODE128, QR, etc.)

5. **Descarregar Resultats**
   - Clica "Download Results (CSV)" per obtenir un fitxer CSV
   - Pots obrir-lo amb Excel o Google Sheets

---

### 2. 📊 Audit Dashboard (Panell d'Auditoria)

**Funció:** Veure estadístiques i mètriques del sistema

#### Què veuràs:

1. **Estadístiques Generals**
   - Total de vídeos processats
   - Total de codis detectats
   - Taxa d'èxit
   - Temps mitjà de processament

2. **Gràfics**
   - Vídeos processats per dia
   - Distribució de tipus de codis
   - Temps de processament per vídeo

3. **Taula de Rendiment**
   - Millors i pitjors vídeos
   - Vídeos amb errors
   - Estadístiques detallades

#### Ús:

- **Filtra per dates**: Selecciona un rang de dates
- **Exporta dades**: Descarrega les estadístiques en CSV
- **Analitza tendències**: Veu com millora el sistema amb el temps

---

### 3. 📜 Job History (Historial de Feines)

**Funció:** Veure tots els vídeos processats i el seu estat

#### Què veuràs:

**Taula amb tots els jobs:**
- **Job ID**: Identificador únic
- **Video Name**: Nom del vídeo
- **Status**: Estat actual
  - 🟢 **COMPLETED**: Processat correctament
  - 🟡 **PROCESSING**: En procés
  - 🔴 **FAILED**: Error
  - ⚪ **PENDING**: Esperant
- **Created At**: Data i hora de creació
- **Completed At**: Data i hora de finalització
- **Barcodes Found**: Nombre de codis detectats
- **Processing Time**: Temps total de processament

#### Accions:

1. **Veure Detalls**
   - Clica sobre un job per veure més informació
   - Veuràs tots els codis detectats
   - Pots descarregar els resultats

2. **Re-processar**
   - Si un job va fallar, pots tornar-lo a processar
   - Clica "Retry" al costat del job

3. **Eliminar**
   - Pots eliminar jobs antics
   - Clica "Delete" (amb confirmació)

4. **Filtrar**
   - Filtra per estat (COMPLETED, FAILED, etc.)
   - Cerca per nom de vídeo
   - Ordena per data, temps, etc.

---

## 🎯 Casos d'Ús Típics

### Cas 1: Processar un Vídeo Nou

```
1. Ves a "Upload Video"
2. Puja el vídeo
3. Deixa les opcions per defecte
4. Clica "Process Video"
5. Espera els resultats
6. Descarrega el CSV
```

**Temps estimat:** 1-5 minuts (depèn de la durada del vídeo)

---

### Cas 2: Revisar Vídeos Processats Avui

```
1. Ves a "Job History"
2. Filtra per data: Avui
3. Revisa els resultats
4. Descarrega els que necessitis
```

---

### Cas 3: Analitzar Rendiment del Sistema

```
1. Ves a "Audit Dashboard"
2. Selecciona rang de dates: Última setmana
3. Revisa les estadístiques
4. Identifica problemes (vídeos amb errors)
5. Exporta dades per anàlisi
```

---

### Cas 4: Re-processar un Vídeo que va Fallar

```
1. Ves a "Job History"
2. Filtra per estat: FAILED
3. Troba el vídeo
4. Clica "Retry"
5. Revisa els nous resultats
```

---

## ⚙️ Configuració Avançada

### Sidebar (Barra Lateral)

A la barra lateral esquerra trobaràs:

1. **API Status**
   - ✅ API Connected: Tot funciona
   - ❌ API Disconnected: Problema de connexió

2. **System Info**
   - Versió de l'aplicació
   - Estat del backend
   - Estat de la base de dades

3. **Settings** (si està disponible)
   - Configuració de processament
   - Preferències d'usuari

---

## 🔧 Opcions de Processament

### Frame Interval

**Què fa:** Determina cada quants frames s'analitza el vídeo

**Valors recomanats:**
- **5-10**: Vídeos amb codis que es mouen ràpid
- **10-20**: Vídeos normals (recomanat)
- **20-30**: Vídeos amb codis estàtics o per processar més ràpid

**Exemple:**
- Vídeo de 30 FPS, interval 10 → Analitza 3 frames per segon
- Vídeo de 60 FPS, interval 20 → Analitza 3 frames per segon

### Confidence Threshold

**Què fa:** Filtra deteccions amb baixa confiança

**Valors recomanats:**
- **0.3-0.4**: Si vols detectar tots els codis possibles (més false positives)
- **0.5-0.6**: Equilibri entre precisió i recall (recomanat)
- **0.7-0.9**: Només codis molt clars (menys false positives)

**Exemple:**
- Threshold 0.5 → Accepta deteccions amb > 50% de confiança
- Threshold 0.8 → Només accepta deteccions amb > 80% de confiança

---

## 📊 Interpretació de Resultats

### Taula de Resultats

Cada fila representa una detecció:

```
Frame | Timestamp | Barcode      | Confidence | Type
------|-----------|--------------|------------|--------
150   | 5.0s      | 8123456789   | 0.95       | CODE128
300   | 10.0s     | 8123456789   | 0.92       | CODE128
450   | 15.0s     | 9876543210   | 0.88       | CODE128
```

**Interpretació:**
- El codi `8123456789` apareix als segons 5 i 10 (mateix codi, diferents frames)
- El codi `9876543210` apareix al segon 15 (codi diferent)
- Totes les deteccions tenen alta confiança (> 0.88)

### Codis Duplicats

**És normal veure el mateix codi múltiples vegades:**
- El codi apareix en múltiples frames consecutius
- Això confirma que la detecció és correcta

**Post-processament:**
- Pots agrupar codis iguals que apareixen en un rang de temps curt
- Exemple: Si el mateix codi apareix entre els segons 5-7, és una sola detecció

---

## 🚨 Resolució de Problemes

### Problema: No detecta cap codi

**Possibles causes:**
1. **Codis massa petits o borrosos**
   - Solució: Millora la qualitat del vídeo
   
2. **Threshold massa alt**
   - Solució: Baixa el confidence threshold a 0.3-0.4
   
3. **Frame interval massa alt**
   - Solució: Baixa el frame interval a 5-10

4. **Model no entrenat per aquest tipus de codi**
   - Solució: Entrena el model amb més exemples (veure GUIA_ENTRENAMENT_YOLO.md)

### Problema: Massa false positives

**Possibles causes:**
1. **Threshold massa baix**
   - Solució: Puja el confidence threshold a 0.6-0.7
   
2. **Model detecta objectes similars**
   - Solució: Re-entrena el model amb més exemples negatius

### Problema: Processament massa lent

**Possibles causes:**
1. **Frame interval massa baix**
   - Solució: Puja el frame interval a 20-30
   
2. **Vídeo massa llarg o alta resolució**
   - Solució: Redueix la resolució del vídeo abans de pujar-lo
   
3. **Model massa gran**
   - Solució: Usa un model més petit (yolov8n en lloc de yolov8m)

### Problema: Job queda en PROCESSING

**Possibles causes:**
1. **Worker no està funcionant**
   - Solució: Comprova que el contenidor `mobilscan-worker` està UP
   ```bash
   docker ps | grep worker
   ```
   
2. **Error en el processament**
   - Solució: Revisa els logs del worker
   ```bash
   docker logs mobilscan-worker
   ```

---

## 💡 Consells i Millors Pràctiques

### 1. Qualitat del Vídeo

✅ **Recomanat:**
- Resolució: 720p o superior
- FPS: 30 o superior
- Il·luminació: Bona i uniforme
- Enfocament: Clar i nítid

❌ **Evita:**
- Vídeos massa foscos
- Vídeos borrosos o desenfocats
- Resolució massa baixa (< 480p)
- Moviments massa ràpids

### 2. Configuració Òptima

**Per vídeos normals:**
```
Frame Interval: 10-15
Confidence Threshold: 0.5-0.6
```

**Per vídeos amb codis petits:**
```
Frame Interval: 5-10
Confidence Threshold: 0.4-0.5
```

**Per processar ràpid:**
```
Frame Interval: 20-30
Confidence Threshold: 0.6-0.7
```

### 3. Gestió de Resultats

- **Descarrega els CSV regularment** per no perdre dades
- **Revisa els jobs FAILED** per identificar problemes
- **Analitza les estadístiques** per millorar el sistema

### 4. Manteniment

- **Neteja jobs antics** (> 30 dies) per alliberar espai
- **Monitoritza el rendiment** amb l'Audit Dashboard
- **Re-entrena el model** si la precisió baixa

---

## 📈 Mètriques de Rendiment

### Què esperar:

| Mètrica | Valor Típic | Excel·lent |
|---------|-------------|------------|
| **Temps de processament** | 1-3 min per vídeo de 1 min | < 1 min |
| **Taxa de detecció** | 80-90% | > 95% |
| **False positives** | < 10% | < 5% |
| **FPS de processament** | 15-30 FPS | > 30 FPS |

### Com Millorar:

1. **Millora la qualitat dels vídeos**
2. **Entrena el model amb més dades**
3. **Ajusta els paràmetres de processament**
4. **Usa un servidor amb més recursos**

---

## 🆘 Suport

### Documentació Addicional:

- **GUIA_ENTRENAMENT_YOLO.md**: Com entrenar el model
- **APLICACIO_FUNCIONANT.md**: Verificació del sistema
- **README.md**: Informació general del projecte

### Logs i Debugging:

```bash
# Veure logs del backend
docker logs mobilscan-backend

# Veure logs del worker
docker logs mobilscan-worker

# Veure logs del frontend
docker logs mobilscan-frontend
```

### Contacte:

- **GitHub Issues**: [Reporta problemes aquí]
- **Email**: [El teu email]

---

## ✅ Checklist d'Ús Diari

- [ ] Comprova que l'API està connectada (sidebar)
- [ ] Puja els vídeos del dia
- [ ] Revisa els resultats a "Job History"
- [ ] Descarrega els CSV necessaris
- [ ] Revisa l'Audit Dashboard per estadístiques
- [ ] Re-processa jobs que hagin fallat

---

**🎉 Ara ja saps com usar l'aplicació Mobile Industrial Scanner!**

**Temps d'aprenentatge:** 15-30 minuts

**Productivitat:** Processa desenes de vídeos per dia automàticament
