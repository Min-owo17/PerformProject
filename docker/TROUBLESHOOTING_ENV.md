# 환경변수 오류 해결 가이드

## "variable is not set" 오류 원인 및 해결 방법

Docker Compose에서 환경변수를 읽지 못할 때 발생하는 오류입니다.

---

## 🔍 가능한 원인들

### 1. .env.prod 파일 위치 문제

**문제**: `.env.prod` 파일이 `docker-compose.prod.yml`과 같은 디렉토리에 없음

**확인 방법**:
```bash
# 프로젝트 디렉토리로 이동
cd /opt/performproject/docker

# 파일 위치 확인
ls -la .env.prod
ls -la docker-compose.prod.yml

# 현재 디렉토리 확인
pwd
```

**해결 방법**:
```bash
# .env.prod 파일이 다른 위치에 있는 경우
# 올바른 위치로 이동
mv /path/to/.env.prod /opt/performproject/docker/.env.prod

# 또는 심볼릭 링크 생성
ln -s /path/to/.env.prod /opt/performproject/docker/.env.prod
```

### 2. 파일 권한 문제

**문제**: `.env.prod` 파일에 읽기 권한이 없음

**확인 방법**:
```bash
# 파일 권한 확인
ls -la .env.prod

# 출력 예시:
# -rw-r--r-- 1 ec2-user ec2-user 1234 Jan 1 12:00 .env.prod
```

**해결 방법**:
```bash
# 파일 권한 설정
chmod 600 .env.prod

# 파일 소유자 확인 및 변경
ls -la .env.prod
sudo chown ec2-user:ec2-user .env.prod  # Amazon Linux 2
# 또는
sudo chown ubuntu:ubuntu .env.prod  # Ubuntu
```

### 3. 파일 형식 문제 (줄바꿈 문자)

**문제**: Windows에서 생성한 파일을 Linux로 업로드할 때 CRLF(\\r\\n) 문제

**확인 방법**:
```bash
# 파일 형식 확인
file .env.prod

# CRLF 문자 확인
cat -A .env.prod | head -5

# CRLF가 있으면 ^M$ 표시가 보임
```

**해결 방법**:
```bash
# dos2unix 설치 (없는 경우)
sudo yum install dos2unix -y  # Amazon Linux 2
# 또는
sudo apt install dos2unix -y  # Ubuntu

# 파일 변환
dos2unix .env.prod

# 또는 sed 사용
sed -i 's/\r$//' .env.prod

# 또는 tr 사용
tr -d '\r' < .env.prod > .env.prod.tmp
mv .env.prod.tmp .env.prod
```

### 4. 파일 인코딩 문제

**문제**: 파일 인코딩이 UTF-8이 아닌 경우

**확인 방법**:
```bash
# 파일 인코딩 확인
file -i .env.prod

# 출력 예시:
# .env.prod: text/plain; charset=utf-8
```

**해결 방법**:
```bash
# UTF-8로 변환
iconv -f ISO-8859-1 -t UTF-8 .env.prod > .env.prod.utf8
mv .env.prod.utf8 .env.prod
```

### 5. 환경변수 형식 문제

**문제**: 환경변수 값에 공백, 특수문자, 따옴표 등이 잘못 사용됨

**확인 방법**:
```bash
# .env.prod 파일 내용 확인
cat .env.prod

# 문제가 있는 형식:
# POSTGRES_PASSWORD = my password  # 공백 있음 (잘못됨)
# POSTGRES_PASSWORD="my password"  # 따옴표 있음 (불필요)
# POSTGRES_PASSWORD=my password    # 값에 공백 있음 (따옴표 필요)

# 올바른 형식:
# POSTGRES_PASSWORD=my_password    # 공백 없음
# POSTGRES_PASSWORD=myPassword123  # 공백 없음
```

**해결 방법**:
```bash
# .env.prod 파일 편집
nano .env.prod
# 또는
vim .env.prod

# 각 줄이 다음과 같은 형식이어야 함:
# 변수명=값
# 공백 없이 작성
# 주석은 #로 시작
```

