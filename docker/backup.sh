#!/bin/bash

# PerformProject 데이터베이스 백업 스크립트

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 환경변수 로드
source .env

echo "=========================================="
echo "데이터베이스 백업 시작"
echo "Backup file: $BACKUP_FILE"
echo "=========================================="

# PostgreSQL 백업
docker exec perform_postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "백업 완료: $BACKUP_FILE"
    
    # 압축 (선택사항)
    # gzip $BACKUP_FILE
    # echo "압축 완료: ${BACKUP_FILE}.gz"
    
    # 오래된 백업 파일 삭제 (30일 이상)
    find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
    echo "오래된 백업 파일 삭제 완료"
else
    echo "백업 실패!"
    exit 1
fi

echo "=========================================="
echo "백업 완료!"
echo "=========================================="

