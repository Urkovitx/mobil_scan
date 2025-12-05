"""
Video Processor Worker - Mobile Industrial Scanner
Extracts frames from videos and detects text using PaddleOCR
"""
import os
import sys
import time
import json
import redis
import cv2
import numpy as np
from datetime import datetime
from pathlib import Path
from loguru import logger
from sqlalchemy.orm import Session

# PaddleOCR import
try:
    from paddleocr import PaddleOCR
    HAVE_PADDLE = True
except ImportError:
    logger.warning("⚠️ PaddleOCR not available")
    HAVE_PADDLE = False

# Import database
sys.path.append('/app')
from database import SessionLocal, Detection, VideoJob

# Configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
VIDEOS_FOLDER = os.getenv("VIDEOS_FOLDER", "./videos")
FRAMES_FOLDER = os.getenv("FRAMES_FOLDER", "./frames")
FRAME_INTERVAL = int(os.getenv("FRAME_INTERVAL", "30"))  # Extract 1 frame every N frames

# Ensure folders exist
os.makedirs(FRAMES_FOLDER, exist_ok=True)

# Initialize PaddleOCR
if HAVE_PADDLE:
    try:
        ocr_engine = PaddleOCR(
            use_angle_cls=True,
            lang='en',
            use_gpu=False,  # Set to True if GPU available
            show_log=False
        )
        logger.info("✅ PaddleOCR initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize PaddleOCR: {e}")
        ocr_engine = None
else:
    ocr_engine = None


def extract_frames(video_path: str, job_id: str, frame_interval: int = 30):
    """
    Extract frames from video at specified interval
    
    Args:
        video_path: Path to video file
        job_id: Unique job identifier
        frame_interval: Extract 1 frame every N frames
        
    Yields:
        tuple: (frame_number, timestamp, frame_image, frame_path)
    """
    try:
        cap = cv2.VideoCapture(video_path)
        
        if not cap.isOpened():
            raise Exception(f"Failed to open video: {video_path}")
        
        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        logger.info(f"📹 Video info: {total_frames} frames, {fps:.2f} FPS")
        
        frame_number = 0
        extracted_count = 0
        
        # Create job-specific folder for frames
        job_frames_folder = os.path.join(FRAMES_FOLDER, job_id)
        os.makedirs(job_frames_folder, exist_ok=True)
        
        while True:
            ret, frame = cap.read()
            
            if not ret:
                break
            
            # Extract frame at interval
            if frame_number % frame_interval == 0:
                timestamp = frame_number / fps
                
                # Save frame
                frame_filename = f"frame_{frame_number:06d}.jpg"
                frame_path = os.path.join(job_frames_folder, frame_filename)
                cv2.imwrite(frame_path, frame)
                
                extracted_count += 1
                yield (frame_number, timestamp, frame, frame_path)
            
            frame_number += 1
        
        cap.release()
        logger.info(f"✅ Extracted {extracted_count} frames from {total_frames} total frames")
        
    except Exception as e:
        logger.error(f"❌ Error extracting frames: {e}")
        raise


def detect_text_paddleocr(frame, frame_path: str):
    """
    Detect text in frame using PaddleOCR
    
    Args:
        frame: OpenCV image (numpy array)
        frame_path: Path where frame is saved
        
    Returns:
        list: List of detections with text, confidence, and bounding boxes
    """
    if not ocr_engine:
        logger.warning("⚠️ OCR engine not available")
        return []
    
    try:
        # Run OCR
        result = ocr_engine.ocr(frame, cls=True)
        
        if not result or not result[0]:
            return []
        
        detections = []
        
        for line in result[0]:
            # Extract bounding box and text
            bbox = line[0]  # [[x1,y1], [x2,y2], [x3,y3], [x4,y4]]
            text_info = line[1]  # (text, confidence)
            
            text = text_info[0]
            confidence = text_info[1]
            
            # Convert bbox to simple format (x1, y1, x2, y2)
            x_coords = [point[0] for point in bbox]
            y_coords = [point[1] for point in bbox]
            
            x1, y1 = int(min(x_coords)), int(min(y_coords))
            x2, y2 = int(max(x_coords)), int(max(y_coords))
            
            detections.append({
                'text': text,
                'confidence': float(confidence),
                'bbox': (x1, y1, x2, y2)
            })
        
        return detections
        
    except Exception as e:
        logger.error(f"❌ OCR error: {e}")
        return []


