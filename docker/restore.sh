#!/bin/bash

# PerformProject 데이터베이스 복원 스크립트
# 사용법: ./restore.sh <backup_file.sql>

if [ -z "$1" ]; then
    echo "Error: 백업 파일을 지정해주세요."
    echo "사용법: ./restore.sh <backup_file.sql>"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: 백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    exit 1
fi

# 환경변수 로드
source .env

echo "=========================================="
echo "데이터베이스 복원 시작"
echo "Backup file: $BACKUP_FILE"
echo "=========================================="

# 확인 메시지
read -p "정말로 데이터베이스를 복원하시겠습니까? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "복원이 취소되었습니다."
    exit 0
fi

# PostgreSQL 복원
docker exec -i perform_postgres psql -U $POSTGRES_USER -d $POSTGRES_DB < $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "복원 완료!"
else
    echo "복원 실패!"
    exit 1
fi

echo "=========================================="
echo "복원 완료!"
echo "=========================================="

