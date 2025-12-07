/**
 * Barcode Scanner Test - zxing-cpp v2.2.1
 * 
 * Test program to validate zxing-cpp integration
 * Reads an image and detects/decodes barcodes using modern API
 * 
 * Usage:
 *   ./barcode_test <image_path>
 *   ./barcode_test  (uses default test image)
 */

#include "ReadBarcode.h"
#include "BarcodeFormat.h"
#include "DecodeHints.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <memory>
#include <cstring>

// Simple image loading for common formats (BMP, PNG, JPG)
// For production, you'd use a proper image library like stb_image or OpenCV
struct ImageData {
    int width = 0;
    int height = 0;
    std::vector<uint8_t> data;
    ZXing::ImageFormat format = ZXing::ImageFormat::RGB;
};

/**
 * Simple PPM image loader (for testing without external dependencies)
 * You can replace this with stb_image or OpenCV for production
 */
bool loadPPM(const std::string& filename, ImageData& image) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        std::cerr << "❌ Error: Cannot open file: " << filename << std::endl;
        return false;
    }

    std::string magic;
    file >> magic;
    
    if (magic != "P6") {
        std::cerr << "❌ Error: Only P6 PPM format supported" << std::endl;
        return false;
    }

    file >> image.width >> image.height;
    int maxval;
    file >> maxval;
    file.get(); // consume newline

    if (maxval != 255) {
        std::cerr << "❌ Error: Only 8-bit PPM supported" << std::endl;
        return false;
    }

    size_t dataSize = image.width * image.height * 3;
    image.data.resize(dataSize);
    file.read(reinterpret_cast<char*>(image.data.data()), dataSize);

    if (!file) {
        std::cerr << "❌ Error: Failed to read image data" << std::endl;
        return false;
    }

    image.format = ZXing::ImageFormat::RGB;
    return true;
}

/**
 * Create a simple test pattern with barcode-like structure
 * This is a fallback if no image is provided
 */
ImageData createTestPattern() {
    ImageData image;
    image.width = 200;
    image.height = 100;
    image.format = ZXing::ImageFormat::Lum; // Grayscale
    
    image.data.resize(image.width * image.height);
    
    // Create a simple barcode-like pattern (vertical bars)
    for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            // Create alternating black and white bars
            int barWidth = 10;
            bool isBlack = ((x / barWidth) % 2) == 0;
            image.data[y * image.width + x] = isBlack ? 0 : 255;
        }
    }
    
    return image;
}

/**
 * Print barcode information in a formatted way
 */
void printBarcodeInfo(const ZXing::Result& result, int index) {
    std::cout << "\n╔════════════════════════════════════════════════════════════╗" << std::endl;
    std::cout << "║  Barcode #" << (index + 1) << std::endl;
    std::cout << "╠════════════════════════════════════════════════════════════╣" << std::endl;
    
    // Format
    std::cout << "║  📋 Format:     " << ToString(result.format()) << std::endl;
    
    // Text content
    std::string text = result.text();
    if (text.length() > 40) {
        std::cout << "║  📝 Text:       " << text.substr(0, 37) << "..." << std::endl;
    } else {
        std::cout << "║  📝 Text:       " << text << std::endl;
    }
    
    // Position
    auto position = result.position();
    std::cout << "║  📍 Position:   " 
              << "(" << position.topLeft().x << "," << position.topLeft().y << ") → "
              << "(" << position.bottomRight().x << "," << position.bottomRight().y << ")" 
              << std::endl;
    
    // Orientation
    std::cout << "║  🔄 Orientation: " << result.orientation() << "°" << std::endl;
    
    // Content type
    std::cout << "║  🏷️  Content:    " << ToString(result.contentType()) << std::endl;
    
    // Error correction level (if applicable)
    if (!result.ecLevel().empty()) {
        std::cout << "║  🛡️  EC Level:   " << result.ecLevel() << std::endl;
    }
    
    // Symbology identifier
    if (!result.symbologyIdentifier().empty()) {
        std::cout << "║  🔖 Symbology:  " << result.symbologyIdentifier() << std::endl;
    }
    
    std::cout << "╚════════════════════════════════════════════════════════════╝" << std::endl;
}

