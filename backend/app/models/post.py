from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, ARRAY, Index
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Post(Base):
    __tablename__ = "posts"
    
    post_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(300), nullable=False)
    content = Column(Text, nullable=False)
    category = Column(String(50), default="general", index=True)  # 'tip', 'question', 'free'
    auto_tags = Column(ARRAY(Text), nullable=True)
    manual_tags = Column(ARRAY(Text), nullable=True)
    view_count = Column(Integer, default=0)
    like_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="posts")
    comments = relationship("Comment", back_populates="post", cascade="all, delete-orphan")
    likes = relationship("PostLike", back_populates="post", cascade="all, delete-orphan")

class Comment(Base):
    __tablename__ = "comments"
    
    comment_id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.post_id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    parent_comment_id = Column(Integer, ForeignKey("comments.comment_id", ondelete="CASCADE"), nullable=True, index=True)
    content = Column(Text, nullable=False)
    like_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    post = relationship("Post", back_populates="comments")
    user = relationship("User", back_populates="comments")
    parent_comment = relationship("Comment", remote_side=[comment_id], backref="replies")
    likes = relationship("CommentLike", back_populates="comment", cascade="all, delete-orphan")

class PostLike(Base):
    __tablename__ = "post_likes"
    
    like_id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.post_id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    post = relationship("Post", back_populates="likes")
    user = relationship("User")
    
    __table_args__ = (
        Index("uq_post_like", "post_id", "user_id", unique=True),
    )

class CommentLike(Base):
    __tablename__ = "comment_likes"
    
    like_id = Column(Integer, primary_key=True, index=True)
    comment_id = Column(Integer, ForeignKey("comments.comment_id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    comment = relationship("Comment", back_populates="likes")
    user = relationship("User")
    
    __table_args__ = (
        Index("uq_comment_like", "comment_id", "user_id", unique=True),
    )

