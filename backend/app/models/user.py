from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ARRAY, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class User(Base):
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=True)
    nickname = Column(String(100), nullable=False, index=True)
    profile_image_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    social_accounts = relationship("SocialAccount", back_populates="user", cascade="all, delete-orphan")
    practice_sessions = relationship("PracticeSession", back_populates="user", cascade="all, delete-orphan")
    groups_owned = relationship("Group", back_populates="owner", cascade="all, delete-orphan")
    group_memberships = relationship("GroupMember", back_populates="user", cascade="all, delete-orphan")
    posts = relationship("Post", back_populates="user", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="user", cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")

class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    profile_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), unique=True, nullable=False)
    instruments = Column(ARRAY(Text), nullable=True)
    user_type = Column(String(50), nullable=True)
    bio = Column(Text, nullable=True)
    hashtags = Column(ARRAY(Text), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="profile")

class SocialAccount(Base):
    __tablename__ = "social_accounts"
    
    social_account_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    provider = Column(String(50), nullable=False)  # 'google', 'kakao', 'naver'
    provider_user_id = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="social_accounts")
    
    __table_args__ = (
        UniqueConstraint("provider", "provider_user_id", name="uq_provider_user_id"),
    )

