from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.user import User
from app.schemas.auth import Token, UserCreate, UserLogin
from app.services.auth import AuthService

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

@router.post("/register", response_model=Token)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """회원가입"""
    auth_service = AuthService(db)
    return await auth_service.register(user_data)

@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """로그인"""
    auth_service = AuthService(db)
    return await auth_service.login(form_data.username, form_data.password)

@router.get("/me")
async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """현재 사용자 정보"""
    auth_service = AuthService(db)
    return await auth_service.get_current_user(token)

