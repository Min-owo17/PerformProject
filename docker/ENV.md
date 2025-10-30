### 11.4 환경변수 예시 (docker/.env)

```env
# Postgres
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppass
POSTGRES_DB=perform
PGDATA=/var/lib/postgresql/data/pgdata

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin1234

# Redis
REDIS_PASSWORD=redispass

# MinIO (S3 대체)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET=perform-audio
```