### 6. 환경변수 이름 불일치

**문제**: `.env.prod` 파일의 변수명과 `docker-compose.prod.yml`에서 사용하는 변수명이 일치하지 않음

**확인 방법**:
```bash
# docker-compose.prod.yml에서 사용하는 변수 확인
grep -E '\$\{[A-Z_]+\}' docker-compose.prod.yml

# .env.prod 파일의 변수 확인
grep -v '^#' .env.prod | grep -v '^$' | cut -d'=' -f1

# 두 결과 비교
```

**해결 방법**:
```bash
# 필요한 환경변수 확인
# docker-compose.prod.yml에서 사용하는 변수:
# - POSTGRES_USER
# - POSTGRES_PASSWORD
# - POSTGRES_DB
# - REDIS_PASSWORD
# - MINIO_ROOT_USER
# - MINIO_ROOT_PASSWORD
# - MINIO_BUCKET
# - JWT_SECRET_KEY (백엔드에서 사용)

# .env.prod 파일에 모든 변수가 있는지 확인
grep -E "POSTGRES_USER|POSTGRES_PASSWORD|POSTGRES_DB|REDIS_PASSWORD|MINIO_ROOT_USER|MINIO_ROOT_PASSWORD|MINIO_BUCKET" .env.prod
```

### 7. env_file 경로 문제

**문제**: `docker-compose.prod.yml`에서 `env_file` 경로가 잘못됨

**확인 방법**:
```bash
# docker-compose.prod.yml에서 env_file 확인
grep -A 2 "env_file" docker-compose.prod.yml

# 출력 예시:
# env_file: .env.prod  # 상대 경로 (올바름)
# env_file: /opt/performproject/docker/.env.prod  # 절대 경로 (가능)
# env_file: ../.env.prod  # 잘못된 경로
```

**해결 방법**:
```bash
# docker-compose.prod.yml 파일 확인
cat docker-compose.prod.yml | grep -A 2 "env_file"

# env_file이 .env.prod로 설정되어 있고,
# docker-compose.prod.yml과 같은 디렉토리에 .env.prod가 있어야 함
```

### 8. 숨겨진 문자 문제

**문제**: 파일에 보이지 않는 특수문자나 BOM이 있음

**확인 방법**:
```bash
# 파일을 hex로 확인
hexdump -C .env.prod | head -20

# BOM 확인 (UTF-8 BOM: EF BB BF)
```

**해결 방법**:
```bash
# BOM 제거
sed -i '1s/^\xEF\xBB\xBF//' .env.prod

# 또는 새로 파일 생성
cat > .env.prod << 'EOF'
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=perform_db
REDIS_PASSWORD=your_redis_password
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password
MINIO_BUCKET=perform-audio
JWT_SECRET_KEY=your_jwt_secret_key
EOF
```

---

## 🔧 종합 진단 스크립트

다음 스크립트로 모든 문제를 한 번에 확인할 수 있습니다:

