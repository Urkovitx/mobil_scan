# 📹 Mobile Industrial Scanner

A modern, microservices-based SaaS solution for automated text detection in industrial video footage. Upload videos from drones or mobile devices, and let AI extract all visible text and codes automatically.

## 🎯 Key Features

- **Video Upload**: Support for MP4, MOV, AVI, MKV formats
- **Automatic Frame Extraction**: Intelligent sampling (1 frame per second by default)
- **AI-Powered OCR**: PaddleOCR for superior text detection in industrial environments
- **No Filtering**: Captures ALL detected text (filter later in UI)
- **Real-time Progress**: Track processing status with live updates
- **Results Dashboard**: Interactive visualization with confidence scores
- **Export to CSV**: Download results for further analysis
- **Microservices Architecture**: Scalable, fault-tolerant design

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Frontend   │────▶│   FastAPI   │────▶│    Redis    │
│ (Streamlit) │     │   Backend   │     │   Queue     │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                    ┌─────────────┐     ┌─────────────┐
                    │  PostgreSQL │◀────│   Worker    │
                    │  Database   │     │ (Processor) │
                    └─────────────┘     └─────────────┘
```

### Services

1. **Frontend (Streamlit)**: User interface for video upload and results visualization
2. **API (FastAPI)**: RESTful API for file management and job orchestration
3. **Worker (Python)**: Asynchronous video processor with PaddleOCR
4. **Redis**: Message broker for job queue
5. **PostgreSQL**: Persistent storage for results and metadata

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- 4GB+ RAM recommended
- 10GB+ disk space for videos and frames

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobil_scan
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost:8501
   - API Docs: http://localhost:8000/docs
   - Redis: localhost:6379
   - PostgreSQL: localhost:5432

### First Use

1. Open http://localhost:8501 in your browser
2. Upload a video file (MP4, MOV, AVI, MKV)
3. Click "🚀 Analyze Inventory"
4. Wait for processing (auto-refreshes every 5 seconds)
5. View results in the "Results" tab
6. Download CSV for further analysis

## 📁 Project Structure

```
mobil_scan/
├── backend/
│   ├── main.py              # FastAPI application
│   └── Dockerfile
├── worker/
│   ├── processor.py         # Video processing logic
│   └── Dockerfile
├── frontend/
│   ├── app.py              # Streamlit UI
│   └── Dockerfile
├── shared/
│   ├── database.py         # SQLAlchemy models
│   ├── videos/             # Uploaded videos
│   ├── frames/             # Extracted frames
│   └── results/            # Processing results
├── docker-compose.yml      # Service orchestration
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file to customize:

```bash
# Frame extraction rate (1 frame every N frames)
FRAME_INTERVAL=30

# Database connection
DATABASE_URL=postgresql://user:pass@db:5432/dbname

# Redis connection
REDIS_URL=redis://redis:6379/0
```

### Processing Parameters

- **Frame Interval**: Default 30 (1 frame per second at 30fps)
- **OCR Language**: English (can be changed in `worker/processor.py`)
- **Confidence Threshold**: Adjustable in UI (default 0.5)

## 📊 API Endpoints

### Upload Video
```bash
POST /upload
Content-Type: multipart/form-data

Response:
{
  "success": true,
  "job_id": "uuid",
  "status": "queued"
}
```

### Get Job Status
```bash
GET /job/{job_id}

Response:
{
  "job_id": "uuid",
  "status": "completed",
  "progress": 100.0,
  "detections_count": 42
}
```

### Get Results
```bash
GET /results/{job_id}?min_confidence=0.5

Response:
{
  "detections": [
    {
      "frame_number": 30,
      "timestamp": 1.0,
      "detected_text": "ABC123",
      "confidence": 0.95,
      "bbox": {"x1": 100, "y1": 200, "x2": 300, "y2": 250}
    }
  ]
}
```

## 🎨 UI Features

### Upload Tab
- Drag & drop video upload
- Video preview
- File size and format validation

### Results Tab
- Real-time progress tracking
- Auto-refresh during processing
- Interactive data table
- Confidence filtering
- CSV export
- Text analysis charts

### Job History Tab
- List all processed videos
- Filter by status
- Quick access to results

## 🔍 Technical Details

### OCR Engine: PaddleOCR

**Why PaddleOCR over Tesseract?**
- ✅ Better accuracy in industrial/wild environments
- ✅ Handles rotated and skewed text
- ✅ Multi-language support
- ✅ Faster processing
- ✅ Better bounding box detection

### Frame Extraction Strategy

- Extract 1 frame every 30 frames (1 fps at 30fps video)
- Saves frames as JPEG for efficient storage
- Organized by job_id for easy cleanup

### Database Schema

**video_jobs**
- job_id, video_name, status, progress
- total_frames, processed_frames, detections_count
- timestamps (created, started, completed)

**detections**
- frame_number, timestamp, detected_text
- confidence, bounding_box coordinates
- frame_path for visual reference

## 🐛 Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose logs -f

# Restart services
docker-compose restart

# Rebuild if needed
docker-compose up -d --build
```

### Worker not processing
```bash
# Check Redis connection
docker-compose exec redis redis-cli ping

# Check worker logs
docker-compose logs -f worker
```

### Database errors
```bash
# Reset database
docker-compose down -v
docker-compose up -d
```

### Low detection accuracy
- Increase video quality
- Adjust FRAME_INTERVAL (lower = more frames)
- Lower confidence threshold in UI
- Check lighting conditions in video

## 📈 Performance

### Benchmarks (on 4-core CPU, 8GB RAM)

- **Upload**: ~10 MB/s
- **Frame Extraction**: ~30 fps
- **OCR Processing**: ~2-3 seconds per frame
- **Total**: ~5-10 minutes for 1-minute video (30 frames)

### Optimization Tips

1. **Increase FRAME_INTERVAL** for faster processing (less accuracy)
2. **Use GPU** for PaddleOCR (edit `worker/processor.py`)
3. **Scale workers** with `docker-compose up -d --scale worker=3`
4. **Increase RAM** for larger videos

## 🔐 Security Considerations

- [ ] Add authentication (JWT tokens)
- [ ] Implement rate limiting
- [ ] Validate file types server-side
- [ ] Sanitize file names
- [ ] Add HTTPS in production
- [ ] Implement user quotas

## 🚀 Production Deployment

### Recommended Changes

1. **Use managed services**
   - AWS RDS for PostgreSQL
   - AWS ElastiCache for Redis
   - AWS S3 for video storage

2. **Add monitoring**
   - Prometheus + Grafana
   - Sentry for error tracking
   - CloudWatch logs

3. **Scale horizontally**
   - Multiple worker instances
   - Load balancer for API
   - CDN for frontend

4. **Security hardening**
   - Enable HTTPS
   - Add authentication
   - Implement CORS properly
   - Use secrets management

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Support

For issues and questions:
- GitHub Issues: [repository-url]/issues
- Email: support@example.com

## 🎉 Acknowledgments

- PaddleOCR team for the excellent OCR engine
- Streamlit for the amazing UI framework
- FastAPI for the modern API framework

---

**Built with ❤️ for industrial automation**