/**
 * Main function
 */
int main(int argc, char* argv[]) {
    std::cout << "\n╔════════════════════════════════════════════════════════════╗" << std::endl;
    std::cout << "║        Barcode Scanner Test - zxing-cpp v2.2.1            ║" << std::endl;
    std::cout << "╚════════════════════════════════════════════════════════════╝\n" << std::endl;

    // Determine image source
    std::string imagePath;
    bool useTestPattern = false;

    if (argc > 1) {
        imagePath = argv[1];
        std::cout << "📂 Loading image: " << imagePath << std::endl;
    } else {
        std::cout << "ℹ️  No image provided, using test pattern" << std::endl;
        std::cout << "   Usage: " << argv[0] << " <image_path>" << std::endl;
        useTestPattern = true;
    }

    // Load or create image
    ImageData image;
    
    if (useTestPattern) {
        image = createTestPattern();
        std::cout << "✅ Test pattern created: " << image.width << "x" << image.height << std::endl;
    } else {
        // Try to load image (PPM format for simplicity)
        if (!loadPPM(imagePath, image)) {
            std::cerr << "\n⚠️  Note: This test program only supports PPM (P6) format" << std::endl;
            std::cerr << "   Convert your image using: convert input.jpg output.ppm" << std::endl;
            std::cerr << "   Or integrate OpenCV/stb_image for full format support" << std::endl;
            std::cerr << "\n   Falling back to test pattern..." << std::endl;
            image = createTestPattern();
            useTestPattern = true;
        } else {
            std::cout << "✅ Image loaded: " << image.width << "x" << image.height << std::endl;
        }
    }

    // Configure decode hints for optimal detection
    ZXing::DecodeHints hints;
    
    // Try all barcode formats
    hints.setFormats(ZXing::BarcodeFormat::Any);
    
    // Enable more thorough scanning (slower but more accurate)
    hints.setTryHarder(true);
    hints.setTryRotate(true);
    hints.setTryDownscale(true);
    
    // Set maximum number of symbols to detect
    hints.setMaxNumberOfSymbols(10);

    std::cout << "\n🔍 Scanning for barcodes..." << std::endl;
    std::cout << "   Formats: All" << std::endl;
    std::cout << "   Try harder: Yes" << std::endl;
    std::cout << "   Try rotate: Yes" << std::endl;
    std::cout << "   Max symbols: 10" << std::endl;

    try {
        // Create ImageView from our image data
        ZXing::ImageView imageView(
            image.data.data(),
            image.width,
            image.height,
            image.format
        );

        // Decode barcodes using modern API
        auto results = ZXing::ReadBarcodes(imageView, hints);

        // Display results
        std::cout << "\n📊 Results: " << results.size() << " barcode(s) found" << std::endl;

        if (results.empty()) {
            std::cout << "\n❌ No barcodes detected in the image" << std::endl;
            
            if (useTestPattern) {
                std::cout << "\nℹ️  The test pattern is not a real barcode." << std::endl;
                std::cout << "   Please provide a real barcode image to test detection." << std::endl;
            } else {
                std::cout << "\nℹ️  Possible reasons:" << std::endl;
                std::cout << "   • Image quality is too low" << std::endl;
                std::cout << "   • Barcode is too small or too large" << std::endl;
                std::cout << "   • Barcode is damaged or partially obscured" << std::endl;
                std::cout << "   • Image format not properly loaded" << std::endl;
            }
            
            return 1;
        }

        // Print detailed information for each barcode
        for (size_t i = 0; i < results.size(); i++) {
            printBarcodeInfo(results[i], i);
        }

        std::cout << "\n✅ Barcode detection completed successfully!" << std::endl;
        return 0;

    } catch (const std::exception& e) {
        std::cerr << "\n❌ Error during barcode detection: " << e.what() << std::endl;
        return 1;
    }
}
