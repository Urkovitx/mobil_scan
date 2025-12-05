"""
Database Models and Connection
SQLAlchemy setup for storing video processing results
"""
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import os

# Database URL from environment or default to SQLite
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./mobilscan.db"
)

# Create engine
engine = create_engine(
    DATABASE_URL,
    echo=False,
    pool_pre_ping=True,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


class Detection(Base):
    """
    Table to store all text detections from video frames
    """
    __tablename__ = "detections"

    id = Column(Integer, primary_key=True, index=True)
    video_name = Column(String(255), nullable=False, index=True)
    job_id = Column(String(100), nullable=False, index=True)
    frame_number = Column(Integer, nullable=False)
    timestamp = Column(Float, nullable=False)  # Video timestamp in seconds
    detected_text = Column(Text, nullable=False)
    confidence = Column(Float, nullable=False)
    bbox_x1 = Column(Integer)  # Bounding box coordinates
    bbox_y1 = Column(Integer)
    bbox_x2 = Column(Integer)
    bbox_y2 = Column(Integer)
    frame_path = Column(String(500))  # Path to saved frame image
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<Detection(id={self.id}, video={self.video_name}, text='{self.detected_text[:20]}...')>"


class VideoJob(Base):
    """
    Table to track video processing jobs
    """
    __tablename__ = "video_jobs"

    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(String(100), unique=True, nullable=False, index=True)
    video_name = Column(String(255), nullable=False)
    video_path = Column(String(500), nullable=False)
    status = Column(String(50), default="pending")  # pending, processing, completed, failed
    total_frames = Column(Integer, default=0)
    processed_frames = Column(Integer, default=0)
    detections_count = Column(Integer, default=0)
    error_message = Column(Text, nullable=True)
    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<VideoJob(job_id={self.job_id}, status={self.status})>"


def init_db():
    """
    Initialize database - create all tables
    """
    Base.metadata.create_all(bind=engine)
    print("✅ Database initialized successfully")


def get_db():
    """
    Dependency to get database session
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


if __name__ == "__main__":
    # Test database connection
    print("Testing database connection...")
    init_db()
    print("Database tables created successfully!")
