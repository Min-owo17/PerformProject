# 빠른 시작 가이드 - AWS EC2 서버 설정

이 가이드는 AWS EC2 서버에서 PerformProject를 빠르게 설정하는 방법을 안내합니다.

## 📋 단계별 체크리스트

- [ ] 1. AWS EC2 인스턴스 생성
- [ ] 2. 보안 그룹 설정
- [ ] 3. EC2 인스턴스 접속
- [ ] 4. Docker 및 Docker Compose 설치
- [ ] 5. 프로젝트 파일 업로드
- [ ] 6. 환경변수 파일 생성 및 설정
- [ ] 7. 서비스 시작
- [ ] 8. 연결 확인

---

## 1. AWS EC2 인스턴스 생성

### 인스턴스 설정
- **AMI**: Amazon Linux 2 또는 Ubuntu 20.04 LTS
- **인스턴스 타입**: t3.micro (프리 티어) 또는 t3.small
- **스토리지**: 20GB 이상
- **키 페어**: 새로 생성하거나 기존 키 페어 사용

### 보안 그룹 설정
다음 포트를 열어주세요:
- **SSH (22)**: 내 IP만 허용
- **HTTP (80)**: 0.0.0.0/0 (모든 IP)
- **HTTPS (443)**: 0.0.0.0/0 (모든 IP)
- **FastAPI (8000)**: 개발용 (프로덕션에서는 제거)

---

## 2. EC2 인스턴스 접속

### Windows (PowerShell)
```powershell
ssh -i "C:\path\to\your-key.pem" ec2-user@your-ec2-public-ip
```

### Mac/Linux
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

**참고**: Ubuntu인 경우 `ec2-user` 대신 `ubuntu`를 사용하세요.

---

## 3. Docker 및 Docker Compose 설치

### Amazon Linux 2
```bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 확인
docker --version
docker-compose --version

# 로그아웃 후 다시 로그인
exit
```

### Ubuntu
```bash
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 확인
docker --version
docker-compose --version

# 로그아웃 후 다시 로그인
exit
```

---

## 4. 프로젝트 파일 업로드

### Git을 사용한 방법 (권장)
```bash
sudo mkdir -p /opt/performproject
sudo chown ec2-user:ec2-user /opt/performproject  # Amazon Linux 2
# 또는
sudo chown ubuntu:ubuntu /opt/performproject  # Ubuntu

cd /opt/performproject
git clone <your-repository-url> .
```

### SCP를 사용한 방법
```bash
# Windows (PowerShell)
scp -i "C:\path\to\your-key.pem" -r docker\ ec2-user@your-ec2-ip:/opt/performproject/

# Mac/Linux
scp -i your-key.pem -r docker/ ec2-user@your-ec2-ip:/opt/performproject/
```

---

## 5. 환경변수 파일 생성 및 설정

```bash
cd /opt/performproject/docker

# 환경변수 파일 생성
cat > .env.prod << 'EOF'
# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# Redis 설정
REDIS_PASSWORD=your_redis_password_here

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password_here
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=your_jwt_secret_key_here
EOF

# 환경변수 파일 편집 (비밀번호 변경)
nano .env.prod
```

**중요**: 반드시 다음 비밀번호를 변경하세요:
- `POSTGRES_PASSWORD`
- `REDIS_PASSWORD`
- `MINIO_ROOT_PASSWORD`
- `JWT_SECRET_KEY`

강력한 비밀번호 생성:
```bash
openssl rand -base64 32
```

---

## 6. 서비스 시작

```bash
cd /opt/performproject/docker

# 프로덕션 환경으로 서비스 시작
docker-compose -f docker-compose.prod.yml up -d

# 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f
```

---

## 7. 연결 확인

### 컨테이너 상태 확인
```bash
docker-compose -f docker-compose.prod.yml ps
```

모든 컨테이너가 `Up (healthy)` 상태여야 합니다.

### 데이터베이스 연결 테스트
```bash
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db

# 테이블 확인
\dt

# 종료
\q
```

### 백엔드 API 테스트
```bash
curl http://localhost:8000/health
```

### 웹 브라우저에서 확인
- **HTTP**: `http://your-ec2-public-ip`
- **API 문서**: `http://your-ec2-public-ip:8000/docs`

---

## 문제 해결

### Docker 컨테이너가 시작되지 않는 경우
```bash
# 로그 확인
docker-compose -f docker-compose.prod.yml logs

# 특정 서비스 로그 확인
docker-compose -f docker-compose.prod.yml logs postgres
```

### 데이터베이스 연결 실패
```bash
# PostgreSQL 로그 확인
docker-compose -f docker-compose.prod.yml logs postgres

# 환경변수 확인
docker exec perform_postgres_prod env | grep POSTGRES
```

### 포트 충돌
```bash
# 사용 중인 포트 확인
sudo netstat -tulpn | grep :5432
```

---

## 다음 단계

1. **도메인 연결**: Route 53을 사용하여 도메인 연결
2. **SSL 인증서**: Let's Encrypt를 사용하여 HTTPS 설정
3. **모니터링**: CloudWatch를 사용하여 모니터링 설정
4. **백업 자동화**: 정기적인 백업 스크립트 설정

---

## 상세 가이드

더 자세한 내용은 [AWS_EC2_SETUP_GUIDE.md](./AWS_EC2_SETUP_GUIDE.md)를 참조하세요.

---

## 지원

문제가 발생하면 다음을 확인하세요:
1. 로그 파일 확인
2. 환경변수 설정 확인
3. 보안 그룹 설정 확인
4. 네트워크 연결 확인

