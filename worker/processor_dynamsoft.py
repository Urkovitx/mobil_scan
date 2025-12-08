"""
Video Processor Worker - Mobile Industrial Scanner
WITH DYNAMSOFT BARCODE READER (PROFESSIONAL)
Extracts frames from videos and detects barcodes using YOLOv8 + Dynamsoft
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

# YOLOv8 and Supervision imports
try:
    from ultralytics import YOLO
    import supervision as sv
    HAVE_YOLO = True
except ImportError as e:
    logger.warning(f"⚠️ YOLO import error: {e}")
    HAVE_YOLO = False

# Dynamsoft Barcode Reader
try:
    from dbr import BarcodeReader
    HAVE_DYNAMSOFT = True
    logger.info("✅ Dynamsoft Barcode Reader imported successfully")
except ImportError as e:
    logger.warning(f"⚠️ Dynamsoft import error: {e}")
    HAVE_DYNAMSOFT = False

# Import database
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
try:
    from shared.database import SessionLocal, Detection, VideoJob
except ImportError:
    # Fallback for local execution
    sys.path.append('../shared')
    from database import SessionLocal, Detection, VideoJob

# Configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
VIDEOS_FOLDER = os.getenv("VIDEOS_FOLDER", "./videos")
FRAMES_FOLDER = os.getenv("FRAMES_FOLDER", "./frames")
RESULTS_FOLDER = os.getenv("RESULTS_FOLDER", "./results")
FRAME_INTERVAL = int(os.getenv("FRAME_INTERVAL", "30"))  # Extract 1 frame every N frames
MODEL_PATH = os.getenv("MODEL_PATH", "/app/models/best_barcode_model.pt")

# Dynamsoft License
DYNAMSOFT_LICENSE = os.getenv("DYNAMSOFT_LICENSE", "t0087YQEAAAo+62EJwjM/Ii+Bb6cm32Kz/IbSOfahkv3f1xUKOznl1gmVl9l/JhhxzFiQAi0iH9QNJTVsUKnrBdQrUFRfrwPtBzN+NLmbxnszJxU38xXaKEmc")

# Ensure folders exist
os.makedirs(FRAMES_FOLDER, exist_ok=True)
os.makedirs(RESULTS_FOLDER, exist_ok=True)

# Initialize YOLO model
yolo_model = None
box_annotator = None
label_annotator = None

if HAVE_YOLO:
    try:
        # Check if model exists
        if os.path.exists(MODEL_PATH):
            yolo_model = YOLO(MODEL_PATH)
            logger.info(f"✅ YOLOv8 model loaded from: {MODEL_PATH}")
        else:
            logger.warning(f"⚠️ Model not found at {MODEL_PATH}, using default YOLOv8n")
            yolo_model = YOLO('yolov8n.pt')  # Fallback to default model
        
        # Initialize Supervision annotators
        box_annotator = sv.BoxAnnotator(
            thickness=2,
            text_thickness=1,
            text_scale=0.5
        )
        label_annotator = sv.LabelAnnotator(
            text_thickness=1,
            text_scale=0.5,
            text_padding=5
        )
        
        logger.info("✅ Supervision annotators initialized")
        
    except Exception as e:
        logger.error(f"❌ Failed to initialize YOLO: {e}")
        yolo_model = None
else:
    logger.error("❌ YOLOv8 not available")

# Initialize Dynamsoft Barcode Reader
dynamsoft_reader = None

if HAVE_DYNAMSOFT:
    try:
        # Initialize with license
        BarcodeReader.init_license(DYNAMSOFT_LICENSE)
        dynamsoft_reader = BarcodeReader()
        
        # Configure settings for optimal performance
        settings = dynamsoft_reader.get_runtime_settings()
        
        # Enable all barcode formats
        settings.barcode_format_ids = 0x7FFFFFFF  # All 1D formats
        settings.barcode_format_ids_2 = 0x3FFFFFF  # All 2D formats
        
        # Optimize for speed and accuracy
        settings.expected_barcodes_count = 10  # Expect up to 10 barcodes per image
        settings.timeout = 5000  # 5 seconds timeout
        settings.scale_down_threshold = 2300  # Scale down large images
        
        # Localization modes (how to find barcodes)
        settings.localization_modes[0] = 1  # Connected blocks
        settings.localization_modes[1] = 2  # Statistics
        settings.localization_modes[2] = 4  # Lines
        settings.localization_modes[3] = 8  # Scan directly
        
        # Deblur modes (handle blurry images)
        settings.deblur_modes[0] = 1  # Direct binarization
        settings.deblur_modes[1] = 2  # Threshold binarization
        settings.deblur_modes[2] = 4  # Gray equalization
        settings.deblur_modes[3] = 8  # Smoothing
        settings.deblur_modes[4] = 16  # Morphing
        
        # Apply settings
        dynamsoft_reader.update_runtime_settings(settings)
        
        logger.info("✅ Dynamsoft Barcode Reader initialized with optimized settings")
        logger.info(f"📜 License: {DYNAMSOFT_LICENSE[:20]}...")
        
    except Exception as e:
        logger.error(f"❌ Failed to initialize Dynamsoft: {e}")
        dynamsoft_reader = None
else:
    logger.error("❌ Dynamsoft Barcode Reader not available")


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


def decode_barcode_dynamsoft(crop):
    """
    Decode barcode using Dynamsoft Barcode Reader (PROFESSIONAL)
    
    Args:
        crop: Cropped image region (numpy array)
        
    Returns:
        list: List of (barcode_text, confidence, format) tuples
    """
    if not dynamsoft_reader:
        logger.warning("⚠️ Dynamsoft not available")
        return []
    
    try:
        # Dynamsoft can handle color images directly
        results = dynamsoft_reader.decode_buffer(crop)
        
        if not results:
            return []
        
        decoded_barcodes = []
        
        for result in results:
            barcode_text = result.barcode_text
            barcode_format = result.barcode_format_string
            
            # Dynamsoft doesn't provide direct confidence, so we calculate it
            # based on barcode characteristics
            confidence = 0.7  # Base confidence (Dynamsoft is very reliable)
            
            # Length bonus
            if len(barcode_text) >= 8:
                confidence += 0.1
            if len(barcode_text) >= 12:
                confidence += 0.1
            
            # Format bonus
            if barcode_format in ['EAN_13', 'EAN_8', 'UPC_A', 'UPC_E']:
                confidence += 0.1
            
            confidence = min(confidence, 1.0)
            
            decoded_barcodes.append((barcode_text, confidence, barcode_format))
            
            logger.info(f"✅ Dynamsoft decoded: {barcode_text} (format: {barcode_format}, confidence: {confidence:.2f})")
        
        return decoded_barcodes
        
    except Exception as e:
        logger.error(f"❌ Dynamsoft decode error: {e}")
        return []


def detect_and_decode_barcodes(frame, frame_path: str, job_id: str, frame_number: int):
    """
    Detect barcodes using YOLOv8 and decode using Dynamsoft
    
    Args:
        frame: OpenCV image (numpy array)
        frame_path: Path where frame is saved
        job_id: Job identifier for saving annotated frames
        frame_number: Frame number for naming
        
    Returns:
        list: List of detections with text, confidence, and bounding boxes
    """
    if not yolo_model or not dynamsoft_reader:
        logger.warning("⚠️ YOLO or Dynamsoft not available")
        return []
    
    try:
        # Run YOLO detection
        results = yolo_model(
            frame,
            conf=0.25,  # Lower threshold to detect more
            iou=0.45,   # IoU threshold for NMS
            max_det=10,  # Maximum detections per image
            verbose=False
        )[0]
        
        # Convert to Supervision Detections
        detections = sv.Detections.from_ultralytics(results)
        
        if len(detections) == 0:
            return []
        
        decoded_detections = []
        labels = []
        
        # Iterate over each detection
        for i in range(len(detections)):
            # Get bounding box coordinates
            x1, y1, x2, y2 = detections.xyxy[i].astype(int)
            yolo_confidence = detections.confidence[i]
            
            # Skip low confidence detections
            if yolo_confidence < 0.3:
                logger.debug(f"⏭️ Skipping low confidence detection: {yolo_confidence:.2f}")
                continue
            
            # Ensure coordinates are within frame bounds
            x1 = max(0, x1)
            y1 = max(0, y1)
            x2 = min(frame.shape[1], x2)
            y2 = min(frame.shape[0], y2)
            
            # Add padding to crop
            padding = 10
            x1 = max(0, x1 - padding)
            y1 = max(0, y1 - padding)
            x2 = min(frame.shape[1], x2 + padding)
            y2 = min(frame.shape[0], y2 + padding)
            
            # Crop the detected region
            crop = frame[y1:y2, x1:x2]
            
            # Skip too small crops
            if crop.shape[0] < 20 or crop.shape[1] < 20:
                logger.warning(f"⚠️ Crop too small: {crop.shape}, skipping")
                continue
            
            # Decode with Dynamsoft (PROFESSIONAL)
            dynamsoft_results = decode_barcode_dynamsoft(crop)
            
            if dynamsoft_results:
                for barcode_text, decode_confidence, barcode_format in dynamsoft_results:
                    # Combine YOLO + Dynamsoft confidence
                    final_confidence = (yolo_confidence + decode_confidence) / 2.0
                    
                    logger.info(f"✅ Frame {frame_number}: {barcode_text} "
                               f"(format: {barcode_format}, "
                               f"YOLO: {yolo_confidence:.2f}, "
                               f"Dynamsoft: {decode_confidence:.2f}, "
                               f"Final: {final_confidence:.2f})")
                    
                    # Create label for annotation
                    label = f"{barcode_text} [{barcode_format}] {final_confidence:.2f}"
                    labels.append(label)
                    
                    # Store detection
                    decoded_detections.append({
                        'text': barcode_text,
                        'confidence': float(final_confidence),
                        'bbox': (int(x1), int(y1), int(x2), int(y2)),
                        'yolo_confidence': float(yolo_confidence),
                        'decode_confidence': float(decode_confidence),
                        'format': barcode_format
                    })
            else:
                # No barcode decoded
                label = f"Unreadable {yolo_confidence:.2f}"
                labels.append(label)
                
                logger.warning(f"⚠️ Frame {frame_number}: Unreadable (YOLO: {yolo_confidence:.2f})")
        
        # Annotate frame with detections
        if len(decoded_detections) > 0:
            try:
                # Annotate with boxes
                annotated_frame = box_annotator.annotate(
                    scene=frame.copy(),
                    detections=detections
                )
                
                # Annotate with labels
                annotated_frame = label_annotator.annotate(
                    scene=annotated_frame,
                    detections=detections,
                    labels=labels
                )
                
                # Save annotated frame
                job_results_folder = os.path.join(RESULTS_FOLDER, job_id)
                os.makedirs(job_results_folder, exist_ok=True)
                
                annotated_filename = f"annotated_frame_{frame_number:06d}.jpg"
                annotated_path = os.path.join(job_results_folder, annotated_filename)
                cv2.imwrite(annotated_path, annotated_frame)
                
                logger.info(f"💾 Saved annotated frame: {annotated_filename}")
                
            except Exception as annotate_error:
                logger.error(f"❌ Annotation error: {annotate_error}")
        
        return decoded_detections
        
    except Exception as e:
        logger.error(f"❌ Detection/decoding error: {e}")
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
    
    logger.info(f"🎬 Processing video with DYNAMSOFT: {video_name} (Job: {job_id})")
    
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
        
        # Extract frames and detect barcodes
        total_detections = 0
        processed_frames = 0
        
        for frame_number, timestamp, frame, frame_path in extract_frames(video_path, job_id, FRAME_INTERVAL):
            try:
                # Detect and decode barcodes in frame
                detections = detect_and_decode_barcodes(frame, frame_path, job_id, frame_number)
                
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
                        bbox_y3=det['bbox'][3],
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
        
        logger.info(f"✅ Job {job_id} completed with DYNAMSOFT: {processed_frames} frames, {total_detections} detections")
        
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
    logger.info("🚀 Starting video processor worker with DYNAMSOFT...")
    logger.info(f"📦 YOLO available: {HAVE_YOLO}")
    logger.info(f"📦 Dynamsoft available: {HAVE_DYNAMSOFT}")
    
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
        "worker_dynamsoft.log",
        rotation="100 MB",
        retention="7 days",
        level="INFO"
    )
    
    # Start worker
    worker_loop()
