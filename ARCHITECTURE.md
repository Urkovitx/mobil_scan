# 🏗️ Architecture Documentation - Mobile Industrial Scanner

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Mobile Industrial Scanner                    │
│                         SaaS Platform                            │
└─────────────────────────────────────────────────────────────────┘

                              ┌──────────┐
                              │  Client  │
                              │ Browser  │
                              └────┬─────┘
                                   │ HTTP
                                   ▼
                         ┌─────────────────┐
                         │    Frontend     │
                         │   Streamlit     │
                         │   Port: 8501    │
                         └────────┬────────┘
                                  │ REST API
                                  ▼
                         ┌─────────────────┐
                         │    Backend      │
                         │    FastAPI      │
                         │   Port: 8000    │
                         └────┬───────┬────┘
                              │       │
                    ┌─────────┘       └─────────┐
                    │                           │
                    ▼                           ▼
            ┌──────────────┐          ┌──────────────┐
            │   Database   │          │    Redis     │
            │ PostgreSQL   │          │    Queue     │
            │ Port: 5432   │          │  Port: 6379  │
            └──────┬───────┘          └──────┬───────┘
                   │                         │
                   │                         ▼
                   │                  ┌──────────────┐
                   │                  │    Worker    │
                   │                  │  Processor   │
                   │                  │   (Python)   │
                   │                  └──────┬───────┘
                   │                         │
                   └─────────────────────────┘
```

## Component Details

### 1. Frontend Service (Streamlit)

**Purpose:** User interface for video upload and results visualization

**Technology Stack:**
- Streamlit 1.31.0
- Pandas 2.2.0
- Requests 2.31.0

**Responsibilities:**
- Video file upload interface
- Job status monitoring
- Results visualization
- CSV export
- Real-time progress updates

**API Endpoints Used:**
- `GET /` - Health check
- `POST /upload` - Upload video
- `GET /job/{job_id}` - Get job status
- `GET /results/{job_id}` - Get detection results
- `GET /stats` - Get system statistics
- `GET /jobs` - List all jobs

**Port:** 8501

**Environment Variables:**
```bash
API_URL=http://api:8000
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0
```

---

### 2. Backend Service (FastAPI)

**Purpose:** RESTful API for job management and data access

**Technology Stack:**
- FastAPI 0.109.0
- Uvicorn 0.27.0
- SQLAlchemy 2.0.25
- Redis 5.0.1

**Responsibilities:**
- Accept video uploads
- Validate file types
- Create job records
- Push jobs to Redis queue
- Query database for results
- Provide system statistics

**API Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| POST | `/upload` | Upload video file |
| GET | `/jobs` | List all jobs |
| GET | `/job/{job_id}` | Get job status |
| GET | `/results/{job_id}` | Get detection results |
| GET | `/stats` | Get system statistics |

**Port:** 8000

**Environment Variables:**
```bash
REDIS_URL=redis://redis:6379/0
DATABASE_URL=postgresql://mobilscan:mobilscan123@db:5432/mobilscan_db
UPLOAD_FOLDER=/app/videos
FRAMES_FOLDER=/app/frames
```

**Database Models:**
- `VideoJob` - Job metadata
- `Detection` - Text detection results

---

### 3. Worker Service (Python)

**Purpose:** Asynchronous video processing and text detection

**Technology Stack:**
- PaddleOCR 2.7.3
- OpenCV 4.9.0
- Redis 5.0.1
- SQLAlchemy 2.0.25

**Responsibilities:**
- Listen to Redis queue
- Extract frames from videos
- Run OCR on each frame
- Store detections in database
- Update job progress
- Handle errors gracefully

**Processing Pipeline:**
```
1. Receive job from Redis queue
2. Open video file with OpenCV
3. Extract frames (1 per second default)
4. For each frame:
   a. Run PaddleOCR
   b. Extract text and bounding boxes
   c. Save detection to database
