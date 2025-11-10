from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.db.database import engine, Base
from app.api import auth, users, practice, groups, posts, achievements

# 데이터베이스 테이블 생성
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="PerformProject API",
    description="악기 연주자 연습 기록 서비스 API",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API 라우터 등록
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(practice.router, prefix="/api/practice", tags=["practice"])
app.include_router(groups.router, prefix="/api/groups", tags=["groups"])
app.include_router(posts.router, prefix="/api/posts", tags=["posts"])
app.include_router(achievements.router, prefix="/api/achievements", tags=["achievements"])

@app.get("/")
async def root():
    return {"message": "PerformProject API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

