"""
Video Processor Worker with LLM Integration
Extracts frames, detects barcodes using YOLOv8 + zxing-cpp, and queries LLM for product info
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
from sqlalchemy import text

# YOLOv8 and Supervision imports
try:
    from ultralytics import YOLO
    import supervision as sv
    import zxingcpp
    HAVE_YOLO = True
    HAVE_ZXING = True
except ImportError as e:
    logger.warning(f"⚠️ Import error: {e}")
    HAVE_YOLO = False
    HAVE_ZXING = False

# Import database and LLM client
sys.path.append('/app')
from database import SessionLocal, Detection, VideoJob
from llm_client import LLMClient

# Configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
LLM_URL = os.getenv("LLM_URL", "http://llm:11434")
VIDEOS_FOLDER = os.getenv("VIDEOS_FOLDER", "./videos")
FRAMES_FOLDER = os.getenv("FRAMES_FOLDER", "./frames")
RESULTS_FOLDER = os.getenv("RESULTS_FOLDER", "./results")
FRAME_INTERVAL = int(os.getenv("FRAME_INTERVAL", "30"))
MODEL_PATH = os.getenv("MODEL_PATH", "/app/models/best_barcode_model.pt")

# Ensure folders exist
os.makedirs(FRAMES_FOLDER, exist_ok=True)
os.makedirs(RESULTS_FOLDER, exist_ok=True)

# Initialize LLM client
llm_client = LLMClient(base_url=LLM_URL)
logger.info(f"🧠 LLM Client initialized: {LLM_URL}")

# Initialize YOLO model
yolo_model = None
box_annotator = None
label_annotator = None

if HAVE_YOLO:
    try:
        if os.path.exists(MODEL_PATH):
            yolo_model = YOLO(MODEL_PATH)
            logger.info(f"✅ YOLOv8 model loaded from: {MODEL_PATH}")
        else:
            logger.warning(f"⚠️ Model not found at {MODEL_PATH}, using default YOLOv8n")
            yolo_model = YOLO('yolov8n.pt')
        
        box_annotator = sv.BoxAnnotator(thickness=2, text_thickness=1, text_scale=0.5)
        label_annotator = sv.LabelAnnotator(text_thickness=1, text_scale=0.5, text_padding=5)
        
        logger.info("✅ Supervision annotators initialized")
        
    except Exception as e:
        logger.error(f"❌ Failed to initialize YOLO: {e}")
        yolo_model = None
else:
    logger.error("❌ YOLOv8 not available")


def get_product_info(db: Session, barcode: str) -> dict:
    """
    Query database for product information by barcode
    
    Args:
        db: Database session
        barcode: Barcode string
        
    Returns:
        dict: Product information or None
    """
    try:
        query = text("""
            SELECT 
                barcode,
                name,
                description,
                category,
                price,
                stock,
                manufacturer
            FROM products
            WHERE barcode = :barcode
            LIMIT 1
        """)
        
        result = db.execute(query, {"barcode": barcode}).fetchone()
        
        if result:
            return {
                "barcode": result[0],
                "name": result[1],
                "description": result[2],
                "category": result[3],
                "price": float(result[4]) if result[4] else 0,
                "stock": result[5],
                "manufacturer": result[6]
            }
        else:
            logger.warning(f"⚠️ Product not found for barcode: {barcode}")
            return None
            
    except Exception as e:
        logger.error(f"❌ Error querying product: {e}")
        return None


def query_llm_about_product(product_info: dict, barcode: str) -> str:
    """
    Query LLM for natural language response about product
    
    Args:
        product_info: Product data dictionary
        barcode: Barcode string
        
    Returns:
        str: LLM response or fallback message
    """
    try:
        if not product_info:
            return f"❌ Producte amb codi {barcode} no trobat a la base de dades"
        
        # Check if LLM is available
        if not llm_client.is_available():
            logger.warning("⚠️ LLM not available, using fallback")
            return llm_client._fallback_response(product_info)
        
        # Query LLM
        logger.info(f"🧠 Querying LLM about product: {product_info.get('name')}")
        
        response = llm_client.consultar_llm(
            product_info=product_info,
            user_question="Proporciona informació útil sobre aquest producte"
        )
        
        return response
        
    except Exception as e:
        logger.error(f"❌ Error querying LLM: {e}")
        if product_info:
            return llm_client._fallback_response(product_info)
        return f"Error processant informació del producte"


def extract_frames(video_path: str, job_id: str, frame_interval: int = 30):
    """Extract frames from video at specified interval"""
    try:
        cap = cv2.VideoCapture(video_path)
        
        if not cap.isOpened():
            raise Exception(f"Failed to open video: {video_path}")
        
        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        logger.info(f"📹 Video info: {total_frames} frames, {fps:.2f} FPS")
        
        frame_number = 0
        extracted_count = 0
        
        job_frames_folder = os.path.join(FRAMES_FOLDER, job_id)
        os.makedirs(job_frames_folder, exist_ok=True)
        
        while True:
            ret, frame = cap.read()
            
            if not ret:
                break
            
            if frame_number % frame_interval == 0:
                timestamp = frame_number / fps
                
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


def detect_and_decode_barcodes(frame, frame_path: str, job_id: str, frame_number: int, db: Session):
    """
    Detect barcodes using YOLOv8, decode with zxing-cpp, and query LLM for product info
    
    Args:
        frame: OpenCV image
        frame_path: Path where frame is saved
        job_id: Job identifier
        frame_number: Frame number
        db: Database session for product queries
        
    Returns:
        list: List of detections with text, confidence, bbox, and LLM response
    """
    if not yolo_model or not HAVE_ZXING:
        logger.warning("⚠️ YOLO or zxing-cpp not available")
        return []
    
    try:
        # Run YOLO detection
        results = yolo_model(frame, verbose=False)[0]
        detections = sv.Detections.from_ultralytics(results)
        
        if len(detections) == 0:
            return []
        
        decoded_detections = []
        labels = []
        
        for i in range(len(detections)):
            x1, y1, x2, y2 = detections.xyxy[i].astype(int)
            confidence = detections.confidence[i]
            
            x1 = max(0, x1)
            y1 = max(0, y1)
            x2 = min(frame.shape[1], x2)
            y2 = min(frame.shape[0], y2)
            
            crop = frame[y1:y2, x1:x2]
            
            barcode_text = "Unreadable"
            llm_response = ""
            
            try:
                barcodes = zxingcpp.read_barcodes(crop)
                
                if barcodes and len(barcodes) > 0:
                    barcode_text = barcodes[0].text
                    logger.info(f"✅ Decoded barcode: {barcode_text}")
                    
                    # Query database for product info
                    product_info = get_product_info(db, barcode_text)
                    
                    if product_info:
                        # Query LLM for natural language response
                        llm_response = query_llm_about_product(product_info, barcode_text)
                        logger.success(f"🧠 LLM Response: {llm_response[:100]}...")
                    else:
                        llm_response = f"Producte {barcode_text} no trobat a la base de dades"
                else:
                    logger.warning(f"⚠️ Barcode detected but not readable")
                    
            except Exception as decode_error:
                logger.error(f"❌ Decode error: {decode_error}")
            
            label = f"{barcode_text} {confidence:.2f}"
            labels.append(label)
            
            decoded_detections.append({
                'text': barcode_text,
                'confidence': float(confidence),
                'bbox': (int(x1), int(y1), int(x2), int(y2)),
                'llm_response': llm_response
            })
        
        # Annotate frame
        if len(decoded_detections) > 0:
            try:
                annotated_frame = box_annotator.annotate(scene=frame.copy(), detections=detections)
                annotated_frame = label_annotator.annotate(
                    scene=annotated_frame,
                    detections=detections,
                    labels=labels
                )
                
                job_results_folder = os.path.join(RESULTS_FOLDER, job_id)
                os.makedirs(job_results_folder, exist_ok=True)
                
                annotated_filename = f"annotated_frame_{frame_number:06d}.jpg"
                annotated_path = os.path.join(job_results_folder, annotated_filename)
                cv2.imwrite(annotated_path, annotated_frame)
                
                # Save LLM responses to text file
                if any(d['llm_response'] for d in decoded_detections):
                    llm_filename = f"llm_response_{frame_number:06d}.txt"
                    llm_path = os.path.join(job_results_folder, llm_filename)
                    
                    with open(llm_path, 'w', encoding='utf-8') as f:
                        for det in decoded_detections:
                            if det['llm_response']:
                                f.write(f"Barcode: {det['text']}\n")
                                f.write(f"LLM Response:\n{det['llm_response']}\n")
                                f.write("-" * 80 + "\n\n")
                
                logger.info(f"💾 Saved annotated frame and LLM responses")
                
            except Exception as annotate_error:
                logger.error(f"❌ Annotation error: {annotate_error}")
        
        return decoded_detections
        
    except Exception as e:
        logger.error(f"❌ Detection/decoding error: {e}")
        return []


def process_video(job_data: dict):
    """Main video processing function with LLM integration"""
    job_id = job_data['job_id']
    video_path = job_data['video_path']
    video_name = job_data['video_name']
    
    logger.info(f"🎬 Processing video with LLM: {video_name} (Job: {job_id})")
    
    db = SessionLocal()
    
    try:
        job = db.query(VideoJob).filter(VideoJob.job_id == job_id).first()
        if not job:
            logger.error(f"❌ Job {job_id} not found")
            return
        
        job.status = "processing"
        job.started_at = datetime.utcnow()
        db.commit()
        
        total_detections = 0
        processed_frames = 0
        
        for frame_number, timestamp, frame, frame_path in extract_frames(video_path, job_id, FRAME_INTERVAL):
            try:
                # Detect, decode, and query LLM
                detections = detect_and_decode_barcodes(frame, frame_path, job_id, frame_number, db)
                
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
                
                if processed_frames % 10 == 0:
                    db.commit()
                    job.processed_frames = processed_frames
                    job.detections_count = total_detections
                    db.commit()
                    logger.info(f"📊 Progress: {processed_frames} frames, {total_detections} detections")
                
            except Exception as e:
                logger.error(f"❌ Error processing frame {frame_number}: {e}")
                continue
        
        db.commit()
        
        job.status = "completed"
        job.completed_at = datetime.utcnow()
        job.processed_frames = processed_frames
        job.detections_count = total_detections
        
        cap = cv2.VideoCapture(video_path)
        job.total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        cap.release()
        
        db.commit()
        
        logger.info(f"✅ Job {job_id} completed: {processed_frames} frames, {total_detections} detections")
        
    except Exception as e:
        logger.error(f"❌ Error processing video: {e}")
        
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
    """Main worker loop with LLM support"""
    logger.info("🚀 Starting video processor worker with LLM...")
    logger.info(f"📦 YOLO available: {HAVE_YOLO}")
    logger.info(f"📦 zxing-cpp available: {HAVE_ZXING}")
    logger.info(f"🧠 LLM available: {llm_client.is_available()}")
    
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
            result = redis_client.brpop("video_queue", timeout=1)
            
            if result:
                queue_name, job_json = result
                job_data = json.loads(job_json)
                
                logger.info(f"📥 Received job: {job_data['job_id']}")
                
                process_video(job_data)
            
        except KeyboardInterrupt:
            logger.info("⚠️ Worker interrupted by user")
            break
        except Exception as e:
            logger.error(f"❌ Worker error: {e}")
            time.sleep(5)


if __name__ == "__main__":
    logger.add("worker.log", rotation="100 MB", retention="7 days", level="INFO")
    worker_loop()
