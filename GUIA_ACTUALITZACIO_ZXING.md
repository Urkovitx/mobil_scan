# 📘 Guia Completa d'Actualització zxing-cpp v2.2.1

## 🎯 Objectiu

Actualitzar el projecte per utilitzar l'última versió estable de zxing-cpp (v2.2.1) tant en Python com en C++ natiu, assegurant una reconstrucció completa de l'entorn Docker.

---

## 📋 Resum de Canvis

### ✅ Actualitzacions Realitzades

1. **Python Bindings**: `zxing-cpp>=2.1.0` → `zxing-cpp>=2.2.0`
2. **Component C++ Natiu**: Nou executable `barcode_test` compilat des del codi font
3. **Dockerfile Multi-Stage**: Build optimitzat que no engreixa la imatge final
4. **Scripts de Rebuild**: Comandes automatitzades amb `--no-cache`
5. **Documentació**: Guies completes d'ús i testing

### 📁 Fitxers Nous Creats

```
worker/
├── cpp_scanner/
│   ├── CMakeLists.txt              # Configuració CMake amb FetchContent
│   ├── src/
│   │   └── barcode_test.cpp        # Executable de test C++
│   └── README.md                   # Documentació del component C++
│
REBUILD_WORKER_NO_CACHE.bat         # Rebuild worker sense caché
REBUILD_ALL_NO_CACHE.bat            # Rebuild tots els serveis sense caché
TEST_CPP_SCANNER.bat                # Test del scanner C++
GUIA_ACTUALITZACIO_ZXING.md         # Aquest document
```

### 📝 Fitxers Modificats

- `worker/requirements-worker.txt`: Actualitzat a zxing-cpp>=2.2.0
- `worker/Dockerfile`: Multi-stage build amb compilació C++

---

## 🚀 Part 1: Dependència (CMakeLists.txt)

### Configuració CMake

El fitxer `worker/cpp_scanner/CMakeLists.txt` defineix com descarregar i compilar zxing-cpp:

```cmake
# Descarrega zxing-cpp v2.2.1 (versió específica i estable)
FetchContent_Declare(
    ZXing
    GIT_REPOSITORY https://github.com/zxing-cpp/zxing-cpp.git
    GIT_TAG v2.2.1  # Versió fixa per evitar canvis inesperats
    GIT_SHALLOW TRUE  # Només descarrega el tag específic
)
```

### Opcions de Build

```cmake
set(BUILD_WRITERS OFF)      # No necessitem encoding
set(BUILD_READERS ON)       # Només decoding
set(BUILD_EXAMPLES OFF)     # Sense exemples
set(BUILD_TESTS OFF)        # Sense tests
```

Això minimitza el temps de compilació i la mida del build.

### Compilació Manual (Opcional)

Si vols compilar fora de Docker:

```bash
cd worker/cpp_scanner
mkdir build && cd build
cmake ..
cmake --build .
./bin/barcode_test
```

---

## 🐳 Part 2: Reconstrucció Docker (CRÍTIC)

### Opció A: Rebuild Només Worker (Recomanat)

```batch
REBUILD_WORKER_NO_CACHE.bat
```

Aquest script:
1. ✅ Atura el contenidor worker
2. ✅ Elimina la imatge antiga
3. ✅ Reconstrueix amb `--no-cache --pull`
4. ✅ Verifica la instal·lació de zxing-cpp
5. ✅ Inicia el worker actualitzat

**Temps estimat**: 5-10 minuts

### Opció B: Rebuild Tots els Serveis

```batch
REBUILD_ALL_NO_CACHE.bat
```

Aquest script reconstrueix API, Worker i Frontend des de zero.

**Temps estimat**: 10-15 minuts

### Comandes Docker Manuals

Si prefereixes executar les comandes manualment:

```bash
# Aturar serveis
docker-compose down

# Eliminar imatges antigues
docker rmi mobil_scan-worker

# Rebuild worker sense caché
docker-compose build --no-cache --pull worker

# Iniciar serveis
docker-compose up -d
```

### ⚠️ Paràmetres Crítics

