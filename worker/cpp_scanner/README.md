# Barcode Scanner C++ - zxing-cpp v2.2.1

Component C++ natiu per a detecció i decodificació de codis de barres utilitzant l'última versió de zxing-cpp.

## 📋 Descripció

Aquest component proporciona un executable de test independent que utilitza zxing-cpp compilat des del codi font per validar la detecció de codis de barres.

## 🏗️ Compilació

### Requisits

- CMake >= 3.14
- Compilador C++ amb suport C++17 (g++, clang++)
- Git (per descarregar zxing-cpp)

### Compilació Manual (fora de Docker)

```bash
cd worker/cpp_scanner
mkdir build
cd build
cmake ..
cmake --build .
```

L'executable es generarà a: `build/bin/barcode_test`

### Compilació dins de Docker

El Dockerfile del worker ja inclou la compilació automàtica d'aquest component.

## 🚀 Ús

### Amb imatge de test

```bash
./barcode_test /path/to/barcode_image.ppm
```

### Sense imatge (test pattern)

```bash
./barcode_test
```

**Nota**: El programa actual només suporta format PPM (P6) per simplicitat. Per utilitzar altres formats (JPG, PNG), converteix primer:

```bash
# Utilitzant ImageMagick
convert barcode.jpg barcode.ppm

# Utilitzant FFmpeg
ffmpeg -i barcode.png barcode.ppm
```

## 📦 Dependències

### zxing-cpp v2.2.1

El CMakeLists.txt descarrega i compila automàticament zxing-cpp v2.2.1 utilitzant FetchContent:

```cmake
FetchContent_Declare(
    ZXing
    GIT_REPOSITORY https://github.com/zxing-cpp/zxing-cpp.git
    GIT_TAG v2.2.1  # Versió específica i estable
    GIT_SHALLOW TRUE
)
```

### Configuració de Build

- **BUILD_READERS**: ON (decodificació)
- **BUILD_WRITERS**: OFF (no necessitem encoding)
- **BUILD_EXAMPLES**: OFF
- **BUILD_TESTS**: OFF

Això minimitza el temps de compilació i la mida del build.

## 🔧 Característiques del Test

El programa `barcode_test.cpp` inclou:

### Detecció Avançada

```cpp
ZXing::DecodeHints hints;
hints.setFormats(ZXing::BarcodeFormat::Any);  // Tots els formats
hints.setTryHarder(true);                      // Escaneig exhaustiu
hints.setTryRotate(true);                      // Prova rotacions
hints.setTryDownscale(true);                   // Prova escalats
hints.setMaxNumberOfSymbols(10);               // Fins a 10 codis
```

### Informació Detallada

Per cada codi detectat mostra:
- 📋 Format (EAN-13, QR Code, Code128, etc.)
- 📝 Text decodificat
- 📍 Posició (coordenades)
- 🔄 Orientació
- 🏷️ Tipus de contingut
- 🛡️ Nivell de correcció d'errors (si aplica)
- 🔖 Identificador de simbologia

### Exemple de Sortida

```
╔════════════════════════════════════════════════════════════╗
║        Barcode Scanner Test - zxing-cpp v2.2.1            ║
╚════════════════════════════════════════════════════════════╝

📂 Loading image: test_barcode.ppm
✅ Image loaded: 800x600

🔍 Scanning for barcodes...
   Formats: All
   Try harder: Yes
   Try rotate: Yes
   Max symbols: 10

📊 Results: 2 barcode(s) found

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

## 🐳 Integració amb Docker

El Dockerfile del worker compila aquest component en una fase intermèdia per no engreixar la imatge final:

```dockerfile
# Build stage per C++ scanner
FROM python:3.10-slim as cpp-builder
RUN apt-get update && apt-get install -y build-essential cmake git
COPY worker/cpp_scanner /build
WORKDIR /build
RUN mkdir build && cd build && cmake .. && cmake --build .

# Final stage
FROM python:3.10-slim
COPY --from=cpp-builder /build/build/bin/barcode_test /usr/local/bin/
```

## 🧪 Testing

### Test Ràpid

```bash
# Dins del contenidor Docker
docker exec -it mobil_scan_worker barcode_test

# O des de l'host (si està compilat localment)
./build/bin/barcode_test
```

### Test amb Imatge Real

```bash
# Preparar imatge de test
convert sample_barcode.jpg sample_barcode.ppm

# Executar test
docker exec -it mobil_scan_worker barcode_test /app/test_images/sample_barcode.ppm
```

## 📚 API Moderna de zxing-cpp

### Funcions Principals

```cpp
// Llegir un sol codi
ZXing::Result result = ZXing::ReadBarcode(imageView, hints);

// Llegir múltiples codis
ZXing::Results results = ZXing::ReadBarcodes(imageView, hints);

// Accedir a la informació
std::string text = result.text();
ZXing::BarcodeFormat format = result.format();
ZXing::Position position = result.position();
```

### Formats Suportats

- **1D**: Code 39, Code 93, Code 128, Codabar, EAN-8, EAN-13, UPC-A, UPC-E, ITF
- **2D**: QR Code, Data Matrix, Aztec, PDF417, MaxiCode

## 🔄 Actualitzar zxing-cpp

Per actualitzar a una versió més recent:

1. Edita `CMakeLists.txt`
2. Canvia `GIT_TAG v2.2.1` per la nova versió (ex: `v2.3.0`)
3. Recompila amb `--no-cache`:

```bash
docker-compose build --no-cache worker
```

## 📖 Referències

- [zxing-cpp GitHub](https://github.com/zxing-cpp/zxing-cpp)
- [zxing-cpp Documentation](https://github.com/zxing-cpp/zxing-cpp/wiki)
- [API Reference](https://github.com/zxing-cpp/zxing-cpp/blob/master/core/src/ReadBarcode.h)

## 🐛 Troubleshooting

### Error: "Cannot open file"

Assegura't que la ruta de la imatge és correcta i que el fitxer existeix.

### Error: "Only P6 PPM format supported"

Converteix la imatge a format PPM:
```bash
convert input.jpg output.ppm
```

### No barcodes detected

- Verifica que la imatge conté un codi de barres visible
- Prova amb millor qualitat d'imatge
- Assegura't que el codi no està danyat o parcialment ocult

### Build errors

- Verifica que tens CMake >= 3.14
- Assegura't que tens connexió a Internet (per descarregar zxing-cpp)
- Comprova que tens un compilador C++17 compatible