def process_video(job_data: dict):
    """
    Main video processing function
    
    Args:
        job_data: Dictionary with job_id, video_path, video_name
    """
    job_id = job_data['job_id']
    video_path = job_data['video_path']
    video_name = job_data['video_name']
    
    logger.info(f"🎬 Processing video: {video_name} (Job: {job_id})")
    
    # Get database session
    db = SessionLocal()
    
    try:
        # Update job status to processing
        job = db.query(VideoJob).filter(VideoJob.job_id == job_id).first()
        if not job:
            logger.error(f"❌ Job {job_id} not found in database")
            return
        
        job.status = "processing"
        job.started_at = datetime.utcnow()
        db.commit()
        
        # Extract frames and detect text
        total_detections = 0
        processed_frames = 0
        
        for frame_number, timestamp, frame, frame_path in extract_frames(video_path, job_id, FRAME_INTERVAL):
            try:
                # Detect text in frame
                detections = detect_text_paddleocr(frame, frame_path)
                
                # Save detections to database
                for det in detections:
                    detection = Detection(
                        video_name=video_name,
                        job_id=job_id,
                        frame_number=frame_number,
                        timestamp=timestamp,
                        detected_text=det['text'],
                        confidence=det['confidence'],
                        bbox_x1=det['bbox'][0],
                        bbox_y1=det['bbox'][1],
                        bbox_x2=det['bbox'][2],
                        bbox_y2=det['bbox'][3],
                        frame_path=frame_path
                    )
                    db.add(detection)
                    total_detections += 1
                
                processed_frames += 1
                
                # Commit every 10 frames
                if processed_frames % 10 == 0:
                    db.commit()
                    job.processed_frames = processed_frames
                    job.detections_count = total_detections
                    db.commit()
                    logger.info(f"📊 Progress: {processed_frames} frames, {total_detections} detections")
                
            except Exception as e:
                logger.error(f"❌ Error processing frame {frame_number}: {e}")
                continue
        
        # Final commit
        db.commit()
        
        # Update job as completed
        job.status = "completed"
        job.completed_at = datetime.utcnow()
        job.processed_frames = processed_frames
        job.detections_count = total_detections
        
        # Calculate total frames
        cap = cv2.VideoCapture(video_path)
        job.total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        cap.release()
        
        db.commit()
        
        logger.info(f"✅ Job {job_id} completed: {processed_frames} frames, {total_detections} detections")
        
    except Exception as e:
        logger.error(f"❌ Error processing video: {e}")
        
        # Update job as failed
        try:
            job = db.query(VideoJob).filter(VideoJob.job_id == job_id).first()
            if job:
                job.status = "failed"
                job.error_message = str(e)
                job.completed_at = datetime.utcnow()
                db.commit()
        except Exception as db_error:
            logger.error(f"❌ Failed to update job status: {db_error}")
    
    finally:
        db.close()


def worker_loop():
    """
    Main worker loop - listens to Redis queue and processes videos
    """
    logger.info("🚀 Starting video processor worker...")
    
    # Connect to Redis
    try:
        redis_client = redis.from_url(REDIS_URL, decode_responses=True)
        redis_client.ping()
        logger.info(f"✅ Connected to Redis: {REDIS_URL}")
    except Exception as e:
        logger.error(f"❌ Failed to connect to Redis: {e}")
        return
    
    logger.info("👂 Listening for jobs on 'video_queue'...")
    
    while True:
        try:
            # Blocking pop from queue (timeout 1 second)
            result = redis_client.brpop("video_queue", timeout=1)
            
            if result:
                queue_name, job_json = result
                job_data = json.loads(job_json)
                
                logger.info(f"📥 Received job: {job_data['job_id']}")
                
                # Process video
                process_video(job_data)
            
        except KeyboardInterrupt:
            logger.info("⚠️ Worker interrupted by user")
            break
        except Exception as e:
            logger.error(f"❌ Worker error: {e}")
            time.sleep(5)  # Wait before retrying


if __name__ == "__main__":
    # Configure logging
    logger.add(
        "worker.log",
        rotation="100 MB",
        retention="7 days",
        level="INFO"
    )
    
    # Start worker
    worker_loop()
