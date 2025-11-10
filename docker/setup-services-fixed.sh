#!/bin/bash

# PostgreSQL, Redis, MinIO 세팅 스크립트 (수정 버전)
# MinIO Init 이미지 문제가 해결된 버전

set -e

echo "=========================================="
echo "PostgreSQL, Redis, MinIO 세팅 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

if [ ! -f "docker-compose.prod.yml" ]; then
    echo "오류: docker-compose.prod.yml 파일을 찾을 수 없습니다."
    echo "프로젝트 디렉토리에서 실행하세요."
    exit 1
fi

echo ""
echo "1. 환경변수 파일 확인..."
if [ ! -f ".env.prod" ]; then
    echo "  .env.prod 파일이 없습니다. 생성 중..."
    
    # 비밀번호 생성 함수
    generate_password() {
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
    }
    
    cat > .env.prod << EOF
# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=$(generate_password)
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# Redis 설정
REDIS_PASSWORD=$(generate_password)

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=$(generate_password)
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=$(generate_password)
EOF
    
    chmod 600 .env.prod
    echo "  ✓ .env.prod 파일 생성 완료"
    echo "  ⚠️  생성된 비밀번호를 확인하고 필요시 수정하세요: nano .env.prod"
else
    echo "  ✓ .env.prod 파일 존재 확인"
fi

echo ""
echo "2. 볼륨 디렉토리 생성 및 권한 설정..."
sudo mkdir -p /var/lib/postgresql/data
sudo mkdir -p /var/lib/redis/data
sudo mkdir -p /var/lib/minio/data

sudo chown -R 999:999 /var/lib/postgresql/data 2>/dev/null || sudo chown -R $USER:$USER /var/lib/postgresql/data
sudo chown -R 999:999 /var/lib/redis/data 2>/dev/null || sudo chown -R $USER:$USER /var/lib/redis/data
sudo chown -R 1000:1000 /var/lib/minio/data 2>/dev/null || sudo chown -R $USER:$USER /var/lib/minio/data

echo "  ✓ 볼륨 디렉토리 생성 및 권한 설정 완료"

echo ""
echo "3. Docker Compose 설정 검증..."
docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "  ✗ Docker Compose 설정에 문제가 있습니다."
    docker-compose -f docker-compose.prod.yml config
    exit 1
fi
echo "  ✓ Docker Compose 설정 검증 완료"

echo ""
echo "4. 최신 이미지 다운로드..."
docker pull postgres:15
docker pull redis:7-alpine
docker pull quay.io/minio/minio:RELEASE.2024-05-10T01-41-38Z
docker pull quay.io/minio/mc:latest
echo "  ✓ 이미지 다운로드 완료"

echo ""
echo "5. 서비스 시작..."
docker-compose -f docker-compose.prod.yml up -d postgres redis minio

echo ""
echo "6. 서비스 준비 대기 (30초)..."
sleep 30

echo ""
echo "7. MinIO Init 서비스 시작..."
docker-compose -f docker-compose.prod.yml up -d minio-init

echo ""
echo "8. 서비스 상태 확인..."
sleep 5
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "9. 서비스 연결 테스트..."

# PostgreSQL 테스트
echo -n "  PostgreSQL: "
if docker exec perform_postgres_prod pg_isready -U perform_user > /dev/null 2>&1; then
    echo "✓ 연결 성공"
else
    echo "✗ 연결 실패"
fi

# Redis 테스트
echo -n "  Redis: "
REDIS_PASSWORD=$(grep REDIS_PASSWORD .env.prod | cut -d'=' -f2)
if docker exec perform_redis_prod redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1; then
    echo "✓ 연결 성공"
else
    echo "✗ 연결 실패"
fi

# MinIO 테스트
echo -n "  MinIO: "
if docker exec perform_minio_prod curl -f http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo "✓ 연결 성공"
else
    echo "✗ 연결 실패"
fi

# MinIO Init 테스트
echo -n "  MinIO Init: "
if docker ps | grep -q "perform_minio_init_prod"; then
    INIT_STATUS=$(docker inspect perform_minio_init_prod --format='{{.State.Status}}' 2>/dev/null || echo "unknown")
    if [ "$INIT_STATUS" = "exited" ]; then
        EXIT_CODE=$(docker inspect perform_minio_init_prod --format='{{.State.ExitCode}}' 2>/dev/null || echo "1")
        if [ "$EXIT_CODE" = "0" ]; then
            echo "✓ 완료"
        else
            echo "✗ 실패 (Exit Code: $EXIT_CODE)"
            echo "    로그 확인: docker logs perform_minio_init_prod"
        fi
    else
        echo "⏳ 실행 중..."
    fi
else
    echo "✗ 컨테이너 없음"
fi

echo ""
echo "=========================================="
echo "세팅 완료!"
echo "=========================================="
echo ""
echo "서비스 상태 확인:"
echo "  docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "로그 확인:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "MinIO 버킷 확인:"
echo "  docker exec perform_minio_prod mc ls local/"
echo ""

