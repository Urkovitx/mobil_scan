# 🚀 Deployment Guide - Mobile Industrial Scanner

Complete guide for deploying and testing the Mobile Industrial Scanner MVP.

## 📋 Pre-Deployment Checklist

### System Requirements
- [ ] Docker 20.10+ installed
- [ ] Docker Compose 2.0+ installed
- [ ] 4GB+ RAM available
- [ ] 10GB+ disk space
- [ ] Ports available: 8501, 8000, 6379, 5432

### Verify Installation
```bash
docker --version
docker-compose --version
```

## 🏗️ Local Development Setup

### Step 1: Clone and Navigate
```bash
cd mobil_scan
```

### Step 2: Create Environment File
```bash
cp .env.example .env
```

Edit `.env` if needed (defaults work for local development).

### Step 3: Build and Start Services
```bash
# Build all images
docker-compose build

# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

Expected output:
```
NAME                    STATUS              PORTS
mobil_scan_api          Up                  0.0.0.0:8000->8000/tcp
mobil_scan_frontend     Up                  0.0.0.0:8501->8501/tcp
mobil_scan_worker       Up                  
mobil_scan_redis        Up                  0.0.0.0:6379->6379/tcp
mobil_scan_db           Up                  0.0.0.0:5432->5432/tcp
```

### Step 4: Verify Services

**Check logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f worker
docker-compose logs -f frontend
```

**Test API:**
```bash
curl http://localhost:8000/
```

Expected response:
```json
{
  "status": "healthy",
  "service": "Mobile Industrial Scanner API",
  "version": "1.0.0",
  "redis_connected": true
}
```

**Test Frontend:**
Open browser: http://localhost:8501

### Step 5: Initialize Database
```bash
# Database is auto-initialized on first API start
# Verify tables exist:
docker-compose exec db psql -U mobilscan -d mobilscan_db -c "\dt"
```

Expected tables:
- `video_jobs`
- `detections`

## 🧪 Testing

### Manual Testing

#### Test 1: Video Upload
1. Open http://localhost:8501
2. Go to "Upload Video" tab
3. Upload a test video (MP4/MOV)
4. Click "🚀 Analyze Inventory"
5. Verify job is created (Job ID displayed)

#### Test 2: Processing
1. Go to "Results" tab
2. Enter Job ID from previous test
3. Verify status shows "processing" or "completed"
4. Wait for auto-refresh (5 seconds)
5. Check progress updates

#### Test 3: Results Display
1. Once job is completed
2. Verify detections table appears
3. Check confidence scores
4. Test CSV download
5. Verify text analysis charts

#### Test 4: Job History
1. Go to "Job History" tab
2. Verify all jobs are listed
3. Select a job from dropdown
4. Click "View Selected Job"
5. Verify navigation works

### API Testing

#### Upload via cURL
```bash
curl -X POST http://localhost:8000/upload \
  -F "file=@test_video.mp4"
```

#### Get Job Status
```bash
curl http://localhost:8000/job/{job_id}
```

#### Get Results
```bash
curl "http://localhost:8000/results/{job_id}?min_confidence=0.5"
```

#### Get Statistics
```bash
curl http://localhost:8000/stats
```

### Automated Testing Script

Create `test_system.sh`:
```bash
#!/bin/bash

echo "🧪 Testing Mobile Industrial Scanner..."

# Test API health
echo "1. Testing API health..."
curl -s http://localhost:8000/ | jq .

# Test stats endpoint
echo "2. Testing stats endpoint..."
curl -s http://localhost:8000/stats | jq .

# Upload test video (if exists)
if [ -f "test_video.mp4" ]; then
    echo "3. Uploading test video..."
    RESPONSE=$(curl -s -X POST http://localhost:8000/upload \
      -F "file=@test_video.mp4")
    echo $RESPONSE | jq .
    
    JOB_ID=$(echo $RESPONSE | jq -r .job_id)
    echo "Job ID: $JOB_ID"
    
    # Wait and check status
    echo "4. Checking job status..."
    sleep 5
    curl -s http://localhost:8000/job/$JOB_ID | jq .
fi

echo "✅ Tests complete!"
```

Run:
```bash
chmod +x test_system.sh
./test_system.sh
```

## 🐛 Troubleshooting

### Issue: Services won't start

**Check Docker:**
```bash
docker ps -a
docker-compose logs
```

**Common fixes:**
```bash
# Restart services
docker-compose restart

# Rebuild images
docker-compose up -d --build

# Clean restart
docker-compose down
docker-compose up -d
```

### Issue: Port already in use

**Find process using port:**
```bash
# Windows
netstat -ano | findstr :8501
netstat -ano | findstr :8000

# Linux/Mac
lsof -i :8501
lsof -i :8000
```

**Change ports in docker-compose.yml:**
```yaml
services:
  frontend:
    ports:
      - "8502:8501"  # Changed from 8501
```

### Issue: Worker not processing

**Check Redis connection:**
```bash
docker-compose exec redis redis-cli ping
# Should return: PONG
```

**Check worker logs:**
```bash
docker-compose logs -f worker
```

**Manually push test job:**
```bash
docker-compose exec redis redis-cli
> LPUSH video_queue '{"job_id":"test","video_path":"/app/videos/test.mp4","video_name":"test.mp4"}'
> LLEN video_queue
```

### Issue: Database connection failed

**Check database:**
```bash
docker-compose exec db psql -U mobilscan -d mobilscan_db
```

**Reset database:**
```bash
docker-compose down -v
docker-compose up -d
```

