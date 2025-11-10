### 11.3 디렉터리 구조 제안

```
project-root/
  docker/
    .env
    docker-compose.yml
    postgres/
      initdb/   # (옵션) 초기 스키마/시드 SQL
      data/     # 볼륨 마운트 대상(로컬 개발시만)
```








