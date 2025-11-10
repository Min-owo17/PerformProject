# AWS EC2 서버 설정 및 데이터베이스 구축 요약

이 문서는 AWS EC2 서버에서 PerformProject를 설정하는 전체 프로세스를 요약합니다.

## 📋 전체 프로세스 개요

1. **AWS EC2 인스턴스 생성** → 서버 준비
2. **보안 그룹 설정** → 포트 및 접근 권한 설정
3. **EC2 인스턴스 접속** → SSH를 통한 서버 접속
4. **Docker 설치** → 컨테이너 환경 구축
5. **프로젝트 파일 업로드** → 코드 및 설정 파일 업로드
6. **환경변수 설정** → 데이터베이스 및 서비스 설정
7. **서비스 시작** → Docker Compose로 서비스 시작
8. **연결 확인** → 데이터베이스 및 API 연결 테스트

---

## 🚀 빠른 시작 (5분 가이드)

### 1단계: AWS EC2 인스턴스 생성
- AWS 콘솔에서 EC2 인스턴스 생성
- Amazon Linux 2 또는 Ubuntu 20.04 LTS 선택
- t3.micro (프리 티어) 또는 t3.small 선택
- 키 페어 생성 및 다운로드

### 2단계: 보안 그룹 설정
- SSH (22): 내 IP만 허용
- HTTP (80): 모든 IP 허용
- HTTPS (443): 모든 IP 허용
- FastAPI (8000): 개발용 (프로덕션에서는 제거)

### 3단계: EC2 인스턴스 접속
```bash
ssh -i "your-key.pem" ec2-user@your-ec2-public-ip
```

### 4단계: Docker 설치
```bash
# Amazon Linux 2
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 로그아웃 후 다시 로그인
exit
```

### 5단계: 프로젝트 파일 업로드
```bash
# Git 사용 (권장)
sudo mkdir -p /opt/performproject
sudo chown ec2-user:ec2-user /opt/performproject
cd /opt/performproject
git clone <your-repository-url> .
```

### 6단계: 환경변수 설정
```bash
cd /opt/performproject/docker

# 환경변수 파일 생성 (자동 생성 스크립트 사용)
chmod +x setup-env.sh
./setup-env.sh prod

# 또는 수동 생성
cat > .env.prod << 'EOF'
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=your_strong_password
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata
REDIS_PASSWORD=your_redis_password
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password
MINIO_BUCKET=perform-audio
JWT_SECRET_KEY=your_jwt_secret_key
EOF

# 파일 권한 설정
chmod 600 .env.prod
```

### 7단계: 서비스 시작
```bash
cd /opt/performproject/docker
docker-compose -f docker-compose.prod.yml up -d
```

### 8단계: 연결 확인
```bash
# 컨테이너 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 데이터베이스 연결 테스트
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db

# 백엔드 API 테스트
curl http://localhost:8000/health
```

---

## 📚 상세 가이드

### 빠른 시작 가이드
- **[QUICK_START.md](./QUICK_START.md)** - 단계별 빠른 설정 가이드

### 상세 설정 가이드
- **[AWS_EC2_SETUP_GUIDE.md](./AWS_EC2_SETUP_GUIDE.md)** - 상세한 설정 및 문제 해결 가이드
- **[FILEZILLA_UPLOAD_GUIDE.md](./FILEZILLA_UPLOAD_GUIDE.md)** - FileZilla를 사용한 파일 업로드 가이드

### 환경변수 설정 가이드
- **[ENV.md](./ENV.md)** - 환경변수 설정 방법

### 기타 가이드
- **[README.md](./README.md)** - 전체 Docker 환경 설정 가이드
- **[BACKUP_RESTORE.md](./BACKUP_RESTORE.md)** - 데이터베이스 백업 및 복원
- **[OPERATIONS_SECURITY.md](./OPERATIONS_SECURITY.md)** - 운영 및 보안 가이드

---

## 🔧 주요 명령어

### 서비스 관리
```bash
# 서비스 시작
docker-compose -f docker-compose.prod.yml up -d

# 서비스 중지
docker-compose -f docker-compose.prod.yml down

# 서비스 재시작
docker-compose -f docker-compose.prod.yml restart

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f

# 상태 확인
docker-compose -f docker-compose.prod.yml ps
```

### 데이터베이스 관리
```bash
# 데이터베이스 접속
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db

# 백업
./backup.sh

# 복원
./restore.sh backup_file.sql
```

### 환경변수 관리
```bash
# 환경변수 파일 생성
./setup-env.sh prod

# 환경변수 확인
docker-compose -f docker-compose.prod.yml config
```

---

## 🔒 보안 체크리스트

- [ ] 강력한 비밀번호 사용 (최소 16자, 대소문자, 숫자, 특수문자)
- [ ] 환경변수 파일 권한 설정 (chmod 600)
- [ ] 보안 그룹 설정 (필요한 포트만 열기)
- [ ] SSH 키 파일 안전하게 보관
- [ ] 정기적인 시스템 업데이트
- [ ] 로그 모니터링 설정
- [ ] 백업 자동화 설정

---

## 🐛 문제 해결

### 일반적인 문제
1. **Docker 컨테이너가 시작되지 않는 경우**
   - 로그 확인: `docker-compose -f docker-compose.prod.yml logs`
   - 환경변수 확인: `docker-compose -f docker-compose.prod.yml config`

2. **데이터베이스 연결 실패**
   - PostgreSQL 로그 확인: `docker-compose -f docker-compose.prod.yml logs postgres`
   - 환경변수 확인: `docker exec perform_postgres_prod env | grep POSTGRES`

3. **포트 충돌**
   - 사용 중인 포트 확인: `sudo netstat -tulpn | grep :5432`
   - 프로세스 종료: `sudo kill -9 <PID>`

더 자세한 문제 해결 방법은 [AWS_EC2_SETUP_GUIDE.md](./AWS_EC2_SETUP_GUIDE.md)의 "문제 해결" 섹션을 참조하세요.

---

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. 로그 파일 확인
2. 환경변수 설정 확인
3. 보안 그룹 설정 확인
4. 네트워크 연결 확인

추가 도움이 필요하면 프로젝트 이슈를 생성하세요.

---

## 다음 단계

1. **도메인 연결**: Route 53을 사용하여 도메인 연결
2. **SSL 인증서**: Let's Encrypt를 사용하여 HTTPS 설정
3. **모니터링**: CloudWatch를 사용하여 모니터링 설정
4. **백업 자동화**: 정기적인 백업 스크립트 설정
5. **CI/CD 파이프라인**: GitHub Actions 또는 AWS CodePipeline 설정