```bash
#!/bin/bash

echo "=========================================="
echo "환경변수 오류 진단 스크립트"
echo "=========================================="

# 프로젝트 디렉토리 확인
cd /opt/performproject/docker || exit 1

echo ""
echo "1. 파일 위치 확인..."
if [ -f ".env.prod" ]; then
    echo "  ✓ .env.prod 파일 존재"
    echo "  위치: $(pwd)/.env.prod"
else
    echo "  ✗ .env.prod 파일 없음"
    echo "  현재 디렉토리: $(pwd)"
    echo "  파일 목록:"
    ls -la | grep env
    exit 1
fi

echo ""
echo "2. 파일 권한 확인..."
PERMISSIONS=$(stat -c "%a" .env.prod 2>/dev/null || stat -f "%OLp" .env.prod 2>/dev/null)
echo "  권한: $PERMISSIONS"
if [ "$PERMISSIONS" != "600" ]; then
    echo "  ⚠️  권한이 600이 아닙니다. 수정 권장: chmod 600 .env.prod"
fi

echo ""
echo "3. 파일 형식 확인..."
FILE_TYPE=$(file .env.prod)
echo "  $FILE_TYPE"

# CRLF 확인
if grep -q $'\r' .env.prod; then
    echo "  ⚠️  CRLF 문자 발견 (Windows 형식)"
    echo "  수정 방법: dos2unix .env.prod"
else
    echo "  ✓ LF 형식 (Linux 형식)"
fi

echo ""
echo "4. 파일 인코딩 확인..."
ENCODING=$(file -i .env.prod | cut -d'=' -f2)
echo "  인코딩: $ENCODING"

echo ""
echo "5. 환경변수 확인..."
REQUIRED_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "REDIS_PASSWORD" "MINIO_ROOT_USER" "MINIO_ROOT_PASSWORD" "MINIO_BUCKET")

for VAR in "${REQUIRED_VARS[@]}"; do
    if grep -q "^${VAR}=" .env.prod; then
        echo "  ✓ $VAR"
    else
        echo "  ✗ $VAR 없음"
    fi
done

echo ""
echo "6. 환경변수 형식 확인..."
# 공백이 있는 변수 확인
if grep -q " = " .env.prod; then
    echo "  ⚠️  공백이 있는 변수 발견 (변수명 = 값 형식)"
    echo "  수정 필요: 변수명=값 형식으로 변경"
else
    echo "  ✓ 변수 형식 올바름"
fi

# 빈 값 확인
if grep -q "=$" .env.prod; then
    echo "  ⚠️  빈 값이 있는 변수 발견"
    grep "=$" .env.prod
else
    echo "  ✓ 모든 변수에 값이 있음"
fi

echo ""
echo "7. Docker Compose 설정 확인..."
if docker-compose -f docker-compose.prod.yml config > /dev/null 2>&1; then
    echo "  ✓ Docker Compose 설정 올바름"
else
    echo "  ✗ Docker Compose 설정 오류"
    echo "  오류 내용:"
    docker-compose -f docker-compose.prod.yml config 2>&1 | head -10
fi

echo ""
echo "8. 환경변수 로드 테스트..."
# 환경변수 로드 테스트
set -a
source .env.prod 2>/dev/null
set +a

if [ -n "$POSTGRES_USER" ]; then
    echo "  ✓ POSTGRES_USER: $POSTGRES_USER"
else
    echo "  ✗ POSTGRES_USER 로드 실패"
fi

if [ -n "$REDIS_PASSWORD" ]; then
    echo "  ✓ REDIS_PASSWORD: 설정됨 (길이: ${#REDIS_PASSWORD})"
else
    echo "  ✗ REDIS_PASSWORD 로드 실패"
fi

echo ""
echo "=========================================="
echo "진단 완료"
echo "=========================================="
```

스크립트 사용:
```bash
# 스크립트 생성
cat > /opt/performproject/docker/diagnose-env.sh << 'EOF'
# 위 스크립트 내용
EOF

# 실행 권한 부여
chmod +x /opt/performproject/docker/diagnose-env.sh

# 실행
/opt/performproject/docker/diagnose-env.sh
```

---

## 🚀 빠른 해결 방법

### 방법 1: .env.prod 파일 재생성

```bash
cd /opt/performproject/docker

# 기존 파일 백업
cp .env.prod .env.prod.backup

# 새로 파일 생성 (Linux 형식)
cat > .env.prod << 'EOF'
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata
REDIS_PASSWORD=your_redis_password_here
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password_here
MINIO_BUCKET=perform-audio
JWT_SECRET_KEY=your_jwt_secret_key_here
EOF

# 파일 권한 설정
chmod 600 .env.prod

# 파일 형식 확인
file .env.prod
dos2unix .env.prod  # CRLF 문제가 있는 경우

# Docker Compose 설정 확인
docker-compose -f docker-compose.prod.yml config
```

