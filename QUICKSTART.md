# ⚡ Quick Start Guide - Mobile Industrial Scanner

Get up and running in 5 minutes!

## 🚀 Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)
- 4GB+ RAM available
- 10GB+ disk space

## 📦 Installation

### Step 1: Navigate to Project
```bash
cd mobil_scan
```

### Step 2: Create Environment File
```bash
# Copy example environment file
cp .env.example .env

# No need to edit - defaults work for local development
```

### Step 3: Start All Services
```bash
# Build and start all containers
docker-compose up -d

# This will:
# - Build 3 Docker images (api, worker, frontend)
# - Start 5 services (api, worker, frontend, redis, db)
# - Initialize the database
# - Takes ~5 minutes on first run
```

### Step 4: Verify Services
```bash
# Check all services are running
docker-compose ps

# Expected output:
# NAME                    STATUS
# mobil_scan_api          Up
# mobil_scan_frontend     Up
# mobil_scan_worker       Up
# mobil_scan_redis        Up
# mobil_scan_db           Up
```

### Step 5: Access the Application
Open your browser and go to:
```
http://localhost:8501
```

You should see the Mobile Industrial Scanner interface! 🎉

## 🎬 First Video Analysis

### 1. Prepare a Test Video
- Use any MP4, MOV, AVI, or MKV file
- Recommended: 30 seconds to 2 minutes
- Should contain visible text/codes

### 2. Upload Video
1. Click on "📤 Upload Video" tab
2. Drag & drop your video or click to browse
3. Preview will appear
4. Click "🚀 Analyze Inventory"

### 3. Monitor Progress
1. Go to "📊 Results" tab
2. Your Job ID will be auto-filled
3. Watch the progress bar
4. Page auto-refreshes every 5 seconds

### 4. View Results
Once completed:
- See all detected text in a table
- Filter by confidence threshold
- View text analysis charts
- Download results as CSV

## 🧪 Quick Test

### Test API Health
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

### Test with Sample Video
If you have a test video:
```bash
curl -X POST http://localhost:8000/upload \
  -F "file=@your_video.mp4"
```

## 📊 View Logs

### All Services
```bash
docker-compose logs -f
```

### Specific Service
```bash
# API logs
docker-compose logs -f api

# Worker logs
docker-compose logs -f worker

# Frontend logs
docker-compose logs -f frontend
```

## 🛑 Stop Services

### Stop (keeps data)
```bash
docker-compose stop
```

### Stop and remove containers (keeps data)
```bash
docker-compose down
```

### Stop and remove everything (including data)
```bash
docker-compose down -v
```

## 🔄 Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart worker
```

## 🐛 Troubleshooting

### Issue: Port already in use

**Error:** `Bind for 0.0.0.0:8501 failed: port is already allocated`

**Solution:**
```bash
# Find what's using the port (Windows)
netstat -ano | findstr :8501

# Kill the process or change port in docker-compose.yml
```

### Issue: Services won't start

**Solution:**
```bash
# Check logs
docker-compose logs

# Rebuild images
docker-compose up -d --build

# Clean restart
docker-compose down -v
docker-compose up -d
```

### Issue: Worker not processing

**Solution:**
```bash
# Check worker logs
docker-compose logs -f worker

# Check Redis
docker-compose exec redis redis-cli ping
# Should return: PONG

# Restart worker
docker-compose restart worker
```

### Issue: Cannot connect to API

**Solution:**
```bash
# Check API is running
docker-compose ps api

# Check API logs
docker-compose logs api

# Test API directly
curl http://localhost:8000/
```

## 📚 Next Steps

### Learn More
- Read [README.md](README.md) for detailed features
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for production deployment
- Review [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for architecture details

### Customize
- Edit `.env` to change configuration
- Adjust `FRAME_INTERVAL` for more/fewer frames
- Scale workers: `docker-compose up -d --scale worker=3`

### Monitor
- View stats: http://localhost:8000/stats
- API docs: http://localhost:8000/docs
- Check database: `docker-compose exec db psql -U mobilscan -d mobilscan_db`

## 🎯 Common Use Cases

### Process Multiple Videos
1. Upload first video
2. Note the Job ID
3. Upload second video (new Job ID)
4. Both process in parallel (if multiple workers)
5. View results for each Job ID

### Export Results
1. Go to Results tab
2. Enter Job ID
3. Wait for completion
4. Click "📥 Download Results (CSV)"
5. Open in Excel/PowerBI

### Adjust Confidence Threshold
1. Use slider in sidebar
2. Set minimum confidence (0.0 to 1.0)
3. Results update automatically
4. Lower = more results, higher = more accurate

## ✅ Success Checklist

- [ ] Docker installed and running
- [ ] All 5 services started successfully
- [ ] Frontend accessible at http://localhost:8501
- [ ] API health check passes
- [ ] Test video uploaded successfully
- [ ] Worker processes the video
- [ ] Results display correctly
- [ ] CSV export works

## 🎉 You're Ready!

Congratulations! Your Mobile Industrial Scanner is now running.

**What you can do:**
- ✅ Upload videos from drones or mobile devices
- ✅ Automatically detect all text and codes
- ✅ View results in real-time
- ✅ Export to CSV for analysis
- ✅ Process multiple videos in parallel

**Need help?**
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed troubleshooting
- Review logs: `docker-compose logs -f`
- Test API: http://localhost:8000/docs

---

**Happy Scanning! 📹✨**
