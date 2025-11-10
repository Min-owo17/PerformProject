# PerformProject Docker 환경 설정

이 디렉토리는 PerformProject의 Docker 기반 개발 및 프로덕션 환경을 관리합니다.

## 📋 목차

- [사전 준비사항](#사전-준비사항)
- [빠른 시작](#빠른-시작)
- [환경 설정](#환경-설정)
- [서비스 구성](#서비스-구성)
- [사용법](#사용법)
- [배포](#배포)

## 사전 준비사항

### 필수 요구사항
- Docker Desktop (Windows/Mac) 또는 Docker Engine + Docker Compose V2 (Linux)
- 최소 4GB RAM
- 최소 10GB 디스크 공간

### 포트 확인
다음 포트가 사용 중이 아니어야 합니다:
- `5432` - PostgreSQL
- `5050` - pgAdmin (개발 환경)
- `6379` - Redis
- `9000` - MinIO S3 API
- `9001` - MinIO Console
- `8000` - FastAPI Backend
- `3000` - React Frontend

## 빠른 시작

### AWS EC2 서버 설정 (프로덕션)

AWS EC2 서버에서 PerformProject를 설정하려면 다음 가이드를 참조하세요:
- **[빠른 시작 가이드](./QUICK_START.md)** - 단계별 빠른 설정 가이드
- **[상세 설정 가이드](./AWS_EC2_SETUP_GUIDE.md)** - 상세한 설정 및 문제 해결 가이드

### 로컬 개발 환경 설정

#### 1. 환경변수 파일 생성

**방법 1: 자동 생성 스크립트 사용 (권장)**
```bash
# 개발 환경
chmod +x setup-env.sh
./setup-env.sh dev

# 프로덕션 환경
./setup-env.sh prod
```

**방법 2: 수동 생성**
```bash
# .env.example을 복사하여 .env 파일 생성
cp .env.example .env

# .env 파일을 열어서 비밀번호 등을 수정
# Windows: notepad .env
# Linux/Mac: nano .env
```

**중요**: `.env` 파일에서 다음 값들을 반드시 수정하세요:
- `POSTGRES_PASSWORD` - 강력한 비밀번호
- `PGADMIN_DEFAULT_PASSWORD` - 관리자 비밀번호
- `REDIS_PASSWORD` - Redis 비밀번호
- `MINIO_ROOT_PASSWORD` - MinIO 비밀번호
- `JWT_SECRET_KEY` - JWT 시크릿 키 (프로덕션에서는 반드시 변경)

더 자세한 내용은 [환경변수 설정 가이드](./ENV.md)를 참조하세요.

### 2. Docker 컨테이너 실행

```bash
# 개발 환경
docker-compose up -d

# 프로덕션 환경
docker-compose -f docker-compose.prod.yml up -d
```

### 3. 서비스 상태 확인

```bash
docker-compose ps
```

### 4. 로그 확인

```bash
# 모든 서비스 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f postgres
docker-compose logs -f backend
```

## 환경 설정

### 개발 환경 (.env)

`docker/.env.example` 파일을 복사하여 `docker/.env` 파일을 생성하고 다음 값을 수정하세요:

```env
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=강력한_비밀번호_입력
POSTGRES_DB=perform_db

PGADMIN_DEFAULT_EMAIL=admin@perform.com
PGADMIN_DEFAULT_PASSWORD=관리자_비밀번호_입력

REDIS_PASSWORD=redis_비밀번호_입력

MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minio_비밀번호_입력
MINIO_BUCKET=perform-audio

JWT_SECRET_KEY=강력한_JWT_시크릿_키_입력
```

### 프로덕션 환경 (.env.prod)

프로덕션 환경에서는 `.env.prod` 파일을 사용합니다. 더 강력한 비밀번호를 사용하고, 환경변수를 안전하게 관리하세요.

## 서비스 구성

### PostgreSQL
- **포트**: 5432
- **데이터베이스**: `${POSTGRES_DB}`
- **사용자**: `${POSTGRES_USER}`
- **초기화**: `postgres/initdb/` 폴더의 SQL 파일 자동 실행

### pgAdmin (개발 환경만)
- **포트**: 5050
- **URL**: http://localhost:5050
- **이메일**: `${PGADMIN_DEFAULT_EMAIL}`
- **비밀번호**: `${PGADMIN_DEFAULT_PASSWORD}`

### Redis
- **포트**: 6379
- **비밀번호**: `${REDIS_PASSWORD}`
- **용도**: 세션 캐싱, 큐잉

### MinIO (S3 호환)
- **S3 API**: http://localhost:9000
- **콘솔**: http://localhost:9001
- **사용자**: `${MINIO_ROOT_USER}`
- **비밀번호**: `${MINIO_ROOT_PASSWORD}`
- **버킷**: `${MINIO_BUCKET}`

### FastAPI Backend
- **포트**: 8000
- **URL**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **환경변수**: `.env` 파일에서 자동 로드

## 사용법

### 데이터베이스 초기화

데이터베이스는 컨테이너가 처음 시작될 때 자동으로 초기화됩니다.

수동으로 초기화하려면:

```bash
# 컨테이너 재시작
docker-compose restart postgres

# 또는 데이터베이스 백업에서 복원
docker exec -i perform_postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < backup.sql
```

### 데이터베이스 백업

```bash
# 백업 스크립트 사용 (권장)
./backup.sh

# 또는 수동 백업
docker exec perform_postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup_$(date +%Y%m%d).sql
```

### 데이터베이스 복원

```bash
# 복원 스크립트 사용 (권장)
./restore.sh backup_20241110.sql

# 또는 수동 복원
docker exec -i perform_postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < backup_20241110.sql
```

### 서비스 중지

```bash
# 서비스 중지 (데이터는 유지)
docker-compose down

# 서비스 중지 및 볼륨 삭제 (데이터 삭제)
docker-compose down -v
```

### 서비스 재시작

```bash
docker-compose restart
```

## 배포

### 자동 배포 스크립트

```bash
# 개발 환경 배포
chmod +x deploy.sh
./deploy.sh dev

# 프로덕션 환경 배포
./deploy.sh prod
```

### AWS EC2에 배포

1. **EC2 인스턴스 준비**
   ```bash
   # Docker 설치
   sudo yum update -y
   sudo yum install docker -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -a -G docker ec2-user

   # Docker Compose 설치
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **프로젝트 파일 업로드**
   ```bash
   # SCP 또는 Git을 사용하여 파일 업로드
   scp -r docker/ ec2-user@your-ec2-ip:/opt/performproject/
   ```

3. **환경변수 설정**
   ```bash
   cd /opt/performproject/docker
   cp .env.example .env.prod
   nano .env.prod  # 비밀번호 수정
   ```

4. **서비스 시작**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

5. **상태 확인**
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   docker-compose -f docker-compose.prod.yml logs -f
   ```

## 문제 해결

### 포트 충돌

포트가 이미 사용 중인 경우:

```bash
# Windows
netstat -ano | findstr :5432

# Linux/Mac
lsof -i :5432
```

### 데이터베이스 연결 실패

```bash
# PostgreSQL 로그 확인
docker-compose logs postgres

# 컨테이너 상태 확인
docker-compose ps

# 데이터베이스 연결 테스트
docker exec -it perform_postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

### 백엔드 서버 오류

```bash
# 백엔드 로그 확인
docker-compose logs backend

# 백엔드 컨테이너 재시작
docker-compose restart backend

# 백엔드 컨테이너 내부 접속
docker exec -it perform_backend bash
```

### 볼륨 권한 문제

```bash
# 볼륨 권한 수정 (Linux)
sudo chown -R 999:999 postgres/data
```

## 추가 리소스

- [PostgreSQL 문서](POSTGRES_CONNECTION.md)
- [Redis 문서](REDIS.md)
- [MinIO 문서](MINIO.md)
- [백업 및 복원](BACKUP_RESTORE.md)
- [마이그레이션](MIGRATION.md)
- [운영 및 보안](OPERATIONS_SECURITY.md)
