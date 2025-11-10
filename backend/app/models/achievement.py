from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Achievement(Base):
    __tablename__ = "achievements"
    
    achievement_id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    condition_type = Column(String(50), nullable=True)  # 'practice_time', 'consecutive_days', 'instrument_count'
    condition_value = Column(Integer, nullable=True)
    icon_url = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class UserAchievement(Base):
    __tablename__ = "user_achievements"
    
    user_achievement_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    achievement_id = Column(Integer, ForeignKey("achievements.achievement_id", ondelete="CASCADE"), nullable=False)
    earned_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="achievements")
    achievement = relationship("Achievement")
    
    __table_args__ = (
        UniqueConstraint("user_id", "achievement_id", name="uq_user_achievement"),
    )