- `--no-cache`: Ignora TOTES les capes de caché
- `--pull`: Descarrega les imatges base més recents
- Aquests paràmetres són **essencials** per garantir que es descarrega i compila la nova versió

---

## 🧪 Part 3: Codi de Test (main.cpp)

### Executable: barcode_test.cpp

El fitxer `worker/cpp_scanner/src/barcode_test.cpp` proporciona un programa complet de test.

### Característiques

✅ **Lectura d'imatges**: Suporta format PPM (P6)
✅ **API Moderna**: Utilitza `ZXing::ReadBarcodes()` amb `DecodeHints`
✅ **Detecció Avançada**: Try harder, rotate, downscale
✅ **Múltiples Formats**: EAN-13, QR Code, Code128, etc.
✅ **Sortida Detallada**: Format, text, posició, orientació, etc.

### Ús del Test

#### 1. Test Bàsic (sense imatge)

```bash
docker-compose exec worker barcode_test
```

O des de Windows:
```batch
TEST_CPP_SCANNER.bat
```

#### 2. Test amb Imatge Real

```bash
# Copiar imatge al contenidor
docker cp barcode.jpg mobil_scan_worker:/app/test.jpg

# Convertir a PPM (dins del contenidor)
docker-compose exec worker sh -c "apt-get update && apt-get install -y imagemagick"
docker-compose exec worker convert test.jpg test.ppm

# Executar test
docker-compose exec worker barcode_test /app/test.ppm
```

#### 3. Test amb Imatge des de Volum Compartit

```bash
# Posar imatge a shared/frames/
copy barcode.jpg shared\frames\

# Convertir i testejar
docker-compose exec worker convert /app/frames/barcode.jpg /app/frames/test.ppm
docker-compose exec worker barcode_test /app/frames/test.ppm
```

### Exemple de Sortida

```
╔════════════════════════════════════════════════════════════╗
║        Barcode Scanner Test - zxing-cpp v2.2.1            ║
╚════════════════════════════════════════════════════════════╝

📂 Loading image: test.ppm
✅ Image loaded: 800x600

🔍 Scanning for barcodes...
   Formats: All
   Try harder: Yes
   Try rotate: Yes
   Max symbols: 10

📊 Results: 1 barcode(s) found

╔════════════════════════════════════════════════════════════╗
║  Barcode #1
╠════════════════════════════════════════════════════════════╣
║  📋 Format:     EAN-13
║  📝 Text:       5901234123457
║  📍 Position:   (120,200) → (380,280)
║  🔄 Orientation: 0°
║  🏷️  Content:    Text
╚════════════════════════════════════════════════════════════╝

✅ Barcode detection completed successfully!
```

---

## 🔍 Verificació de la Instal·lació

### 1. Verificar Python Bindings

```bash
docker-compose exec worker python -c "import zxingcpp; print(zxingcpp.__version__)"
```

**Sortida esperada**: `2.2.0` o superior

### 2. Verificar Executable C++

```bash
docker-compose exec worker which barcode_test
```

**Sortida esperada**: `/usr/local/bin/barcode_test`

### 3. Test Complet

```bash
docker-compose exec worker test-cpp-scanner
```

Aquest script intern executa un test bàsic del scanner.

### 4. Verificar Logs del Worker

```bash
docker-compose logs worker | findstr "zxing"
```

Hauries de veure missatges com:
- `✅ zxing-cpp available: True`
- `✅ C++ scanner ready`

---

## 📊 Arquitectura Multi-Stage Build

### Stage 1: cpp-builder

```dockerfile
FROM python:3.10-slim as cpp-builder
# Instal·la build-essential, cmake, git
# Compila barcode_test
# Genera executable a /build/build/bin/barcode_test
```

**Avantatges**:
- ✅ Compilació aïllada
- ✅ No contamina la imatge final
- ✅ Eines de build no queden a la imatge final

### Stage 2: Final Image

```dockerfile
FROM python:3.10-slim
# Copia NOMÉS l'executable compilat
COPY --from=cpp-builder /build/build/bin/barcode_test /usr/local/bin/
# Instal·la dependències Python
# Copia codi de l'aplicació
```

