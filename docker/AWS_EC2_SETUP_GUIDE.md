# AWS EC2 서버 설정 및 데이터베이스 구축 가이드

이 가이드는 AWS EC2 서버에서 PerformProject를 설정하고 PostgreSQL 데이터베이스를 구축하는 방법을 단계별로 안내합니다.

## 📋 목차

1. [사전 준비사항](#사전-준비사항)
2. [AWS EC2 인스턴스 생성](#aws-ec2-인스턴스-생성)
3. [보안 그룹 설정](#보안-그룹-설정)
4. [EC2 인스턴스 접속](#ec2-인스턴스-접속)
5. [Docker 및 Docker Compose 설치](#docker-및-docker-compose-설치)
6. [프로젝트 파일 업로드](#프로젝트-파일-업로드)
7. [환경변수 설정](#환경변수-설정)
8. [데이터베이스 초기화](#데이터베이스-초기화)
9. [서비스 시작](#서비스-시작)
10. [연결 확인 및 테스트](#연결-확인-및-테스트)
11. [문제 해결](#문제-해결)

---

## 사전 준비사항

### 필수 요구사항
- AWS 계정
- EC2 인스턴스에 대한 접근 권한
- SSH 클라이언트 (Windows: PuTTY 또는 PowerShell, Mac/Linux: Terminal)
- 프로젝트 파일 (로컬에 준비되어 있어야 함)

### 권장 사양
- **인스턴스 타입**: t3.micro (프리 티어) 또는 t3.small 이상
- **운영체제**: Amazon Linux 2 또는 Ubuntu 20.04 LTS
- **스토리지**: 최소 20GB (데이터베이스 및 파일 저장용)
- **메모리**: 최소 1GB (2GB 권장)

---

## AWS EC2 인스턴스 생성

### 1. EC2 인스턴스 시작

1. **AWS 콘솔 접속**
   - AWS Management Console에 로그인
   - EC2 서비스로 이동

2. **인스턴스 시작**
   - "인스턴스 시작" 버튼 클릭
   - 이름 및 태그 설정 (예: `perform-project-server`)

3. **AMI 선택**
   - Amazon Linux 2 또는 Ubuntu 20.04 LTS 선택 (프리 티어 가능)

4. **인스턴스 타입 선택**
   - t3.micro (프리 티어) 또는 t3.small 선택

5. **키 페어 생성/선택**
   - 새 키 페어 생성 또는 기존 키 페어 선택
   - 키 페어 이름 입력 (예: `perform-project-key`)
   - 키 페어 다운로드 (`.pem` 파일) - **안전하게 보관**

6. **네트워크 설정**
   - VPC 및 서브넷 선택 (기본값 사용 가능)
   - 자동 할당 퍼블릭 IP: 활성화
   - 보안 그룹은 다음 단계에서 설정

7. **스토리지 구성**
   - 볼륨 크기: 20GB 이상
   - 볼륨 타입: gp3 (권장)

8. **인스턴스 시작**
   - "인스턴스 시작" 버튼 클릭

---

## 보안 그룹 설정

### 1. 보안 그룹 생성

1. **보안 그룹 생성**
   - EC2 콘솔에서 "보안 그룹" 메뉴 선택
   - "보안 그룹 생성" 버튼 클릭

2. **기본 세부 정보**
   - 이름: `perform-project-sg`
   - 설명: `PerformProject 서버 보안 그룹`
   - VPC: 기본 VPC 선택

3. **인바운드 규칙 추가**

   | 유형 | 프로토콜 | 포트 범위 | 소스 | 설명 |
   |------|---------|----------|------|------|
   | SSH | TCP | 22 | 내 IP | SSH 접속 |
   | HTTP | TCP | 80 | 0.0.0.0/0 | 웹 접속 |
   | HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS 접속 |
   | 사용자 지정 TCP | TCP | 8000 | 0.0.0.0/0 | FastAPI (개발용, 프로덕션에서는 제거) |
   | 사용자 지정 TCP | TCP | 5432 | 보안 그룹 ID | PostgreSQL (내부 네트워크만) |
   | 사용자 지정 TCP | TCP | 6379 | 보안 그룹 ID | Redis (내부 네트워크만) |
   | 사용자 지정 TCP | TCP | 9000 | 보안 그룹 ID | MinIO API (내부 네트워크만) |
   | 사용자 지정 TCP | TCP | 9001 | 보안 그룹 ID | MinIO Console (내부 네트워크만) |

   **주의**: 프로덕션 환경에서는 PostgreSQL, Redis, MinIO 포트는 보안 그룹 내부에서만 접근 가능하도록 설정하세요.

4. **아웃바운드 규칙**
   - 기본값 사용 (모든 트래픽 허용)

5. **보안 그룹 연결**
   - 생성한 EC2 인스턴스에 보안 그룹 연결
   - 인스턴스 선택 → "보안" 탭 → "보안 그룹 편집" → 생성한 보안 그룹 선택

---

## EC2 인스턴스 접속

### Windows (PowerShell)

1. **키 파일 권한 설정** (처음 한 번만)
   ```powershell
   # 키 파일의 경로를 올바르게 지정
   icacls "C:\path\to\perform-project-key.pem" /inheritance:r
   icacls "C:\path\to\perform-project-key.pem" /grant:r "%username%:R"
   ```

2. **SSH 접속**
   ```powershell
   ssh -i "C:\path\to\perform-project-key.pem" ec2-user@your-ec2-public-ip
   ```
   또는 Amazon Linux 2가 아닌 경우:
   ```powershell
   ssh -i "C:\path\to\perform-project-key.pem" ubuntu@your-ec2-public-ip
   ```

### Mac/Linux

1. **키 파일 권한 설정**
   ```bash
   chmod 400 perform-project-key.pem
   ```

2. **SSH 접속**
   ```bash
   ssh -i perform-project-key.pem ec2-user@your-ec2-public-ip
   ```
   또는 Ubuntu인 경우:
   ```bash
   ssh -i perform-project-key.pem ubuntu@your-ec2-public-ip
   ```

---

## Docker 및 Docker Compose 설치

### Amazon Linux 2

```bash
# 시스템 업데이트
sudo yum update -y

# Docker 설치
sudo yum install docker -y

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가 (sudo 없이 docker 명령어 사용 가능)
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 설치 확인
docker --version
docker-compose --version

# 로그아웃 후 다시 로그인하여 docker 그룹 변경사항 적용
exit
```

### Ubuntu

```bash
# 시스템 업데이트
sudo apt update -y
sudo apt upgrade -y

# 필요한 패키지 설치
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Docker 공식 GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker 저장소 추가
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -a -G docker ubuntu

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 설치 확인
docker --version
docker-compose --version

# 로그아웃 후 다시 로그인
exit
```

**중요**: 로그아웃 후 다시 로그인하여 docker 그룹 변경사항을 적용해야 합니다.

---

## 프로젝트 파일 업로드

### 방법 1: Git을 사용한 업로드 (권장)

```bash
# Git 설치 (Amazon Linux 2)
sudo yum install git -y

# Git 설치 (Ubuntu)
sudo apt install git -y

# 프로젝트 디렉토리 생성
sudo mkdir -p /opt/performproject
sudo chown ec2-user:ec2-user /opt/performproject  # Amazon Linux 2
# 또는
sudo chown ubuntu:ubuntu /opt/performproject  # Ubuntu

# 프로젝트 클론
cd /opt/performproject
git clone <your-repository-url> .

# 또는 직접 파일 업로드한 경우
# scp -r docker/ ec2-user@your-ec2-ip:/opt/performproject/
```

### 방법 2: SCP를 사용한 업로드

**Windows (PowerShell)**
```powershell
scp -i "C:\path\to\perform-project-key.pem" -r docker\ ec2-user@your-ec2-ip:/opt/performproject/
```

**Mac/Linux**
```bash
scp -i perform-project-key.pem -r docker/ ec2-user@your-ec2-ip:/opt/performproject/
```

### 방법 3: SFTP 클라이언트 사용

- WinSCP (Windows)
- FileZilla (모든 플랫폼)
- VS Code의 SFTP 확장

---

## 환경변수 설정

```bash
# 프로젝트 디렉토리로 이동
cd /opt/performproject/docker

# 환경변수 파일 생성 (프로덕션 환경)
cp .env.example .env.prod

# 환경변수 파일 편집
nano .env.prod
# 또는
vim .env.prod
```

### 필수 환경변수 수정

`.env.prod` 파일에서 다음 값들을 반드시 수정하세요:

```env
# PostgreSQL 설정
POSTGRES_USER=perform_user
POSTGRES_PASSWORD=강력한_비밀번호_생성  # 반드시 변경!
POSTGRES_DB=perform_db
PGDATA=/var/lib/postgresql/data/pgdata

# Redis 설정
REDIS_PASSWORD=강력한_Redis_비밀번호  # 반드시 변경!

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=강력한_MinIO_비밀번호  # 반드시 변경!
MINIO_BUCKET=perform-audio

# JWT 설정
JWT_SECRET_KEY=강력한_JWT_시크릿_키_생성  # 반드시 변경!
```

**비밀번호 생성 팁**:
```bash
# 강력한 비밀번호 생성 (선택사항)
openssl rand -base64 32
```

---

## 데이터베이스 초기화

데이터베이스는 Docker Compose로 컨테이너를 시작할 때 자동으로 초기화됩니다.

초기화 스크립트 위치:
- `docker/postgres/initdb/01_init_schema.sql` - 데이터베이스 스키마
- `docker/postgres/initdb/02_init_data.sql` - 초기 데이터 (선택사항)

**수동 초기화가 필요한 경우**:

```bash
# PostgreSQL 컨테이너에 접속
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db

# SQL 파일 실행
docker exec -i perform_postgres_prod psql -U perform_user -d perform_db < postgres/initdb/01_init_schema.sql
```

---

## 서비스 시작

### 1. 프로덕션 환경으로 서비스 시작

```bash
# 프로젝트 디렉토리로 이동
cd /opt/performproject/docker

# Docker Compose로 서비스 시작
docker-compose -f docker-compose.prod.yml up -d

# 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f
```

### 2. 서비스 시작 순서 확인

서비스는 다음 순서로 시작됩니다:
1. PostgreSQL (데이터베이스)
2. Redis (캐시)
3. MinIO (객체 스토리지)
4. Backend (FastAPI)
5. Nginx (리버스 프록시)

### 3. 서비스 재시작

```bash
# 모든 서비스 재시작
docker-compose -f docker-compose.prod.yml restart

# 특정 서비스만 재시작
docker-compose -f docker-compose.prod.yml restart postgres
docker-compose -f docker-compose.prod.yml restart backend
```

### 4. 서비스 중지

```bash
# 서비스 중지 (데이터는 유지)
docker-compose -f docker-compose.prod.yml down

# 서비스 중지 및 볼륨 삭제 (데이터 삭제)
docker-compose -f docker-compose.prod.yml down -v
```

---

## 연결 확인 및 테스트

### 1. 컨테이너 상태 확인

```bash
# 모든 컨테이너 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 예상 출력:
# NAME                      STATUS          PORTS
# perform_postgres_prod     Up (healthy)    
# perform_redis_prod        Up (healthy)    
# perform_minio_prod        Up (healthy)    
# perform_backend_prod      Up              
# perform_nginx_prod        Up              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

### 2. 데이터베이스 연결 테스트

```bash
# PostgreSQL 컨테이너에 접속
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db

# 데이터베이스에서 테이블 확인
\dt

# 사용자 확인
SELECT * FROM users;

# 종료
\q
```

### 3. 백엔드 API 테스트

```bash
# 백엔드 헬스 체크
curl http://localhost:8000/health

# 또는 EC2 퍼블릭 IP를 사용
curl http://your-ec2-public-ip:8000/health
```

### 4. 웹 브라우저에서 확인

- **HTTP**: `http://your-ec2-public-ip`
- **HTTPS**: `https://your-ec2-public-ip` (SSL 인증서 설정 후)

---

## 문제 해결

### 1. Docker 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose -f docker-compose.prod.yml logs

# 특정 서비스 로그 확인
docker-compose -f docker-compose.prod.yml logs postgres
docker-compose -f docker-compose.prod.yml logs backend

# 컨테이너 상태 확인
docker-compose -f docker-compose.prod.yml ps
```

### 2. 데이터베이스 연결 실패

```bash
# PostgreSQL 컨테이너 로그 확인
docker-compose -f docker-compose.prod.yml logs postgres

# 환경변수 확인
docker exec perform_postgres_prod env | grep POSTGRES

# PostgreSQL 컨테이너에 직접 접속 테스트
docker exec -it perform_postgres_prod psql -U perform_user -d perform_db
```

### 3. 포트 충돌

```bash
# 사용 중인 포트 확인
sudo netstat -tulpn | grep :5432
sudo netstat -tulpn | grep :8000

# 프로세스 종료 (필요한 경우)
sudo kill -9 <PID>
```

### 4. 디스크 공간 부족

```bash
# 디스크 사용량 확인
df -h

# Docker 이미지 및 컨테이너 정리
docker system prune -a

# 볼륨 정리 (주의: 데이터 삭제됨)
docker volume prune
```

### 5. 권한 문제

```bash
# Docker 그룹에 사용자 추가 확인
groups

# Docker 서비스 재시작
sudo systemctl restart docker

# 로그아웃 후 다시 로그인
exit
```

### 6. 백엔드 서버 오류

```bash
# 백엔드 로그 확인
docker-compose -f docker-compose.prod.yml logs backend

# 백엔드 컨테이너 재시작
docker-compose -f docker-compose.prod.yml restart backend

# 백엔드 컨테이너 내부 접속
docker exec -it perform_backend_prod bash
```

---

## 추가 설정

### 1. 자동 시작 설정 (시스템 재부팅 시)

```bash
# systemd 서비스 파일 생성
sudo nano /etc/systemd/system/performproject.service
```

서비스 파일 내용:
```ini
[Unit]
Description=PerformProject Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/performproject/docker
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

서비스 활성화:
```bash
sudo systemctl daemon-reload
sudo systemctl enable performproject.service
sudo systemctl start performproject.service
```

### 2. 로그 로테이션 설정

```bash
# Docker 로그 로테이션 설정
sudo nano /etc/docker/daemon.json
```

파일 내용:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Docker 재시작:
```bash
sudo systemctl restart docker
```

### 3. 백업 스크립트 설정

```bash
# 백업 스크립트에 실행 권한 부여
chmod +x /opt/performproject/docker/backup.sh

# Cron 작업 추가 (매일 새벽 2시에 백업)
crontab -e
```

Cron 작업 추가:
```cron
0 2 * * * /opt/performproject/docker/backup.sh
```

---

## 보안 권장사항

1. **강력한 비밀번호 사용**: 모든 비밀번호를 강력하게 설정하세요.
2. **SSH 키 보안**: SSH 키 파일을 안전하게 보관하세요.
3. **보안 그룹 설정**: 필요한 포트만 열어두세요.
4. **정기 업데이트**: 시스템 및 Docker 이미지를 정기적으로 업데이트하세요.
5. **방화벽 설정**: UFW 또는 iptables를 사용하여 추가 보안 설정을 고려하세요.
6. **SSL/TLS 인증서**: Let's Encrypt를 사용하여 HTTPS를 설정하세요.
7. **로그 모니터링**: CloudWatch Logs를 사용하여 로그를 모니터링하세요.

---

## 다음 단계

1. **도메인 연결**: Route 53을 사용하여 도메인을 연결하세요.
2. **SSL 인증서 설정**: Let's Encrypt를 사용하여 SSL 인증서를 설정하세요.
3. **모니터링 설정**: CloudWatch를 사용하여 모니터링을 설정하세요.
4. **백업 자동화**: 정기적인 백업을 자동화하세요.
5. **CI/CD 파이프라인**: GitHub Actions 또는 AWS CodePipeline을 설정하세요.

---

## 참고 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [AWS EC2 문서](https://docs.aws.amazon.com/ec2/)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)

---

## 지원

문제가 발생하면 다음을 확인하세요:
1. 로그 파일 확인
2. 환경변수 설정 확인
3. 보안 그룹 설정 확인
4. 네트워크 연결 확인

추가 도움이 필요하면 프로젝트 이슈를 생성하세요.

