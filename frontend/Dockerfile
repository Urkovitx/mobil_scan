FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements from parent directory
COPY requirements-base.txt .

# Install Python dependencies with increased timeout
RUN pip install --no-cache-dir --timeout=1000 -r requirements-base.txt

# Copy application code
COPY ./frontend/app.py .

# Create necessary directories
RUN mkdir -p /app/videos /app/frames /app/results

# Expose Streamlit port
EXPOSE 8501

# Run Streamlit
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