5. Update job status
6. Mark job as completed
```

**Environment Variables:**
```bash
REDIS_URL=redis://redis:6379/0
DATABASE_URL=postgresql://mobilscan:mobilscan123@db:5432/mobilscan_db
VIDEOS_FOLDER=/app/videos
FRAMES_FOLDER=/app/frames
FRAME_INTERVAL=30
```

**Configuration:**
- `FRAME_INTERVAL`: Extract 1 frame every N frames (default: 30)
- `use_gpu`: Enable GPU acceleration (default: False)
- `lang`: OCR language (default: 'en')

---

### 4. Redis Service

**Purpose:** Message broker for job queue

**Technology:** Redis 7-alpine

**Responsibilities:**
- Store job queue
- Enable async communication
- Provide pub/sub capabilities

**Port:** 6379

**Queue Structure:**
```
Queue: "video_queue"
Message Format: JSON
{
  "job_id": "uuid",
  "video_path": "/app/videos/file.mp4",
  "video_name": "file.mp4"
}
```

---

### 5. Database Service (PostgreSQL)

**Purpose:** Persistent storage for jobs and results

**Technology:** PostgreSQL 15-alpine

**Port:** 5432

**Database Schema:**

#### Table: `video_jobs`
```sql
CREATE TABLE video_jobs (
    id SERIAL PRIMARY KEY,
    job_id VARCHAR(100) UNIQUE NOT NULL,
    video_name VARCHAR(255) NOT NULL,
    video_path VARCHAR(500) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    total_frames INTEGER DEFAULT 0,
    processed_frames INTEGER DEFAULT 0,
    detections_count INTEGER DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Table: `detections`
```sql
CREATE TABLE detections (
    id SERIAL PRIMARY KEY,
    video_name VARCHAR(255) NOT NULL,
    job_id VARCHAR(100) NOT NULL,
    frame_number INTEGER NOT NULL,
    timestamp FLOAT NOT NULL,
    detected_text TEXT NOT NULL,
    confidence FLOAT NOT NULL,
    bbox_x1 INTEGER,
    bbox_y1 INTEGER,
    bbox_x2 INTEGER,
    bbox_y2 INTEGER,
    frame_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Indexes:**
```sql
CREATE INDEX idx_job_id ON detections(job_id);
CREATE INDEX idx_video_name ON video_jobs(video_name);
CREATE INDEX idx_status ON video_jobs(status);
```

---

## Data Flow

### Video Upload Flow

```
1. User uploads video via Frontend
   ↓
2. Frontend sends POST /upload to Backend
   ↓
3. Backend saves video to /app/videos
   ↓
4. Backend creates VideoJob record in Database
   ↓
5. Backend pushes job to Redis queue
   ↓
6. Backend returns job_id to Frontend
   ↓
7. Frontend displays job_id and redirects to Results
```

### Video Processing Flow

```
1. Worker polls Redis queue (BRPOP)
   ↓
2. Worker receives job message
   ↓
3. Worker updates job status to "processing"
   ↓
4. Worker extracts frames from video
   ↓
5. For each frame:
   a. Run PaddleOCR
   b. Extract text and bounding boxes
   c. Create Detection record
   d. Update job progress
   ↓
6. Worker updates job status to "completed"
   ↓
7. Frontend polls GET /job/{job_id} for updates
   ↓
8. Frontend displays results when completed
```

### Results Retrieval Flow

```
1. User enters job_id in Frontend
   ↓
2. Frontend calls GET /job/{job_id}
   ↓
3. Backend queries video_jobs table
   ↓
4. Backend returns job status and progress
   ↓
5. If completed, Frontend calls GET /results/{job_id}
   ↓
6. Backend queries detections table
   ↓
7. Backend returns all detections
   ↓
8. Frontend displays results in table
```

---

## Scalability

### Horizontal Scaling

**Workers:**
```bash
# Scale to 3 workers
docker-compose up -d --scale worker=3

# Each worker processes jobs independently
# Redis ensures no duplicate processing
```

**API:**
```bash
# Use load balancer (nginx, HAProxy)
# Multiple API instances behind load balancer
# Stateless design enables easy scaling
```

### Vertical Scaling

**Database:**
- Increase connection pool size
- Add read replicas
- Use managed service (RDS, Cloud SQL)

**Redis:**
- Increase memory
- Use Redis Cluster
- Use managed service (ElastiCache, Memorystore)

**Workers:**
- Increase CPU/RAM per container
- Enable GPU for PaddleOCR
- Optimize frame extraction

---

## Performance Optimization

### Database Optimization

**Indexes:**
```sql
CREATE INDEX idx_job_id ON detections(job_id);
CREATE INDEX idx_confidence ON detections(confidence);
CREATE INDEX idx_frame_number ON detections(frame_number);
```

**Connection Pooling:**
```python
engine = create_engine(
    DATABASE_URL,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True
)
```

### Caching Strategy

**Redis Caching:**
```python
# Cache job results for 1 hour
redis_client.setex(f"job:{job_id}", 3600, json.dumps(results))
```

**Application-Level Caching:**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_job_results(job_id: str):
    # Cached in memory
    return db.query(Detection).filter_by(job_id=job_id).all()
```

### Frame Extraction Optimization

**Parallel Processing:**
```python
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=4) as executor:
    results = executor.map(process_frame, frames)
```

**Batch Database Writes:**
```python
# Commit every 10 frames instead of every frame
if frame_count % 10 == 0:
    db.commit()
```

---

## Security Architecture

### Network Security

**Container Isolation:**
- Services communicate via Docker network
- No direct external access to database/redis
- Only frontend and API exposed

**Port Exposure:**
```yaml
# Only expose necessary ports
frontend: 8501 (public)
api: 8000 (public)
redis: 6379 (internal only)
db: 5432 (internal only)
```

### Data Security

**File Validation:**
```python
ALLOWED_EXTENSIONS = ['.mp4', '.mov', '.avi', '.mkv']
MAX_FILE_SIZE = 500 * 1024 * 1024  # 500MB
```

**SQL Injection Prevention:**
- Use SQLAlchemy ORM
- Parameterized queries
- Input validation

**Path Traversal Prevention:**
```python
# Sanitize filenames
safe_filename = secure_filename(file.filename)
```

---

## Monitoring & Logging

### Logging Strategy

**Log Levels:**
- ERROR: Critical failures
- WARNING: Recoverable issues
- INFO: Normal operations
- DEBUG: Detailed debugging

**Log Locations:**
```
Backend: docker-compose logs api
Worker: docker-compose logs worker
Frontend: docker-compose logs frontend
```

**Structured Logging:**
```python
from loguru import logger

logger.add(
    "worker.log",
    rotation="100 MB",
    retention="7 days",
    level="INFO"
)
```

### Metrics Collection

**System Metrics:**
- CPU usage per container
- Memory usage per container
- Disk I/O
- Network traffic

**Application Metrics:**
- Jobs processed per hour
- Average processing time
- Success/failure rate
- Queue length

**Database Metrics:**
- Query performance
- Connection pool usage
- Table sizes
- Index usage

---

## Disaster Recovery

### Backup Strategy

**Database Backups:**
```bash
# Daily backup
docker-compose exec db pg_dump -U mobilscan mobilscan_db > backup.sql

# Restore
docker-compose exec -T db psql -U mobilscan mobilscan_db < backup.sql
```

**Video Storage:**
- Regular backups to S3/Cloud Storage
- Retention policy (30 days)
- Automated cleanup of old files

### Recovery Procedures

**Service Failure:**
```bash
# Restart failed service
docker-compose restart worker

# Full restart
docker-compose down
docker-compose up -d
```

**Data Corruption:**
```bash
# Restore from backup
docker-compose down -v
# Restore database from backup
docker-compose up -d
```

---

## Development Workflow

### Local Development

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Make code changes
# Changes auto-reload (FastAPI, Streamlit)

# Restart if needed
docker-compose restart api
```

### Testing

```bash
# Run unit tests
docker-compose exec api pytest

# Run integration tests
docker-compose exec worker pytest

# Manual testing
# Use frontend at http://localhost:8501
```

### Deployment

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Push to registry
docker push registry/mobil_scan_api:latest

# Deploy to production
# Use orchestration tool (Kubernetes, ECS, etc.)
```

---

## Technology Decisions

### Why PaddleOCR?
- ✅ Better accuracy than Tesseract
- ✅ Handles rotated text
- ✅ Built-in angle classification
- ✅ Better bounding boxes

### Why PostgreSQL?
- ✅ ACID compliance
- ✅ Better concurrency
- ✅ Production-ready
- ✅ Easy to scale

### Why Redis?
- ✅ Fast message broker
- ✅ Simple queue implementation
- ✅ Reliable delivery
- ✅ Widely supported

### Why Microservices?
- ✅ Independent scaling
- ✅ Fault isolation
- ✅ Technology flexibility
- ✅ Easier maintenance

---

## Future Architecture

### Phase 2 Enhancements

**Add Load Balancer:**
```
Client → Load Balancer → [API1, API2, API3]
```

**Add Caching Layer:**
```
API → Redis Cache → Database
```

**Add Message Queue:**
```
API → RabbitMQ → [Worker1, Worker2, Worker3]
```

### Phase 3 (Cloud-Native)

**Kubernetes Deployment:**
- Horizontal Pod Autoscaling
- Service mesh (Istio)
- Distributed tracing
- Centralized logging

**Managed Services:**
- Cloud SQL (Database)
- Cloud Storage (Videos)
- Cloud Pub/Sub (Queue)
- Cloud Run (Containers)

---

**Architecture Version:** 1.0.0  
**Last Updated:** 2024  
**Status:** ✅ Production Ready
