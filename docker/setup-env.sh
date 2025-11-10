#!/bin/bash

# PerformProject 환경변수 파일 설정 스크립트
# 사용법: ./setup-env.sh [dev|prod]

ENVIRONMENT=${1:-dev}

echo "=========================================="
echo "PerformProject 환경변수 파일 설정"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# 환경변수 파일 이름 결정
if [ "$ENVIRONMENT" = "prod" ]; then
    ENV_FILE=".env.prod"
else
    ENV_FILE=".env"
fi

# 환경변수 파일이 이미 존재하는지 확인
if [ -f "$ENV_FILE" ]; then
    echo "경고: $ENV_FILE 파일이 이미 존재합니다."
    read -p "덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "취소되었습니다."
        exit 1
    fi
fi

# 비밀번호 생성 함수
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# 환경변수 파일 생성
echo "환경변수 파일 생성 중: $ENV_FILE"

cat > "$ENV_FILE" << EOF
# PerformProject 환경변수 설정 파일
# 생성일: $(date +"%Y-%m-%d %H:%M:%S")
# Environment: $ENVIRONMENT

# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=$(generate_password)
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# pgAdmin 설정 (개발 환경만)
PGADMIN_DEFAULT_EMAIL=admin@perform.com
PGADMIN_DEFAULT_PASSWORD=$(generate_password)

# Redis 설정
REDIS_PASSWORD=$(generate_password)

# MinIO (S3 호환) 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=$(generate_password)
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=$(generate_password)

# CORS 설정 (개발 환경)
CORS_ORIGINS=http://localhost:3000,http://localhost:5173

# AWS 설정 (프로덕션 환경에서 사용, 선택사항)
# AWS_ACCESS_KEY_ID=your_aws_access_key
# AWS_SECRET_ACCESS_KEY=your_aws_secret_key
# AWS_REGION=ap-northeast-2
# AWS_S3_BUCKET=perform-project-audio

# 소셜 로그인 설정 (OAuth, 선택사항)
# GOOGLE_CLIENT_ID=your_google_client_id
# GOOGLE_CLIENT_SECRET=your_google_client_secret
# KAKAO_CLIENT_ID=your_kakao_client_id
# KAKAO_CLIENT_SECRET=your_kakao_client_secret
# NAVER_CLIENT_ID=your_naver_client_id
# NAVER_CLIENT_SECRET=your_naver_client_secret
EOF

# 파일 권한 설정
chmod 600 "$ENV_FILE"

echo "=========================================="
echo "환경변수 파일이 생성되었습니다: $ENV_FILE"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "1. 환경변수 파일을 확인하세요: cat $ENV_FILE"
echo "2. 필요에 따라 환경변수를 수정하세요: nano $ENV_FILE"
echo "3. 서비스를 시작하세요: docker-compose -f docker-compose.yml up -d"
echo ""
echo "보안 참고사항:"
echo "- 생성된 비밀번호를 안전하게 보관하세요."
echo "- 프로덕션 환경에서는 추가 보안 설정을 권장합니다."
echo "- 환경변수 파일은 Git에 커밋하지 마세요."

