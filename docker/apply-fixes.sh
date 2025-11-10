#!/bin/bash

# Docker Compose 파일 수정 사항 적용 스크립트
# 이 스크립트는 수정된 docker-compose 파일을 적용하고 서비스를 재시작합니다.

set -e

echo "=========================================="
echo "Docker Compose 수정 사항 적용 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

if [ ! -f "docker-compose.prod.yml" ]; then
    echo "오류: docker-compose.prod.yml 파일을 찾을 수 없습니다."
    exit 1
fi

echo ""
echo "수정된 내용:"
echo "  1. minio-init 이미지: RELEASE.2024-05-10T00-17-41Z → latest"
echo "  2. redis 서비스에 env_file 추가"
echo ""

# 사용자 확인
read -p "서비스를 재시작하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 0
fi

echo ""
echo "1. Docker Compose 설정 검증..."
docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "오류: Docker Compose 설정에 문제가 있습니다."
    docker-compose -f docker-compose.prod.yml config
    exit 1
fi
echo "  ✓ 설정 검증 완료"

echo ""
echo "2. 최신 MinIO MC 이미지 다운로드..."
docker pull quay.io/minio/mc:latest
echo "  ✓ 이미지 다운로드 완료"

echo ""
echo "3. 기존 minio-init 컨테이너 제거..."
docker-compose -f docker-compose.prod.yml stop minio-init 2>/dev/null || true
docker-compose -f docker-compose.prod.yml rm -f minio-init 2>/dev/null || true
echo "  ✓ 기존 컨테이너 제거 완료"

echo ""
echo "4. Redis 서비스 재시작 (env_file 적용)..."
docker-compose -f docker-compose.prod.yml up -d redis
sleep 3
echo "  ✓ Redis 서비스 재시작 완료"

echo ""
echo "5. MinIO Init 서비스 시작..."
docker-compose -f docker-compose.prod.yml up -d minio-init
sleep 5
echo "  ✓ MinIO Init 서비스 시작 완료"

echo ""
echo "6. 서비스 상태 확인..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "7. MinIO Init 로그 확인..."
docker-compose -f docker-compose.prod.yml logs --tail 20 minio-init

echo ""
echo "=========================================="
echo "적용 완료!"
echo "=========================================="
echo ""
echo "서비스 상태 확인:"
echo "  docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "로그 확인:"
echo "  docker-compose -f docker-compose.prod.yml logs -f minio-init"
echo ""
echo "MinIO 버킷 확인:"
echo "  docker exec perform_minio_prod mc ls local/"
echo ""

