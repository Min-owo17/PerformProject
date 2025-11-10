#!/bin/bash

# .env.prod 파일 문제 자동 수정 스크립트

# set -e를 사용하지 않음 (오류 처리 개선)

echo "=========================================="
echo ".env.prod 파일 자동 수정 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

if [ ! -f ".env.prod" ]; then
    echo "오류: .env.prod 파일이 없습니다."
    exit 1
fi

echo ""
echo "1. 기존 파일 백업..."
cp .env.prod .env.prod.backup.$(date +%Y%m%d_%H%M%S)
echo "  ✓ 백업 완료"

echo ""
echo "2. CRLF 문제 해결..."
if command -v dos2unix > /dev/null 2>&1; then
    dos2unix .env.prod
    echo "  ✓ dos2unix 사용하여 변환 완료"
else
    sed -i 's/\r$//' .env.prod
    echo "  ✓ sed 사용하여 변환 완료"
fi

echo ""
echo "3. 파일 권한 설정..."
chmod 600 .env.prod
echo "  ✓ 권한 설정 완료 (600)"

echo ""
echo "4. 환경변수 형식 정리..."
# 공백 제거 (변수명 = 값 → 변수명=값)
sed -i 's/^\([A-Z_]*\)[[:space:]]*=[[:space:]]*\(.*\)$/\1=\2/' .env.prod

# 빈 줄과 주석은 유지하되, 불필요한 공백 제거
sed -i 's/[[:space:]]*$//' .env.prod

echo "  ✓ 형식 정리 완료"

echo ""
echo "5. 파일 검증..."
# 필수 환경변수 확인
REQUIRED_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "REDIS_PASSWORD" "MINIO_ROOT_USER" "MINIO_ROOT_PASSWORD" "MINIO_BUCKET")

MISSING_VARS=()
for VAR in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${VAR}=" .env.prod; then
        MISSING_VARS+=("$VAR")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "  ⚠️  누락된 환경변수: ${MISSING_VARS[*]}"
    echo "  .env.prod 파일을 수동으로 확인하세요."
else
    echo "  ✓ 모든 필수 환경변수 존재"
fi

echo ""
echo "6. Docker Compose 설정 검증..."
if docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1; then
    echo "  ✓ Docker Compose 설정 올바름"
else
    echo "  ✗ Docker Compose 설정 오류"
    echo "  오류 내용:"
    docker-compose -f docker-compose.prod.yml config 2>&1 | head -10
    echo ""
    echo "  백업 파일에서 복원:"
    echo "  cp .env.prod.backup.* .env.prod"
    exit 1
fi

echo ""
echo "=========================================="
echo "수정 완료!"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "  1. .env.prod 파일 확인: cat .env.prod"
echo "  2. 서비스 시작: docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo "백업 파일: .env.prod.backup.*"
echo ""

