"""
FastAPI Backend - Mobile Industrial Scanner
Handles video uploads and job management
"""
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import os
import uuid
import redis
import json
from datetime import datetime
from loguru import logger

# Import database models
import sys
sys.path.append('/app')
from database import get_db, init_db, Detection, VideoJob

# Configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", "./videos")
FRAMES_FOLDER = os.getenv("FRAMES_FOLDER", "./frames")

# Ensure folders exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(FRAMES_FOLDER, exist_ok=True)

# Initialize FastAPI
app = FastAPI(
    title="Mobile Industrial Scanner API",
    description="API for video upload and text detection",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Redis connection
try:
    redis_client = redis.from_url(REDIS_URL, decode_responses=True)
    redis_client.ping()
    logger.info(f"✅ Connected to Redis: {REDIS_URL}")
except Exception as e:
    logger.error(f"❌ Failed to connect to Redis: {e}")
    redis_client = None


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    logger.info("🚀 Starting Mobile Industrial Scanner API...")
    init_db()
    logger.info("✅ API ready!")


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Mobile Industrial Scanner API",
        "version": "1.0.0",
        "redis_connected": redis_client is not None
    }


@app.post("/upload")
async def upload_video(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Upload a video file for processing
    
    Args:
        file: Video file (MP4, MOV, AVI)
        
    Returns:
        job_id: Unique identifier for tracking the job
    """
    try:
        # Validate file type
        allowed_extensions = ['.mp4', '.mov', '.avi', '.mkv']
        file_ext = os.path.splitext(file.filename)[1].lower()
        
        if file_ext not in allowed_extensions:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Allowed: {', '.join(allowed_extensions)}"
            )
        
        # Generate unique job ID
        job_id = str(uuid.uuid4())
        
        # Save video file
        video_filename = f"{job_id}_{file.filename}"
        video_path = os.path.join(UPLOAD_FOLDER, video_filename)
        
        # Write file to disk
        with open(video_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        file_size_mb = len(content) / (1024 * 1024)
        logger.info(f"📹 Video uploaded: {video_filename} ({file_size_mb:.2f} MB)")
        
        # Create job record in database
        video_job = VideoJob(
            job_id=job_id,
            video_name=file.filename,
            video_path=video_path,
            status="pending"
        )
        db.add(video_job)
        db.commit()
        db.refresh(video_job)
        
        # Push job to Redis queue
        if redis_client:
            job_data = {
                "job_id": job_id,
                "video_path": video_path,
                "video_name": file.filename
            }
            redis_client.lpush("video_queue", json.dumps(job_data))
            logger.info(f"✅ Job {job_id} added to queue")
        else:
            logger.warning("⚠️ Redis not available, job not queued")
        
        return {
            "success": True,
            "job_id": job_id,
            "video_name": file.filename,
            "file_size_mb": round(file_size_mb, 2),
            "status": "queued",
            "message": "Video uploaded successfully and queued for processing"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Upload error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/jobs")
async def list_jobs(
    limit: int = 50,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    List all video processing jobs
    
    Args:
        limit: Maximum number of jobs to return
        status: Filter by status (pending, processing, completed, failed)
    """
    try:
        query = db.query(VideoJob)
        
        if status:
            query = query.filter(VideoJob.status == status)
        
        jobs = query.order_by(VideoJob.created_at.desc()).limit(limit).all()
        
        return {
            "success": True,
            "count": len(jobs),
            "jobs": [
                {
                    "job_id": job.job_id,
                    "video_name": job.video_name,
                    "status": job.status,
                    "total_frames": job.total_frames,
                    "processed_frames": job.processed_frames,
                    "detections_count": job.detections_count,
                    "created_at": job.created_at.isoformat() if job.created_at else None,
                    "started_at": job.started_at.isoformat() if job.started_at else None,
                    "completed_at": job.completed_at.isoformat() if job.completed_at else None,
                    "error_message": job.error_message
                }
                for job in jobs
            ]
        }
    except Exception as e:
        logger.error(f"❌ Error listing jobs: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/job/{job_id}")
async def get_job_status(
    job_id: str,
    db: Session = Depends(get_db)
):
    """
    Get status of a specific job
    """
    try:
        job = db.query(VideoJob).filter(VideoJob.job_id == job_id).first()
        
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")
        
        return {
            "success": True,
            "job": {
                "job_id": job.job_id,
                "video_name": job.video_name,
                "status": job.status,
                "total_frames": job.total_frames,
                "processed_frames": job.processed_frames,
                "detections_count": job.detections_count,
                "progress": (job.processed_frames / job.total_frames * 100) if job.total_frames > 0 else 0,
                "created_at": job.created_at.isoformat() if job.created_at else None,
                "started_at": job.started_at.isoformat() if job.started_at else None,
                "completed_at": job.completed_at.isoformat() if job.completed_at else None,
                "error_message": job.error_message
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error getting job status: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/results/{job_id}")
async def get_results(
    job_id: str,
    limit: int = 1000,
    min_confidence: float = 0.0,
    db: Session = Depends(get_db)
):
    """
    Get detection results for a specific job
    
    Args:
        job_id: Job identifier
        limit: Maximum number of results
        min_confidence: Minimum confidence threshold (0.0 to 1.0)
    """
    try:
        # Check if job exists
        job = db.query(VideoJob).filter(VideoJob.job_id == job_id).first()
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")
        
        # Get detections
        detections = db.query(Detection)\
            .filter(Detection.job_id == job_id)\
            .filter(Detection.confidence >= min_confidence)\
            .order_by(Detection.frame_number)\
            .limit(limit)\
            .all()
        
        return {
            "success": True,
            "job_id": job_id,
            "video_name": job.video_name,
            "job_status": job.status,
            "total_detections": len(detections),
            "detections": [
                {
                    "id": det.id,
                    "frame_number": det.frame_number,
                    "timestamp": det.timestamp,
                    "detected_text": det.detected_text,
                    "confidence": det.confidence,
                    "bbox": {
                        "x1": det.bbox_x1,
                        "y1": det.bbox_y1,
                        "x2": det.bbox_x2,
                        "y2": det.bbox_y2
                    } if det.bbox_x1 is not None else None,
                    "frame_path": det.frame_path
                }
                for det in detections
            ]
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error getting results: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """
    Get overall system statistics
    """
    try:
        total_jobs = db.query(VideoJob).count()
        completed_jobs = db.query(VideoJob).filter(VideoJob.status == "completed").count()
        failed_jobs = db.query(VideoJob).filter(VideoJob.status == "failed").count()
        processing_jobs = db.query(VideoJob).filter(VideoJob.status == "processing").count()
        pending_jobs = db.query(VideoJob).filter(VideoJob.status == "pending").count()
        total_detections = db.query(Detection).count()
        
        return {
            "success": True,
            "stats": {
                "total_jobs": total_jobs,
                "completed_jobs": completed_jobs,
                "failed_jobs": failed_jobs,
                "processing_jobs": processing_jobs,
                "pending_jobs": pending_jobs,
                "total_detections": total_detections,
                "avg_detections_per_job": round(total_detections / total_jobs, 2) if total_jobs > 0 else 0
            }
        }
    except Exception as e:
        logger.error(f"❌ Error getting stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
