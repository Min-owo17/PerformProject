### 11.10 백업/복구 가이드 (개발 환경)

- 백업
```bash
docker exec -i perform_postgres pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > backup.sql
```

- 복구
```bash
cat backup.sql | docker exec -i perform_postgres psql -U $POSTGRES_USER -d $POSTGRES_DB
```








