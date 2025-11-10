#!/bin/bash

# 환경변수 오류 진단 스크립트
# EC2 서버에서 실행하여 .env.prod 파일의 문제를 진단합니다.

# set -e를 사용하지 않음 (오류가 있어도 진단 계속)

echo "=========================================="
echo "환경변수 오류 진단 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo ""
echo "현재 디렉토리: $(pwd)"
echo ""

# 1. 파일 위치 확인
echo "1. 파일 위치 확인..."
if [ -f ".env.prod" ]; then
    echo "  ✓ .env.prod 파일 존재"
    echo "  위치: $(pwd)/.env.prod"
    FILE_EXISTS=true
else
    echo "  ✗ .env.prod 파일 없음"
    echo "  현재 디렉토리의 파일 목록:"
    ls -la | grep -E "\.env|docker-compose"
    FILE_EXISTS=false
fi

if [ -f "docker-compose.prod.yml" ]; then
    echo "  ✓ docker-compose.prod.yml 파일 존재"
else
    echo "  ✗ docker-compose.prod.yml 파일 없음"
fi

echo ""

# 2. 파일 권한 확인
if [ "$FILE_EXISTS" = true ]; then
    echo "2. 파일 권한 확인..."
    PERMISSIONS=$(stat -c "%a" .env.prod 2>/dev/null || stat -f "%OLp" .env.prod 2>/dev/null || echo "unknown")
    OWNER=$(stat -c "%U:%G" .env.prod 2>/dev/null || stat -f "%Su:%Sg" .env.prod 2>/dev/null || echo "unknown")
    echo "  권한: $PERMISSIONS"
    echo "  소유자: $OWNER"
    
    if [ "$PERMISSIONS" != "600" ] && [ "$PERMISSIONS" != "644" ] && [ "$PERMISSIONS" != "660" ]; then
        echo "  ⚠️  권한이 적절하지 않을 수 있습니다. (권장: 600)"
        echo "  수정 방법: chmod 600 .env.prod"
    else
        echo "  ✓ 권한 올바름"
    fi
    echo ""

    # 3. 파일 형식 확인 (CRLF 문제)
    echo "3. 파일 형식 확인 (줄바꿈 문자)..."
    if command -v file > /dev/null 2>&1; then
        FILE_TYPE=$(file .env.prod)
        echo "  $FILE_TYPE"
    fi
    
    # CRLF 확인
    if grep -q $'\r' .env.prod 2>/dev/null; then
        echo "  ✗ CRLF 문자 발견 (Windows 형식)"
        echo "  문제: Windows에서 생성한 파일을 Linux로 업로드할 때 발생"
        echo "  수정 방법: dos2unix .env.prod"
        echo "  또는: sed -i 's/\r$//' .env.prod"
        CRLF_PROBLEM=true
    else
        echo "  ✓ LF 형식 (Linux 형식)"
        CRLF_PROBLEM=false
    fi
    echo ""

    # 4. 파일 인코딩 확인
    echo "4. 파일 인코딩 확인..."
    if command -v file > /dev/null 2>&1; then
        ENCODING=$(file -i .env.prod 2>/dev/null | cut -d'=' -f2 || echo "unknown")
        echo "  인코딩: $ENCODING"
        if [[ "$ENCODING" == *"utf-8"* ]] || [[ "$ENCODING" == *"us-ascii"* ]]; then
            echo "  ✓ 인코딩 올바름"
        else
            echo "  ⚠️  인코딩 문제 가능성"
        fi
    else
        echo "  file 명령어를 사용할 수 없습니다."
    fi
    echo ""

    # 5. 환경변수 확인
    echo "5. 필수 환경변수 확인..."
    REQUIRED_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "REDIS_PASSWORD" "MINIO_ROOT_USER" "MINIO_ROOT_PASSWORD" "MINIO_BUCKET")
    
    MISSING_VARS=()
    for VAR in "${REQUIRED_VARS[@]}"; do
        if grep -q "^${VAR}=" .env.prod 2>/dev/null; then
            echo "  ✓ $VAR"
        else
            echo "  ✗ $VAR 없음"
            MISSING_VARS+=("$VAR")
        fi
    done
    
    if [ ${#MISSING_VARS[@]} -gt 0 ]; then
        echo "  ⚠️  누락된 환경변수: ${MISSING_VARS[*]}"
    fi
    echo ""

    # 6. 환경변수 형식 확인
    echo "6. 환경변수 형식 확인..."
    
    # 공백이 있는 변수 확인 (변수명 = 값 형식)
    if grep -qE "^[A-Z_]+ = " .env.prod 2>/dev/null; then
        echo "  ✗ 공백이 있는 변수 발견 (변수명 = 값 형식)"
        echo "  문제가 있는 줄:"
        grep -E "^[A-Z_]+ = " .env.prod | head -5
        echo "  수정 필요: 변수명=값 형식으로 변경 (공백 제거)"
        FORMAT_PROBLEM=true
    else
        echo "  ✓ 변수 형식 올바름 (변수명=값)"
        FORMAT_PROBLEM=false
    fi
    
    # 빈 값 확인
    if grep -qE "^[A-Z_]+=$" .env.prod 2>/dev/null; then
        echo "  ⚠️  빈 값이 있는 변수 발견"
        echo "  문제가 있는 줄:"
        grep -E "^[A-Z_]+=$" .env.prod
        EMPTY_VALUE=true
    else
        echo "  ✓ 모든 변수에 값이 있음"
        EMPTY_VALUE=false
    fi
    
    # 따옴표 확인 (불필요한 따옴표)
    if grep -qE '^[A-Z_]+=".*"$' .env.prod 2>/dev/null; then
        echo "  ⚠️  따옴표가 있는 변수 발견 (일반적으로 불필요)"
        echo "  문제가 있는 줄:"
        grep -E '^[A-Z_]+=".*"$' .env.prod | head -3
    fi
    echo ""

    # 7. 환경변수 값 확인 (일부만 표시)
    echo "7. 환경변수 값 샘플 확인..."
    echo "  (비밀번호는 표시하지 않음)"
    while IFS='=' read -r key value; do
        # 주석 스킵
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        
        # 처음 3개만 표시
        if [ ${#SAMPLED_VARS[@]} -lt 3 ]; then
            if [[ "$key" == *"PASSWORD"* ]] || [[ "$key" == *"SECRET"* ]]; then
                echo "  $key=*** (숨김)"
            else
                echo "  $key=$value"
            fi
            SAMPLED_VARS+=("$key")
        fi
    done < .env.prod
    echo ""

    # 8. Docker Compose 설정 확인
    echo "8. Docker Compose 설정 검증..."
    if docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1; then
        echo "  ✓ Docker Compose 설정 올바름"
        CONFIG_OK=true
    else
        echo "  ✗ Docker Compose 설정 오류"
        echo "  오류 내용:"
        docker-compose -f docker-compose.prod.yml config 2>&1 | head -20
        CONFIG_OK=false
    fi
    echo ""

    # 9. 환경변수 로드 테스트
    echo "9. 환경변수 로드 테스트..."
    set +e
    set -a
    source .env.prod 2>/dev/null
    set +a
    set -e
    
    if [ -n "$POSTGRES_USER" ]; then
        echo "  ✓ POSTGRES_USER: $POSTGRES_USER"
    else
        echo "  ✗ POSTGRES_USER 로드 실패"
    fi
    
    if [ -n "$POSTGRES_DB" ]; then
        echo "  ✓ POSTGRES_DB: $POSTGRES_DB"
    else
        echo "  ✗ POSTGRES_DB 로드 실패"
    fi
    
    if [ -n "$REDIS_PASSWORD" ]; then
        echo "  ✓ REDIS_PASSWORD: 설정됨 (길이: ${#REDIS_PASSWORD})"
    else
        echo "  ✗ REDIS_PASSWORD 로드 실패"
    fi
    
    if [ -n "$MINIO_BUCKET" ]; then
        echo "  ✓ MINIO_BUCKET: $MINIO_BUCKET"
    else
        echo "  ✗ MINIO_BUCKET 로드 실패"
    fi
    echo ""
fi

# 10. 요약 및 해결 방법
echo "=========================================="
echo "진단 결과 요약"
echo "=========================================="

if [ "$FILE_EXISTS" = false ]; then
    echo "✗ .env.prod 파일이 없습니다."
    echo "  해결 방법: .env.prod 파일을 생성하세요."
elif [ "$CRLF_PROBLEM" = true ]; then
    echo "⚠️  CRLF 문제 발견 (가장 가능성 높은 원인)"
    echo "  해결 방법:"
    echo "    1. dos2unix 설치: sudo yum install dos2unix -y (Amazon Linux 2)"
    echo "    2. 파일 변환: dos2unix .env.prod"
    echo "    3. 또는: sed -i 's/\r$//' .env.prod"
elif [ "$FORMAT_PROBLEM" = true ]; then
    echo "⚠️  환경변수 형식 문제 발견"
    echo "  해결 방법: 변수명=값 형식으로 수정 (공백 제거)"
elif [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "⚠️  누락된 환경변수 발견: ${MISSING_VARS[*]}"
    echo "  해결 방법: .env.prod 파일에 누락된 환경변수를 추가하세요."
elif [ "$CONFIG_OK" = false ]; then
    echo "⚠️  Docker Compose 설정 오류"
    echo "  해결 방법: 위의 오류 메시지를 확인하고 수정하세요."
else
    echo "✓ 기본적인 문제는 발견되지 않았습니다."
    echo "  추가 확인이 필요할 수 있습니다."
fi

echo ""
echo "=========================================="
echo "빠른 해결 스크립트"
echo "=========================================="
echo ""
echo "다음 명령어를 실행하여 문제를 해결할 수 있습니다:"
echo ""
echo "# 1. CRLF 문제 해결"
echo "dos2unix .env.prod"
echo "# 또는"
echo "sed -i 's/\r$//' .env.prod"
echo ""
echo "# 2. 파일 권한 설정"
echo "chmod 600 .env.prod"
echo ""
echo "# 3. 파일 형식 확인"
echo "cat -A .env.prod | head -5"
echo ""
echo "# 4. Docker Compose 설정 확인"
echo "docker-compose -f docker-compose.prod.yml config"
echo ""
echo "=========================================="

