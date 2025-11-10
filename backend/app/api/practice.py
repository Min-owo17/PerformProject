from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_practice_sessions():
    return {"message": "Practice sessions endpoint"}