**Avantatges**:
- ✅ Imatge final més petita
- ✅ Només runtime dependencies
- ✅ Més segura (sense eines de compilació)

### Comparació de Mides

| Tipus Build | Mida Imatge |
|-------------|-------------|
| Single-stage (amb build tools) | ~1.5 GB |
| Multi-stage (optimitzat) | ~800 MB |
| **Estalvi** | **~700 MB** |

---

## 🔧 Troubleshooting

### Problema: "zxing-cpp not found"

**Solució**:
```bash
REBUILD_WORKER_NO_CACHE.bat
```

### Problema: "barcode_test: command not found"

**Causa**: Build C++ ha fallat

**Solució**:
1. Verifica logs del build:
   ```bash
   docker-compose build worker 2>&1 | findstr "error"
   ```
2. Assegura't que tens connexió a Internet
3. Rebuild amb `--no-cache`

### Problema: "CMake Error"

**Causa**: Versió de CMake massa antiga

**Solució**: El Dockerfile ja inclou CMake recent, però si compiles localment:
```bash
# Actualitza CMake
pip install --upgrade cmake
```

### Problema: Build molt lent

**Causa**: Descarrega de zxing-cpp

**Solució**: Normal en el primer build. Builds posteriors seran més ràpids si no uses `--no-cache`.

### Problema: "No barcodes detected"

**Causes possibles**:
- Imatge no conté barcode
- Format d'imatge no suportat (usa PPM)
- Qualitat d'imatge baixa
- Barcode massa petit o gran

**Solució**:
1. Verifica que la imatge conté un barcode visible
2. Converteix a PPM: `convert input.jpg output.ppm`
3. Prova amb una imatge de millor qualitat

---

## 📚 Referències

### Documentació zxing-cpp

- **GitHub**: https://github.com/zxing-cpp/zxing-cpp
- **Wiki**: https://github.com/zxing-cpp/zxing-cpp/wiki
- **API Reference**: https://github.com/zxing-cpp/zxing-cpp/blob/master/core/src/ReadBarcode.h
- **Releases**: https://github.com/zxing-cpp/zxing-cpp/releases

### Formats de Barcode Suportats

#### 1D Barcodes
- Code 39, Code 93, Code 128
- Codabar
- EAN-8, EAN-13
- UPC-A, UPC-E
- ITF (Interleaved 2 of 5)

#### 2D Barcodes
- QR Code
- Data Matrix
- Aztec
- PDF417
- MaxiCode

### CMake FetchContent

- **Documentació**: https://cmake.org/cmake/help/latest/module/FetchContent.html

---

## ✅ Checklist Final

Abans de considerar la migració completa:

- [ ] Worker reconstruït amb `--no-cache`
- [ ] Python bindings actualitzats (>=2.2.0)
- [ ] Executable C++ compilat i accessible
- [ ] Test bàsic executat correctament
- [ ] Test amb imatge real (opcional)
- [ ] Logs del worker sense errors
- [ ] Aplicació completa funcionant

---

## 🎓 Pròxims Passos

1. **Executar rebuild**:
   ```batch
   REBUILD_WORKER_NO_CACHE.bat
   ```

2. **Verificar instal·lació**:
   ```batch
   TEST_CPP_SCANNER.bat
   ```

3. **Provar aplicació completa**:
   ```batch
   VERIFICAR_APLICACIO.bat
   ```

4. **Testejar amb vídeos reals**:
   - Puja un vídeo des del frontend
   - Verifica que la detecció funciona
   - Comprova els resultats

---

## 📞 Suport

Si tens problemes:

1. Revisa els logs: `docker-compose logs worker`
2. Verifica l'estat: `docker-compose ps`
3. Consulta el README: `worker/cpp_scanner/README.md`
4. Revisa aquest document

---

**Versió**: 1.0  
**Data**: 2024  
**zxing-cpp**: v2.2.1  
**Python**: 3.10  
**CMake**: >=3.14  
**Docker**: Multi-stage build optimitzat
