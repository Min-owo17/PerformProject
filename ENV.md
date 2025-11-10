# 환경변수 설정 가이드

이 문서는 PerformProject의 Docker 환경변수 설정 방법을 안내합니다.

## 환경변수 파일 생성

### 개발 환경 (.env)
```bash
cd docker
cp .env.example .env
nano .env  # 또는 원하는 에디터 사용
```

### 프로덕션 환경 (.env.prod)
```bash
cd docker
cp .env.example .env.prod
nano .env.prod  # 또는 원하는 에디터 사용
```

## 환경변수 목록

### PostgreSQL 설정
```env
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata
```

### pgAdmin 설정 (개발 환경만)
```env
PGADMIN_DEFAULT_EMAIL=admin@perform.com
PGADMIN_DEFAULT_PASSWORD=admin_password_here
```

### Redis 설정
```env
REDIS_PASSWORD=your_redis_password_here
```

### MinIO (S3 호환) 설정
```env
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password_here
MINIO_BUCKET=perform-audio
```

### JWT 설정
```env
JWT_SECRET_KEY=your_jwt_secret_key_here_change_in_production
```

### CORS 설정 (개발 환경)
```env
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### AWS 설정 (프로덕션 환경에서 사용, 선택사항)
```env
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=ap-northeast-2
AWS_S3_BUCKET=perform-project-audio
```

### 소셜 로그인 설정 (OAuth, 선택사항)
```env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
KAKAO_CLIENT_ID=your_kakao_client_id
KAKAO_CLIENT_SECRET=your_kakao_client_secret
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
```

## 환경변수 예시 파일

### 개발 환경 (.env)
```env
# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# pgAdmin 설정
PGADMIN_DEFAULT_EMAIL=admin@perform.com
PGADMIN_DEFAULT_PASSWORD=admin1234

# Redis 설정
REDIS_PASSWORD=redis_pass_123

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=dev_jwt_secret_key_change_in_production

# CORS 설정
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### 프로덕션 환경 (.env.prod)
```env
# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=강력한_프로덕션_비밀번호
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# Redis 설정
REDIS_PASSWORD=강력한_Redis_비밀번호

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=강력한_MinIO_비밀번호
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=강력한_JWT_시크릿_키

# AWS 설정 (선택사항)
# AWS_ACCESS_KEY_ID=your_aws_access_key
# AWS_SECRET_ACCESS_KEY=your_aws_secret_key
# AWS_REGION=ap-northeast-2
# AWS_S3_BUCKET=perform-project-audio
```

## 비밀번호 생성

강력한 비밀번호를 생성하려면:
```bash
# OpenSSL 사용
openssl rand -base64 32

# 또는 /dev/urandom 사용 (Linux)
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

## 보안 권장사항

1. **강력한 비밀번호 사용**: 최소 16자 이상, 대소문자, 숫자, 특수문자 포함
2. **환경별 분리**: 개발 환경과 프로덕션 환경의 비밀번호를 다르게 설정
3. **비밀번호 변경**: 정기적으로 비밀번호를 변경하세요
4. **파일 권한**: 환경변수 파일의 권한을 제한하세요 (chmod 600)
5. **Git 제외**: `.env` 및 `.env.prod` 파일을 `.gitignore`에 추가하세요
6. **시크릿 관리**: 프로덕션 환경에서는 AWS Secrets Manager 또는 HashiCorp Vault 사용 고려

## 환경변수 파일 권한 설정

```bash
# 환경변수 파일 권한 제한
chmod 600 .env
chmod 600 .env.prod

# 소유자 확인
ls -la .env .env.prod
```

## 환경변수 확인

### Docker Compose에서 환경변수 확인
```bash
# 환경변수 파일 로드 확인
docker-compose config

# 특정 서비스의 환경변수 확인
docker-compose config | grep -A 20 "postgres:"
```

### 컨테이너 내부에서 환경변수 확인
```bash
# PostgreSQL 컨테이너
docker exec perform_postgres env | grep POSTGRES

# Redis 컨테이너
docker exec perform_redis env | grep REDIS

# MinIO 컨테이너
docker exec perform_minio env | grep MINIO
```

## 문제 해결

### 환경변수가 로드되지 않는 경우
1. 환경변수 파일 경로 확인
2. 파일 이름 확인 (.env 또는 .env.prod)
3. 파일 권한 확인
4. Docker Compose 파일에서 `env_file` 설정 확인

### 비밀번호 오류
1. 환경변수 파일의 비밀번호 확인
2. 특수문자 이스케이프 확인
3. 따옴표 사용 확인 (필요한 경우)

### 연결 오류
1. 환경변수 파일의 호스트 이름 확인
2. 포트 번호 확인
3. 네트워크 설정 확인








