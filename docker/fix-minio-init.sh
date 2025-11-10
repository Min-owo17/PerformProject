#!/bin/bash

# MinIO Init 이미지 수정 및 적용 스크립트
# 이 스크립트는 minio-init 서비스의 이미지 태그를 latest로 변경하고 서비스를 재시작합니다.

set -e

echo "=========================================="
echo "MinIO Init 이미지 수정 및 적용 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "오류: docker-compose.prod.yml 파일을 찾을 수 없습니다."
    echo "프로젝트 디렉토리(/opt/performproject/docker)에서 실행하세요."
    exit 1
fi

echo ""
echo "1. 기존 minio-init 컨테이너 중지 및 제거..."
docker-compose -f docker-compose.prod.yml stop minio-init 2>/dev/null || true
docker-compose -f docker-compose.prod.yml rm -f minio-init 2>/dev/null || true

echo ""
echo "2. 최신 MinIO MC 이미지 다운로드..."
docker pull quay.io/minio/mc:latest

echo ""
echo "3. Docker Compose 설정 확인..."
docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "경고: Docker Compose 설정에 문제가 있을 수 있습니다."
    echo "설정을 확인합니다..."
    docker-compose -f docker-compose.prod.yml config
    exit 1
fi

echo ""
echo "4. MinIO Init 서비스 시작..."
docker-compose -f docker-compose.prod.yml up -d minio-init

echo ""
echo "5. MinIO Init 컨테이너 상태 확인..."
sleep 5
docker-compose -f docker-compose.prod.yml ps minio-init

echo ""
echo "6. MinIO Init 로그 확인..."
docker-compose -f docker-compose.prod.yml logs minio-init

echo ""
echo "=========================================="
echo "작업 완료!"
echo "=========================================="
echo ""
echo "MinIO Init 서비스가 성공적으로 시작되었습니다."
echo ""
echo "확인 사항:"
echo "  - 컨테이너 상태: docker-compose -f docker-compose.prod.yml ps minio-init"
echo "  - 로그 확인: docker-compose -f docker-compose.prod.yml logs minio-init"
echo "  - MinIO 버킷 확인: docker exec perform_minio_prod mc ls local/"
echo ""

