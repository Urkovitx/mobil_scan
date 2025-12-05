"""
Industrial Video Audit Tool - Frontend
======================================

Modern Streamlit dashboard for video-based inventory auditing.
Displays detected tags in a clean, grid-based "Evidence Gallery".

Author: Senior UX/UI Developer
Version: 2.0.0
"""

import streamlit as st
import requests
import pandas as pd
import time
from datetime import datetime
from io import BytesIO
import os

# ============================================================================
# CONFIGURATION
# ============================================================================

API_URL = os.getenv("API_URL", "http://api:8000")
ALLOWED_VIDEO_FORMATS = ["mp4", "mov", "avi", "mkv"]

# Page configuration
st.set_page_config(
    page_title="Industrial Video Audit Tool",
    page_icon="🎬",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ============================================================================
# CUSTOM CSS
# ============================================================================

st.markdown("""
<style>
    /* Main title styling */
    .main-title {
        font-size: 2.5rem;
        font-weight: 700;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 1rem;
    }
    
    /* Subtitle styling */
    .subtitle {
        font-size: 1.2rem;
        color: #666;
        text-align: center;
        margin-bottom: 2rem;
    }
    
    /* Evidence card styling */
    .evidence-card {
        border: 2px solid #e0e0e0;
        border-radius: 8px;
        padding: 10px;
        margin: 5px;
        background-color: #f9f9f9;
        transition: transform 0.2s;
    }
    
    .evidence-card:hover {
        transform: scale(1.02);
        border-color: #1f77b4;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    /* Tag text styling */
    .tag-text {
        font-size: 1.3rem;
        font-weight: 700;
        color: #2c3e50;
        text-align: center;
        margin-top: 8px;
        font-family: 'Courier New', monospace;
    }
    
    /* Confidence badge */
    .confidence-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 0.85rem;
        font-weight: 600;
        margin-top: 5px;
    }
    
    .confidence-high {
        background-color: #d4edda;
        color: #155724;
    }
    
    .confidence-medium {
        background-color: #fff3cd;
        color: #856404;
    }
    
    .confidence-low {
        background-color: #f8d7da;
        color: #721c24;
    }
    
    /* Metric styling */
    .metric-container {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 10px;
        color: white;
        text-align: center;
    }
    
    /* Status badge */
    .status-badge {
        display: inline-block;
        padding: 8px 16px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.9rem;
    }
    
    .status-processing {
        background-color: #ffc107;
        color: #000;
    }
    
    .status-completed {
        background-color: #28a745;
        color: white;
    }
    
    .status-failed {
        background-color: #dc3545;
        color: white;
    }
</style>
""", unsafe_allow_html=True)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def check_api_health():
    """Check if the API is reachable"""
    try:
        response = requests.get(f"{API_URL}/", timeout=5)
        return response.status_code == 200
    except:
        return False

def upload_video(video_file):
    """Upload video to backend API"""
    try:
        files = {"file": (video_file.name, video_file, video_file.type)}
        response = requests.post(f"{API_URL}/upload", files=files, timeout=30)
        
        if response.status_code == 200:
            return response.json()
        else:
            st.error(f"Upload failed: {response.text}")
            return None
    except Exception as e:
        st.error(f"Error uploading video: {str(e)}")
        return None

def get_job_status(job_id):
    """Get job status from API"""
    try:
        response = requests.get(f"{API_URL}/job/{job_id}", timeout=10)
        if response.status_code == 200:
            return response.json()
        return None
    except:
        return None

def get_job_results(job_id, min_confidence=0.0):
    """Get detection results from API"""
    try:
        response = requests.get(
            f"{API_URL}/results/{job_id}",
            params={"min_confidence": min_confidence},
            timeout=10
        )
        if response.status_code == 200:
            return response.json()
        return None
    except:
        return None

def get_system_stats():
    """Get system statistics from API"""
    try:
        response = requests.get(f"{API_URL}/stats", timeout=5)
        if response.status_code == 200:
            return response.json().get("stats", {})
        return {}
    except:
        return {}

def format_confidence(confidence):
    """Format confidence score with color coding"""
    if confidence >= 0.8:
        badge_class = "confidence-high"
        emoji = "🟢"
    elif confidence >= 0.6:
        badge_class = "confidence-medium"
        emoji = "🟡"
    else:
        badge_class = "confidence-low"
        emoji = "🔴"
    
    return f'<span class="confidence-badge {badge_class}">{emoji} {confidence*100:.1f}%</span>'

def format_timestamp(seconds):
    """Convert seconds to MM:SS format"""
    minutes = int(seconds // 60)
    secs = int(seconds % 60)
    return f"{minutes:02d}:{secs:02d}"

def export_to_csv(detections, video_name):
    """Export detections to CSV"""
    if not detections:
        return None
    
    # Prepare data for CSV
    data = []
    for det in detections:
        data.append({
            "Video": video_name,
            "Frame": det.get("frame_number", "N/A"),
            "Timestamp": format_timestamp(det.get("timestamp", 0)),
            "Detected_Text": det.get("detected_text", ""),
            "Confidence": f"{det.get('confidence', 0)*100:.2f}%",
            "BBox_X1": det.get("bbox", {}).get("x1", ""),
            "BBox_Y1": det.get("bbox", {}).get("y1", ""),
            "BBox_X2": det.get("bbox", {}).get("x2", ""),
            "BBox_Y2": det.get("bbox", {}).get("y2", ""),
        })
    
    df = pd.DataFrame(data)
    return df.to_csv(index=False).encode('utf-8')

# ============================================================================
# MAIN APPLICATION
# ============================================================================

def main():
    """Main application"""
    
    # Header
    st.markdown('<h1 class="main-title">🎬 Industrial Video Audit Tool</h1>', unsafe_allow_html=True)
    st.markdown('<p class="subtitle">AI-Powered Tag Detection for Inventory Management</p>', unsafe_allow_html=True)
    
    # Sidebar
    with st.sidebar:
        st.header("⚙️ System Status")
        
        # API Health Check
        api_healthy = check_api_health()
        if api_healthy:
            st.success("✅ API Connected")
        else:
            st.error("❌ API Offline")
            st.stop()
        
        # System Stats
        stats = get_system_stats()
        if stats:
            st.metric("Total Jobs", stats.get("total_jobs", 0))
            st.metric("Completed", stats.get("completed_jobs", 0))
            st.metric("Total Detections", stats.get("total_detections", 0))
        
        st.divider()
        
        # Settings
        st.header("🎛️ Settings")
        min_confidence = st.slider(
            "Minimum Confidence",
            min_value=0.0,
            max_value=1.0,
            value=0.5,
            step=0.05,
            help="Filter detections below this confidence threshold"
        )
        
        images_per_row = st.select_slider(
            "Images per Row",
            options=[2, 3, 4, 5, 6],
            value=4,
            help="Number of evidence images per row in the gallery"
        )
    
    # Main content tabs
    tab1, tab2, tab3 = st.tabs(["📤 Upload Video", "📊 Audit Dashboard", "📜 Job History"])
    
    # ========================================================================
    # TAB 1: UPLOAD VIDEO
    # ========================================================================
    with tab1:
        st.header("Upload Video for Analysis")
        
        col1, col2 = st.columns([2, 1])
        
        with col1:
            uploaded_file = st.file_uploader(
                "Choose a video file",
                type=ALLOWED_VIDEO_FORMATS,
                help=f"Supported formats: {', '.join(ALLOWED_VIDEO_FORMATS).upper()}"
            )
            
            if uploaded_file:
                st.video(uploaded_file)
                
                # File info
                file_size_mb = uploaded_file.size / (1024 * 1024)
                st.info(f"📁 **{uploaded_file.name}** ({file_size_mb:.2f} MB)")
        
        with col2:
            st.markdown("### 📋 Instructions")
            st.markdown("""
            1. Upload your video file
            2. Click "Process Video"
            3. Wait for analysis
            4. View results in Dashboard
            5. Export data as CSV
            """)
        
        # Process button
        if uploaded_file:
            if st.button("🚀 Process Video", type="primary", use_container_width=True):
                with st.spinner("Uploading video..."):
                    result = upload_video(uploaded_file)
                    
                    if result and result.get("success"):
                        job_id = result.get("job_id")
                        st.session_state.current_job_id = job_id
                        st.session_state.video_name = uploaded_file.name
                        
                        st.success(f"✅ Video uploaded successfully!")
                        st.info(f"🆔 Job ID: `{job_id}`")
                        st.info("📊 Switch to 'Audit Dashboard' tab to view results")
                        
                        # Auto-switch to dashboard tab
                        time.sleep(2)
                        st.rerun()
    
    # ========================================================================
    # TAB 2: AUDIT DASHBOARD
    # ========================================================================
    with tab2:
        st.header("Audit Dashboard")
        
        # Job ID input
        col1, col2 = st.columns([3, 1])
        with col1:
            job_id_input = st.text_input(
                "Job ID",
                value=st.session_state.get("current_job_id", ""),
                placeholder="Enter Job ID or upload a video",
                help="Enter the Job ID from your video upload"
            )
        
        with col2:
            refresh_button = st.button("🔄 Refresh", use_container_width=True)
        
        if job_id_input:
            # Get job status
            job_data = get_job_status(job_id_input)
            
            if job_data and job_data.get("success"):
                job = job_data.get("job", {})
                status = job.get("status", "unknown")
                video_name = job.get("video_name", "Unknown")
                
                # Status badge
                if status == "completed":
                    status_html = '<span class="status-badge status-completed">✅ COMPLETED</span>'
                elif status == "processing":
                    status_html = '<span class="status-badge status-processing">⏳ PROCESSING</span>'
                elif status == "failed":
                    status_html = '<span class="status-badge status-failed">❌ FAILED</span>'
                else:
                    status_html = f'<span class="status-badge">{status.upper()}</span>'
                
                st.markdown(f"### 📹 {video_name} {status_html}", unsafe_allow_html=True)
                
                # Progress bar
                if status == "processing":
                    progress = job.get("progress", 0.0)
                    processed = job.get("processed_frames", 0)
                    total = job.get("total_frames", 0)
                    
                    st.progress(progress / 100.0)
                    st.caption(f"Processing: {processed}/{total} frames ({progress:.1f}%)")
                    
                    # Auto-refresh every 5 seconds
                    st.info("🔄 Auto-refreshing every 5 seconds...")
                    time.sleep(5)
                    st.rerun()
                
                # Get results if completed
                if status == "completed":
                    results_data = get_job_results(job_id_input, min_confidence)
                    
                    if results_data and results_data.get("success"):
                        detections = results_data.get("detections", [])
                        total_detections = results_data.get("total_detections", 0)
                        
                        # ============================================
                        # TOP METRICS ROW
                        # ============================================
                        st.markdown("---")
                        metric_col1, metric_col2, metric_col3 = st.columns(3)
                        
                        with metric_col1:
                            st.metric(
                                "🎞️ Total Frames Scanned",
                                job.get("total_frames", 0),
                                help="Total number of frames extracted from video"
                            )
                        
                        with metric_col2:
                            st.metric(
                                "🏷️ Tags Detected",
                                len(detections),
                                delta=f"{total_detections} total",
                                help=f"Detections with confidence ≥ {min_confidence*100:.0f}%"
                            )
                        
                        with metric_col3:
                            if detections:
                                avg_conf = sum(d.get("confidence", 0) for d in detections) / len(detections)
                                st.metric(
                                    "📊 Average Confidence",
                                    f"{avg_conf*100:.1f}%",
                                    help="Average confidence score of all detections"
                                )
                            else:
                                st.metric("📊 Average Confidence", "N/A")
                        
                        st.markdown("---")
                        
                        # ============================================
                        # EVIDENCE GALLERY
                        # ============================================
                        if detections:
                            st.subheader("🖼️ Evidence Gallery")
                            st.caption(f"Showing {len(detections)} detections (filtered by confidence ≥ {min_confidence*100:.0f}%)")
                            
                            # Export button
                            csv_data = export_to_csv(detections, video_name)
                            if csv_data:
                                st.download_button(
                                    label="📥 Download Results (CSV)",
                                    data=csv_data,
                                    file_name=f"audit_results_{job_id_input}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                                    mime="text/csv",
                                    use_container_width=True
                                )
                            
                            st.markdown("---")
                            
                            # Create grid of evidence cards
                            for i in range(0, len(detections), images_per_row):
                                cols = st.columns(images_per_row)
                                
                                for j, col in enumerate(cols):
                                    idx = i + j
                                    if idx < len(detections):
                                        detection = detections[idx]
                                        
                                        with col:
                                            # Evidence card container
                                            with st.container():
                                                # Frame info
                                                frame_num = detection.get("frame_number", 0)
                                                timestamp = detection.get("timestamp", 0)
                                                confidence = detection.get("confidence", 0)
                                                detected_text = detection.get("detected_text", "")
                                                
                                                # Display frame image (if available)
                                                frame_path = detection.get("frame_path", "")
                                                if frame_path and os.path.exists(frame_path):
                                                    try:
                                                        st.image(
                                                            frame_path,
                                                            use_container_width=True,
                                                            caption=f"Frame {frame_num} @ {format_timestamp(timestamp)}"
                                                        )
                                                    except:
                                                        st.info("🖼️ Image not available")
                                                else:
                                                    # Placeholder if image not available
                                                    st.info(f"📹 Frame {frame_num}\n⏱️ {format_timestamp(timestamp)}")
                                                
                                                # Detected text (big and bold)
                                                st.markdown(
                                                    f'<div class="tag-text">{detected_text}</div>',
                                                    unsafe_allow_html=True
                                                )
                                                
                                                # Confidence badge
                                                st.markdown(
                                                    f'<div style="text-align: center;">{format_confidence(confidence)}</div>',
                                                    unsafe_allow_html=True
                                                )
                                                
                                                # Bounding box info (collapsible)
                                                with st.expander("📐 Details"):
                                                    bbox = detection.get("bbox", {})
                                                    st.caption(f"**Frame:** {frame_num}")
                                                    st.caption(f"**Time:** {format_timestamp(timestamp)}")
                                                    st.caption(f"**BBox:** ({bbox.get('x1', 0)}, {bbox.get('y1', 0)}) → ({bbox.get('x2', 0)}, {bbox.get('y2', 0)})")
                        
                        else:
                            st.warning("⚠️ No detections found with the current confidence threshold.")
                            st.info(f"Try lowering the minimum confidence in the sidebar (currently {min_confidence*100:.0f}%)")
                    
                    else:
                        st.error("❌ Failed to retrieve results")
                
                elif status == "failed":
                    error_msg = job.get("error_message", "Unknown error")
                    st.error(f"❌ Job failed: {error_msg}")
            
            else:
                st.warning("⚠️ Job not found. Please check the Job ID.")
        
        else:
            st.info("👆 Enter a Job ID above or upload a video in the 'Upload Video' tab")
    
    # ========================================================================
    # TAB 3: JOB HISTORY
    # ========================================================================
    with tab3:
        st.header("Job History")
        
        try:
            response = requests.get(f"{API_URL}/jobs", timeout=10)
            if response.status_code == 200:
                jobs_data = response.json()
                if jobs_data.get("success"):
                    jobs = jobs_data.get("jobs", [])
                    
                    if jobs:
                        # Create DataFrame
                        df = pd.DataFrame(jobs)
                        
                        # Format columns
                        if "created_at" in df.columns:
                            df["created_at"] = pd.to_datetime(df["created_at"]).dt.strftime("%Y-%m-%d %H:%M")
                        
                        # Display table
                        st.dataframe(
                            df[[
                                "job_id", "video_name", "status", 
                                "total_frames", "detections_count", 
                                "progress", "created_at"
                            ]],
                            use_container_width=True,
                            hide_index=True
                        )
                        
                        # Quick access
                        st.subheader("Quick Access")
                        selected_job = st.selectbox(
                            "Select a job to view",
                            options=[f"{j['video_name']} ({j['job_id'][:8]}...)" for j in jobs],
                            index=0
                        )
                        
                        if st.button("📊 View Selected Job", use_container_width=True):
                            # Extract job_id from selection
                            job_id = jobs[0]["job_id"]  # Simplified - should parse from selected_job
                            st.session_state.current_job_id = job_id
                            st.info(f"Switched to job: {job_id}")
                            st.rerun()
                    
                    else:
                        st.info("📭 No jobs found. Upload a video to get started!")
            
            else:
                st.error("❌ Failed to retrieve job history")
        
        except Exception as e:
            st.error(f"❌ Error: {str(e)}")

# ============================================================================
# RUN APPLICATION
# ============================================================================

if __name__ == "__main__":
    # Initialize session state
    if "current_job_id" not in st.session_state:
        st.session_state.current_job_id = ""
    if "video_name" not in st.session_state:
        st.session_state.video_name = ""
    
    main()
