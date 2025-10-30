### 11.11 마이그레이션 권장

- FastAPI + SQLAlchemy 사용 시 Alembic 도입 권장.
- CI 단계에서 `alembic upgrade head`로 스키마 일관성 유지.


