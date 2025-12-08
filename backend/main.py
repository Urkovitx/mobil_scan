"""
FastAPI Backend - Mobile Industrial Scanner
Handles video uploads and job management
"""
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
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

# Google Gemini for AI analysis
try:
    import google.generativeai as genai
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        gemini_model = genai.GenerativeModel('gemini-pro')
        logger.info("✅ Gemini AI configured")
    else:
        gemini_model = None
        logger.warning("⚠️ GEMINI_API_KEY not set, AI features disabled")
except ImportError:
    gemini_model = None
    logger.warning("⚠️ google-generativeai not installed, AI features disabled")

# Google Cloud Run Jobs for worker
try:
    from google.cloud import run_v2
    from google.api_core import exceptions as google_exceptions
    PROJECT_ID = os.getenv("GCP_PROJECT_ID", "mobil-scan-app")
    REGION = os.getenv("GCP_REGION", "europe-west1")
    WORKER_IMAGE = os.getenv("WORKER_IMAGE", f"gcr.io/{PROJECT_ID}/mobil-scan-worker:latest")
    USE_CLOUD_RUN_JOBS = os.getenv("USE_CLOUD_RUN_JOBS", "true").lower() == "true"
    
    if USE_CLOUD_RUN_JOBS:
        jobs_client = run_v2.JobsClient()
        logger.info("✅ Cloud Run Jobs client configured")
    else:
        jobs_client = None
        logger.info("ℹ️ Using Redis queue (Cloud Run Jobs disabled)")
except ImportError:
    jobs_client = None
    USE_CLOUD_RUN_JOBS = False
    logger.warning("⚠️ google-cloud-run not installed, using Redis queue")

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
        
        # Launch Cloud Run Job or push to Redis queue
        if USE_CLOUD_RUN_JOBS and jobs_client:
            try:
                # Create Cloud Run Job execution
                job_name = f"process-video-{job_id[:8]}"
                parent = f"projects/{PROJECT_ID}/locations/{REGION}"
                
                execution_request = run_v2.RunJobRequest(
                    name=f"{parent}/jobs/{job_name}",
                    overrides=run_v2.RunJobRequest.Overrides(
                        container_overrides=[
                            run_v2.RunJobRequest.Overrides.ContainerOverride(
                                env=[
                                    run_v2.EnvVar(name="JOB_ID", value=job_id),
                                    run_v2.EnvVar(name="VIDEO_PATH", value=video_path),
                                    run_v2.EnvVar(name="VIDEO_NAME", value=file.filename),
                                    run_v2.EnvVar(name="REDIS_URL", value=REDIS_URL),
                                    run_v2.EnvVar(name="DATABASE_URL", value=os.getenv("DATABASE_URL")),
                                ]
                            )
                        ]
                    )
                )
                
                operation = jobs_client.run_job(request=execution_request)
                logger.info(f"✅ Cloud Run Job launched: {job_name}")
                
                return {
                    "success": True,
                    "job_id": job_id,
                    "video_name": file.filename,
                    "file_size_mb": round(file_size_mb, 2),
                    "status": "queued",
                    "message": "Video uploaded successfully and Cloud Run Job launched",
                    "worker_type": "cloud_run_job"
                }
                
            except Exception as job_error:
                logger.error(f"❌ Failed to launch Cloud Run Job: {job_error}")
                logger.info("⚠️ Falling back to Redis queue")
                
                # Fallback to Redis
                if redis_client:
                    job_data = {
                        "job_id": job_id,
                        "video_path": video_path,
                        "video_name": file.filename
                    }
                    redis_client.lpush("video_queue", json.dumps(job_data))
                    logger.info(f"✅ Job {job_id} added to Redis queue")
                    
                    return {
                        "success": True,
                        "job_id": job_id,
                        "video_name": file.filename,
                        "file_size_mb": round(file_size_mb, 2),
                        "status": "queued",
                        "message": "Video uploaded successfully and queued for processing (Redis fallback)",
                        "worker_type": "redis_queue"
                    }
                else:
                    raise HTTPException(
                        status_code=503,
                        detail="Worker service unavailable (Cloud Run Job failed and Redis not available)"
                    )
        else:
            # Use Redis queue
            if redis_client:
                job_data = {
                    "job_id": job_id,
                    "video_path": video_path,
                    "video_name": file.filename
                }
                redis_client.lpush("video_queue", json.dumps(job_data))
                logger.info(f"✅ Job {job_id} added to Redis queue")
                
                return {
                    "success": True,
                    "job_id": job_id,
                    "video_name": file.filename,
                    "file_size_mb": round(file_size_mb, 2),
                    "status": "queued",
                    "message": "Video uploaded successfully and queued for processing",
                    "worker_type": "redis_queue"
                }
            else:
                logger.warning("⚠️ Redis not available, job not queued")
                raise HTTPException(
                    status_code=503,
                    detail="Worker service unavailable (Redis not connected)"
                )
        
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


class AIQueryRequest(BaseModel):
    job_id: str
    question: str


@app.post("/ai/analyze")
async def ai_analyze(request: AIQueryRequest, db: Session = Depends(get_db)):
    """
    Analyze barcode detections with AI (Gemini or Ollama)
    
    Args:
        job_id: Job identifier
        question: User's question about the detections
        
    Returns:
        AI-generated response about the barcode detections
    """
    try:
        # Check if AI is available
        if not gemini_model:
            raise HTTPException(
                status_code=503,
                detail="AI service not available. Please configure GEMINI_API_KEY."
            )
        
        # Get job and detections
        job = db.query(VideoJob).filter(VideoJob.job_id == request.job_id).first()
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")
        
        detections = db.query(Detection)\
            .filter(Detection.job_id == request.job_id)\
            .limit(100)\
            .all()
        
        if not detections:
            return {
                "success": True,
                "response": "No s'han trobat deteccions per aquest treball. Puja un vídeo primer per poder analitzar els codis de barres."
            }
        
        # Prepare context for AI
        detection_summary = []
        for det in detections:
            detection_summary.append({
                "text": det.detected_text,
                "confidence": f"{det.confidence*100:.1f}%",
                "frame": det.frame_number
            })
        
        # Build prompt
        prompt = f"""Ets un assistent expert en gestió d'inventari i codis de barres.

CONTEXT:
- Treball: {job.video_name}
- Total deteccions: {len(detections)}
- Codis detectats: {[d['text'] for d in detection_summary[:10]]}

PREGUNTA DE L'USUARI:
{request.question}

Proporciona una resposta útil, clara i en català. Si la pregunta és sobre validació, inventari, ubicació o SKUs, dona consells pràctics."""

        # Query AI
        response = gemini_model.generate_content(prompt)
        
        return {
            "success": True,
            "response": response.text,
            "detections_analyzed": len(detections),
            "ai_provider": "gemini"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ AI analysis error: {e}")
        return {
            "success": False,
            "response": f"Error en l'anàlisi: {str(e)}",
            "ai_provider": "gemini"
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
