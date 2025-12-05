
# Use full Python image instead of slim to avoid apt-get issues
# This image already has most system dependencies pre-installed
FROM python:3.9

WORKDIR /app

# Copy requirements from parent directory
COPY requirements-worker.txt .

# Install Python dependencies with increased timeout
RUN pip install --no-cache-dir --timeout=1000 -r requirements-worker.txt

# Copy application code
COPY ./worker/processor.py .
COPY ./shared/database.py .

# Create necessary directories
RUN mkdir -p /app/videos /app/frames /app/results

# Run the worker
CMD ["python", "processor.py"]