### 방법 2: 수동으로 문제 해결

```bash
cd /opt/performproject/docker

# 1. 파일 위치 확인
pwd
ls -la .env.prod

# 2. 파일 권한 수정
chmod 600 .env.prod

# 3. 파일 형식 변환 (Windows → Linux)
dos2unix .env.prod

# 4. 파일 내용 확인
cat .env.prod

# 5. 환경변수 형식 확인 (공백, 따옴표 제거)
nano .env.prod

# 6. Docker Compose 설정 검증
docker-compose -f docker-compose.prod.yml config

# 7. 서비스 시작
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📋 체크리스트

문제 해결을 위해 다음을 확인하세요:

- [ ] .env.prod 파일이 docker-compose.prod.yml과 같은 디렉토리에 있는가?
- [ ] .env.prod 파일 권한이 600인가?
- [ ] 파일이 Linux 형식(LF)인가? (CRLF가 아닌지 확인)
- [ ] 파일 인코딩이 UTF-8인가?
- [ ] 모든 필수 환경변수가 있는가?
- [ ] 환경변수 형식이 올바른가? (변수명=값, 공백 없음)
- [ ] 환경변수 값에 특수문자가 올바르게 처리되었는가?
- [ ] docker-compose.prod.yml에서 env_file 경로가 올바른가?
- [ ] Docker Compose 설정이 올바른가? (config 명령어로 확인)

---

## 🔍 오류 메시지별 해결 방법

### "The 'POSTGRES_USER' variable is not set"

**원인**: POSTGRES_USER 환경변수가 .env.prod에 없거나 로드되지 않음

**해결**:
```bash
# .env.prod 파일 확인
grep POSTGRES_USER .env.prod

# 없으면 추가
echo "POSTGRES_USER=perform_user" >> .env.prod
```

### "The 'REDIS_PASSWORD' variable is not set"

**원인**: REDIS_PASSWORD 환경변수가 .env.prod에 없거나 로드되지 않음

**해결**:
```bash
# .env.prod 파일 확인
grep REDIS_PASSWORD .env.prod

# 없으면 추가
echo "REDIS_PASSWORD=your_redis_password" >> .env.prod
```

### "The 'MINIO_BUCKET' variable is not set"

**원인**: MINIO_BUCKET 환경변수가 .env.prod에 없거나 로드되지 않음

**해결**:
```bash
# .env.prod 파일 확인
grep MINIO_BUCKET .env.prod

# 없으면 추가
echo "MINIO_BUCKET=perform-audio" >> .env.prod
```

---

## 💡 추가 팁

### 환경변수 파일 검증

```bash
# .env.prod 파일 검증 스크립트
validate_env() {
    local file="$1"
    echo "환경변수 파일 검증: $file"
    
    # 빈 줄과 주석 제외하고 검증
    while IFS='=' read -r key value; do
        # 주석 스킵
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        
        # 키에 공백이 있는지 확인
        if [[ "$key" =~ [[:space:]] ]]; then
            echo "경고: '$key'에 공백이 있습니다."
        fi
        
        # 값이 비어있는지 확인
        if [[ -z "$value" ]]; then
            echo "경고: '$key'의 값이 비어있습니다."
        fi
    done < "$file"
}

validate_env .env.prod
```

### 환경변수 테스트

```bash
# 환경변수 로드 테스트
set -a
source .env.prod
set +a

# 변수 확인
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "REDIS_PASSWORD: ${REDIS_PASSWORD:0:5}..." # 처음 5자만 표시
```

---

## 📞 문제가 해결되지 않는 경우

1. **로그 확인**: `docker-compose -f docker-compose.prod.yml config` 실행
2. **환경변수 확인**: `docker-compose -f docker-compose.prod.yml config | grep -A 5 "postgres:"`
3. **파일 재생성**: .env.prod 파일을 새로 생성
4. **권한 확인**: 파일 권한 및 소유자 확인
5. **형식 확인**: 파일 형식 및 인코딩 확인

