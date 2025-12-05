FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements from parent directory
COPY requirements-base.txt .

# Install Python dependencies with increased timeout
RUN pip install --no-cache-dir --timeout=1000 -r requirements-base.txt

# Copy application code
COPY ./backend/main.py .
COPY ./shared/database.py .

# Create necessary directories
RUN mkdir -p /app/videos /app/frames /app/results

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
