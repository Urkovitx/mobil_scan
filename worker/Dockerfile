

FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install lightweight system deps required by opencv and ffmpeg
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   ca-certificates \
	   ffmpeg \
	   libgl1 \
	   libglib2.0-0 \
	&& rm -rf /var/lib/apt/lists/*

# Copy requirements and use longer pip timeout and no-cache
COPY requirements-worker.txt ./
RUN pip install --no-cache-dir --default-timeout=1000 -r requirements-worker.txt

# Copy application code
COPY ./worker/processor.py ./
COPY ./shared/database.py ./

# Create necessary directories
RUN mkdir -p /app/videos /app/frames /app/results

# Set a non-root user (optional safety) - keep using root if volumes require it
# USER appuser

CMD ["python", "processor.py"]
