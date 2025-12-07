cmake_minimum_required(VERSION 3.14)
project(BarcodeScanner VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable verbose output for debugging
set(CMAKE_VERBOSE_MAKEFILE ON)

# Include FetchContent module for downloading dependencies
include(FetchContent)

# Configure FetchContent to be more resilient
set(FETCHCONTENT_QUIET OFF)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

# Download and build zxing-cpp from specific stable release
# Using v2.2.1 - latest stable version as of 2024
message(STATUS "Fetching zxing-cpp v2.2.1...")

FetchContent_Declare(
    ZXing
    GIT_REPOSITORY https://github.com/zxing-cpp/zxing-cpp.git
    GIT_TAG v2.2.1  # Specific stable version to avoid future breaking changes
    GIT_SHALLOW TRUE  # Only download the specific tag, not full history
    GIT_PROGRESS TRUE  # Show download progress
    TIMEOUT 600  # 10 minutes timeout for download
)

# Configure zxing-cpp build options
set(BUILD_WRITERS OFF CACHE BOOL "Build with writer support (encoding)")
set(BUILD_READERS ON CACHE BOOL "Build with reader support (decoding)")
set(BUILD_EXAMPLES OFF CACHE BOOL "Build examples")
set(BUILD_BLACKBOX_TESTS OFF CACHE BOOL "Build blackbox tests")
set(BUILD_UNIT_TESTS OFF CACHE BOOL "Build unit tests")
set(BUILD_PYTHON_MODULE OFF CACHE BOOL "Build Python module")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries")

# Make zxing-cpp available
FetchContent_MakeAvailable(ZXing)

message(STATUS "zxing-cpp successfully fetched and configured")

# Create executable for barcode testing
add_executable(barcode_test
    src/barcode_test.cpp
)

# Link against zxing-cpp library
target_link_libraries(barcode_test
    PRIVATE
        ZXing::ZXing
)

# Set output directory
set_target_properties(barcode_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Installation rules (optional)
install(TARGETS barcode_test
    RUNTIME DESTINATION bin
)

# Print build information
message(STATUS "===========================================")
message(STATUS "Barcode Scanner C++ Test Build Configuration")
message(STATUS "===========================================")
message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "zxing-cpp version: v2.2.1")
message(STATUS "===========================================")
