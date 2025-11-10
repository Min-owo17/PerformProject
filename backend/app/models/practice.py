from sqlalchemy import Column, Integer, String, Date, DateTime, BigInteger, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class PracticeSession(Base):
    __tablename__ = "practice_sessions"
    
    session_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    practice_date = Column(Date, nullable=False, index=True)
    start_time = Column(DateTime(timezone=True), nullable=True)
    end_time = Column(DateTime(timezone=True), nullable=True)
    actual_play_time = Column(Integer, default=0)  # seconds
    instrument = Column(String(100), nullable=True, index=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="practice_sessions")
    recording_files = relationship("RecordingFile", back_populates="session", cascade="all, delete-orphan")

class RecordingFile(Base):
    __tablename__ = "recording_files"
    
    recording_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("practice_sessions.session_id", ondelete="CASCADE"), nullable=False, index=True)
    file_path = Column(String(500), nullable=True)
    file_size = Column(BigInteger, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    session = relationship("PracticeSession", back_populates="recording_files")