### Issue: Low OCR accuracy

**Possible causes:**
- Poor video quality
- Low lighting
- Text too small
- Motion blur

**Solutions:**
1. Increase video resolution
2. Reduce FRAME_INTERVAL (more frames)
3. Lower confidence threshold in UI
4. Pre-process video (stabilization, brightness)

## 📊 Monitoring

### View Logs
```bash
# Real-time logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Specific service
docker-compose logs -f worker
```

### Check Resource Usage
```bash
docker stats
```

### Database Queries
```bash
# Connect to database
docker-compose exec db psql -U mobilscan -d mobilscan_db

# Count jobs
SELECT status, COUNT(*) FROM video_jobs GROUP BY status;

# Count detections
SELECT COUNT(*) FROM detections;

# Recent jobs
SELECT job_id, video_name, status, created_at 
FROM video_jobs 
ORDER BY created_at DESC 
LIMIT 10;
```

## 🔧 Configuration

### Adjust Frame Extraction Rate

Edit `.env`:
```bash
FRAME_INTERVAL=15  # Extract more frames (slower but more accurate)
FRAME_INTERVAL=60  # Extract fewer frames (faster but less accurate)
```

Restart worker:
```bash
docker-compose restart worker
```

### Scale Workers

Process multiple videos in parallel:
```bash
docker-compose up -d --scale worker=3
```

### Enable GPU for PaddleOCR

Edit `worker/processor.py`:
```python
ocr_engine = PaddleOCR(
    use_angle_cls=True,
    lang='en',
    use_gpu=True,  # Changed from False
    show_log=False
)
```

Update `worker/Dockerfile` to use CUDA base image.

## 🚀 Production Deployment

### AWS Deployment

#### Prerequisites
- AWS account
- AWS CLI configured
- ECR repository created

#### Step 1: Push Images to ECR
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin {account}.dkr.ecr.us-east-1.amazonaws.com

# Tag images
docker tag mobil_scan_api:latest {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_api:latest
docker tag mobil_scan_worker:latest {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_worker:latest
docker tag mobil_scan_frontend:latest {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_frontend:latest

# Push images
docker push {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_api:latest
docker push {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_worker:latest
docker push {account}.dkr.ecr.us-east-1.amazonaws.com/mobil_scan_frontend:latest
```

#### Step 2: Use Managed Services
- **RDS PostgreSQL** instead of local PostgreSQL
- **ElastiCache Redis** instead of local Redis
- **S3** for video storage
- **ECS/EKS** for container orchestration

#### Step 3: Update Environment Variables
```bash
DATABASE_URL=postgresql://user:pass@rds-endpoint:5432/dbname
REDIS_URL=redis://elasticache-endpoint:6379/0
```

### Google Cloud Deployment

#### Prerequisites
- GCP account
- gcloud CLI configured
- GCR repository created

#### Step 1: Push Images to GCR
```bash
# Tag images
docker tag mobil_scan_api:latest gcr.io/{project-id}/mobil_scan_api:latest
docker tag mobil_scan_worker:latest gcr.io/{project-id}/mobil_scan_worker:latest
docker tag mobil_scan_frontend:latest gcr.io/{project-id}/mobil_scan_frontend:latest

# Push images
docker push gcr.io/{project-id}/mobil_scan_api:latest
docker push gcr.io/{project-id}/mobil_scan_worker:latest
docker push gcr.io/{project-id}/mobil_scan_frontend:latest
```

#### Step 2: Deploy to Cloud Run
```bash
# Deploy API
gcloud run deploy mobil-scan-api \
  --image gcr.io/{project-id}/mobil_scan_api:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Deploy Frontend
gcloud run deploy mobil-scan-frontend \
  --image gcr.io/{project-id}/mobil_scan_frontend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## 🔐 Security Hardening

### Add Authentication

Edit `backend/main.py`:
```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

@app.post("/upload")
async def upload_video(
    file: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    # Verify token
    if not verify_token(credentials.credentials):
        raise HTTPException(status_code=401, detail="Invalid token")
    # ... rest of code
```

### Enable HTTPS

Use reverse proxy (nginx):
```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8501;
    }
    
    location /api {
        proxy_pass http://localhost:8000;
    }
}
```

### Rate Limiting

Add to `backend/main.py`:
```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/upload")
@limiter.limit("5/minute")
async def upload_video(...):
    # ... code
```

## 📈 Performance Optimization

### Database Indexing
```sql
CREATE INDEX idx_job_id ON detections(job_id);
CREATE INDEX idx_video_name ON video_jobs(video_name);
CREATE INDEX idx_status ON video_jobs(status);
```

### Caching Results
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_job_results(job_id: str):
    # ... query database
```

### Batch Processing
```python
# Process multiple frames in parallel
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=4) as executor:
    results = executor.map(process_frame, frames)
```

## ✅ Deployment Checklist

- [ ] All services start successfully
- [ ] API health check passes
- [ ] Frontend loads without errors
- [ ] Video upload works
- [ ] Worker processes jobs
- [ ] Results display correctly
- [ ] CSV export works
- [ ] Database persists data
- [ ] Logs are accessible
- [ ] Resource usage is acceptable
- [ ] Security measures implemented
- [ ] Monitoring configured
- [ ] Backup strategy defined
- [ ] Documentation updated

## 📞 Support

For deployment issues:
1. Check logs: `docker-compose logs -f`
2. Review this guide
3. Check GitHub issues
4. Contact support team

---

**Happy Deploying! 🚀**
