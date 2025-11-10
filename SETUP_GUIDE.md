# PerformProject 설정 가이드

이 문서는 PerformProject를 설정하고 실행하는 방법을 안내합니다.

## 📋 진행 상황

### ✅ 완료된 작업

1. **데이터베이스 초기화 SQL 파일 생성**
   - `docker/postgres/initdb/01_init_schema.sql` - 테이블 스키마
   - `docker/postgres/initdb/02_init_data.sql` - 초기 데이터 (칭호 등)

2. **Docker 환경 설정**
   - `docker/docker-compose.yml` - 개발 환경 설정
   - `docker/docker-compose.prod.yml` - 프로덕션 환경 설정
   - `docker/.env.example` - 환경변수 예시 파일
   - `docker/README.md` - Docker 사용 가이드

3. **React 프론트엔드 프로젝트 구조 생성**
   - `frontend/` 폴더 구조 생성
   - 기본 설정 파일들 (package.json, vite.config.ts, tailwind.config.js 등)
   - Dockerfile 및 nginx 설정

### 🔄 진행 중인 작업

1. **screen 폴더 컴포넌트 통합**
   - screen 폴더의 컴포넌트들을 frontend/src로 복사 필요

### 📝 다음 단계

1. **screen 폴더 파일 복사**
   ```bash
   # Windows PowerShell
   Copy-Item -Path "screen\components\*" -Destination "frontend\src\components\" -Recurse
   Copy-Item -Path "screen\context\*" -Destination "frontend\src\context\" -Recurse
   Copy-Item -Path "screen\hooks\*" -Destination "frontend\src\hooks\" -Recurse
   Copy-Item -Path "screen\services\*" -Destination "frontend\src\services\" -Recurse
   Copy-Item -Path "screen\styles\*" -Destination "frontend\src\styles\" -Recurse
   Copy-Item -Path "screen\utils\*" -Destination "frontend\src\utils\" -Recurse
   Copy-Item -Path "screen\types.ts" -Destination "frontend\src\types.ts"
   ```

2. **Navigation 컴포넌트 생성**
   - `frontend/src/components/Navigation.tsx` 생성 필요

3. **FastAPI 백엔드 프로젝트 생성**
   - `backend/` 폴더 구조 생성
   - FastAPI 기본 설정
   - API 엔드포인트 구현

4. **환경변수 설정**
   - `docker/.env` 파일 생성 (`.env.example` 참고)
   - `frontend/.env` 파일 생성

5. **Docker 컨테이너 실행**
   ```bash
   cd docker
   docker-compose up -d
   ```

## 🚀 빠른 시작

### 1. 데이터베이스 설정

```bash
# docker 폴더로 이동
cd docker

# .env 파일 생성
cp .env.example .env

# .env 파일 수정 (비밀번호 등)
# Windows: notepad .env
# Linux/Mac: nano .env

# Docker 컨테이너 실행
docker-compose up -d

# 상태 확인
docker-compose ps
```

### 2. 프론트엔드 설정

```bash
# frontend 폴더로 이동
cd ../frontend

# screen 폴더 파일 복사 (위의 명령어 참고)

# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
```

### 3. 백엔드 설정 (준비 중)

```bash
# backend 폴더로 이동
cd ../backend

# 가상환경 생성 (Python)
python -m venv venv

# 가상환경 활성화
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

# 의존성 설치
pip install -r requirements.txt

# 서버 실행
uvicorn app.main:app --reload
```

## 📁 프로젝트 구조

```
PerformProject/
├── docker/                 # Docker 설정
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   ├── .env.example
│   ├── postgres/
│   │   └── initdb/        # 데이터베이스 초기화 SQL
│   └── README.md
├── frontend/               # React 프론트엔드
│   ├── src/
│   │   ├── components/    # 화면 컴포넌트 (복사 필요)
│   │   ├── context/       # React Context (복사 필요)
│   │   ├── hooks/         # 커스텀 훅 (복사 필요)
│   │   ├── services/      # API 서비스 (복사 필요)
│   │   ├── styles/        # 스타일 (복사 필요)
│   │   ├── utils/         # 유틸리티 (복사 필요)
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── types.ts       # 타입 정의 (복사 필요)
│   ├── package.json
│   └── README.md
├── backend/                # FastAPI 백엔드 (생성 필요)
│   ├── app/
│   │   ├── main.py
│   │   ├── models/
│   │   ├── schemas/
│   │   └── api/
│   └── requirements.txt
├── screen/                 # 기존 컴포넌트 (복사 필요)
│   ├── components/
│   ├── context/
│   ├── hooks/
│   ├── services/
│   ├── styles/
│   ├── utils/
│   └── types.ts
└── requirements.md         # 요구사항 문서
```

## 🔧 문제 해결

### Docker 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs

# 컨테이너 재시작
docker-compose restart

# 컨테이너 재생성
docker-compose down
docker-compose up -d
```

### 포트 충돌

다음 포트가 사용 중인지 확인:
- 5432 (PostgreSQL)
- 6379 (Redis)
- 9000, 9001 (MinIO)
- 3000 (Frontend)
- 8000 (Backend)

### 데이터베이스 연결 실패

```bash
# PostgreSQL 컨테이너 확인
docker exec -it perform_postgres psql -U perform_user -d perform_db

# 환경변수 확인
docker-compose config
```

## 📚 추가 문서

- [Docker 사용 가이드](docker/README.md)
- [데이터베이스 스키마](docker/postgres/initdb/01_init_schema.sql)
- [요구사항 문서](requirements.md)

