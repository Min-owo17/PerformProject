from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Group(Base):
    __tablename__ = "groups"
    
    group_id = Column(Integer, primary_key=True, index=True)
    group_name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    owner_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    is_public = Column(Boolean, default=False)
    max_members = Column(Integer, default=50)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    owner = relationship("User", back_populates="groups_owned")
    members = relationship("GroupMember", back_populates="group", cascade="all, delete-orphan")

class GroupMember(Base):
    __tablename__ = "group_members"
    
    member_id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.group_id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(String(20), default="member")  # 'owner', 'admin', 'member'
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    group = relationship("Group", back_populates="members")
    user = relationship("User", back_populates="group_memberships")
    
    __table_args__ = (
        UniqueConstraint("group_id", "user_id", name="uq_group_user"),
    )

