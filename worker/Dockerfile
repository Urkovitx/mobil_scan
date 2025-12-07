# ============================================================================
# Stage 1: Build C++ Scanner (zxing-cpp v2.2.1)
# ============================================================================
FROM python:3.10-slim as cpp-builder

ENV DEBIAN_FRONTEND=noninteractive
ENV GIT_SSL_NO_VERIFY=1

WORKDIR /build

# Install build dependencies for C++ compilation
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   build-essential \
	   cmake \
	   git \
	   ca-certificates \
	   wget \
	   curl \
	&& rm -rf /var/lib/apt/lists/*

# Copy C++ scanner source code
COPY ./worker/cpp_scanner /build

# Build C++ scanner with increased timeout and retry logic
RUN mkdir -p build \
	&& cd build \
	&& cmake -DCMAKE_BUILD_TYPE=Release .. \
	&& cmake --build . --parallel 2 \
	&& echo "✅ C++ scanner compiled successfully"

# Verify the executable was created
RUN test -f /build/build/bin/barcode_test || (echo "❌ barcode_test not found!" && exit 1)

# ============================================================================
# Stage 2: Final Worker Image
# ============================================================================
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install runtime dependencies (no build tools needed here)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   ca-certificates \
	   ffmpeg \
	   libgl1 \
	   libglib2.0-0 \
	   libstdc++6 \
	&& rm -rf /var/lib/apt/lists/*

# Copy C++ scanner executable from builder stage
COPY --from=cpp-builder /build/build/bin/barcode_test /usr/local/bin/barcode_test

# Verify C++ scanner is executable
RUN chmod +x /usr/local/bin/barcode_test \
	&& barcode_test 2>&1 || echo "✅ C++ scanner ready"

# Copy Python requirements and install with longer timeout
COPY ./worker/requirements-worker.txt ./
RUN pip install --no-cache-dir --default-timeout=1000 -r requirements-worker.txt

# Copy application code
COPY ./worker/processor.py ./
COPY ./shared/database.py ./

# Create necessary directories
RUN mkdir -p /app/videos /app/frames /app/results /app/models /app/test_images

# Add a simple test script for the C++ scanner
RUN echo '#!/bin/bash\n\
echo "🧪 Testing C++ Barcode Scanner..."\n\
echo ""\n\
barcode_test\n\
echo ""\n\
echo "✅ C++ scanner test completed"\n\
' > /usr/local/bin/test-cpp-scanner \
	&& chmod +x /usr/local/bin/test-cpp-scanner

# Set labels for image metadata
LABEL maintainer="Mobile Industrial Scanner Team"
LABEL description="Worker service with YOLOv8 + zxing-cpp (Python & C++)"
LABEL zxing-cpp.version="2.2.1"
LABEL python.version="3.10"

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
	CMD python -c "import redis; redis.from_url('${REDIS_URL}').ping()" || exit 1

# Run the Python worker
CMD ["python", "processor.py"]
