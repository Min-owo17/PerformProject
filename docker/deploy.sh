#!/bin/bash

# PerformProject 배포 스크립트
# 사용법: ./deploy.sh [dev|prod]

ENVIRONMENT=${1:-dev}

echo "=========================================="
echo "PerformProject 배포 시작"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# 환경 확인
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
    ENV_FILE=".env.prod"
else
    COMPOSE_FILE="docker-compose.yml"
    ENV_FILE=".env"
fi

# 환경변수 파일 확인
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE 파일이 없습니다."
    echo "Please create $ENV_FILE from .env.example"
    exit 1
fi

# Docker Compose 파일 확인
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: $COMPOSE_FILE 파일이 없습니다."
    exit 1
fi

# Docker가 실행 중인지 확인
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker가 실행되지 않았습니다."
    exit 1
fi

# 기존 컨테이너 중지 및 제거
echo "기존 컨테이너 중지 중..."
docker-compose -f $COMPOSE_FILE down

# 이미지 빌드 (백엔드, 프론트엔드)
echo "이미지 빌드 중..."
docker-compose -f $COMPOSE_FILE build --no-cache

# 컨테이너 시작
echo "컨테이너 시작 중..."
docker-compose -f $COMPOSE_FILE up -d

# 상태 확인
echo "컨테이너 상태 확인 중..."
sleep 5
docker-compose -f $COMPOSE_FILE ps

# 로그 확인
echo "=========================================="
echo "배포 완료!"
echo "로그를 확인하려면: docker-compose -f $COMPOSE_FILE logs -f"
echo "=========================================="

