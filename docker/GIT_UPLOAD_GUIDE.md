# Git을 사용한 EC2 서버 업로드 가이드

이 가이드에서는 로컬에서 수정한 내용을 Git 저장소에 커밋하고, EC2 서버에서 pull하여 적용하는 방법을 안내합니다.

## 📋 목차

1. [사전 준비사항](#사전-준비사항)
2. [로컬에서 Git 작업](#로컬에서-git-작업)
3. [EC2 서버에서 Git Pull](#ec2-서버에서-git-pull)
4. [문제 해결](#문제-해결)

---

## 사전 준비사항

### 1. Git 저장소 확인

로컬에서 원격 저장소가 설정되어 있는지 확인:

```bash
# 원격 저장소 확인
git remote -v

# 원격 저장소가 없으면 추가
git remote add origin <your-repository-url>
```

### 2. .gitignore 확인

환경변수 파일이 Git에 포함되지 않도록 확인:

```bash
# .gitignore 파일 확인
cat .gitignore

# .env.prod 파일이 제외되어 있는지 확인
grep -E "\.env|\.env\.prod" .gitignore
```

`.env.prod` 파일이 `.gitignore`에 없으면 추가해야 합니다.

---

## 로컬에서 Git 작업

### 1단계: 변경사항 확인

```bash
# 현재 작업 디렉토리 확인
cd C:\Users\Lein(홍혜민)\Desktop\개발\PerformProject\PerformProject

# 변경된 파일 확인
git status

# 변경 내용 확인
git diff
```

### 2단계: .gitignore 확인 및 수정

`.env.prod` 파일이 Git에 포함되지 않도록 확인:

```bash
# .gitignore 파일에 .env.prod 추가 (없는 경우)
echo ".env.prod" >> .gitignore

# 또는 수동으로 .gitignore 파일 편집
notepad .gitignore
```

`.gitignore` 파일에 다음이 포함되어 있어야 합니다:
```
.env
.env.local
.env.prod
```

### 3단계: 변경사항 스테이징

```bash
# 특정 파일만 추가
git add docker/docker-compose.prod.yml
git add docker/docker-compose.yml
git add docker/fix-minio-init.sh
git add docker/apply-fixes.sh
git add docker/setup-services-fixed.sh

# 또는 모든 변경사항 추가 (주의: .env.prod는 제외되어야 함)
git add .

# 스테이징된 파일 확인
git status
```

### 4단계: 커밋

```bash
# 커밋 메시지와 함께 커밋
git commit -m "Fix: MinIO Init 이미지 태그 수정 및 Redis env_file 추가

- minio-init 이미지를 latest로 변경 (존재하지 않는 태그 문제 해결)
- Redis 서비스에 env_file 추가
- MinIO Init 수정 및 적용 스크립트 추가"

# 커밋 히스토리 확인
git log --oneline -5
```

### 5단계: 원격 저장소에 푸시

```bash
# 현재 브랜치 확인
git branch

# 원격 저장소에 푸시
git push origin main
# 또는
git push origin master

# 푸시 확인
git remote show origin
```

---

## EC2 서버에서 Git Pull

### 1단계: EC2 서버 접속

```bash
# SSH로 EC2 서버 접속
ssh -i "your-key.pem" ec2-user@your-ec2-ip
# 또는 Ubuntu인 경우
ssh -i "your-key.pem" ubuntu@your-ec2-ip
```

### 2단계: 프로젝트 디렉토리로 이동

```bash
# 프로젝트 디렉토리로 이동
cd /opt/performproject

# 현재 Git 상태 확인
git status

# 현재 브랜치 확인
git branch
```

### 3단계: 변경사항 Pull

```bash
# 원격 저장소의 최신 변경사항 가져오기
git fetch origin

# 변경사항 확인
git log HEAD..origin/main --oneline
# 또는
git log HEAD..origin/master --oneline

# 변경사항 적용 (Pull)
git pull origin main
# 또는
git pull origin master

# 충돌이 발생한 경우
# git status로 충돌 파일 확인
# 파일 수정 후
# git add .
# git commit -m "Merge conflict resolved"
```

### 4단계: 변경사항 확인

```bash
# 변경된 파일 확인
git log --oneline -5

# docker-compose.prod.yml 파일 확인
cat docker/docker-compose.prod.yml | grep -A 2 "minio-init:"

# Redis 서비스 확인
cat docker/docker-compose.prod.yml | grep -A 5 "redis:"
```

### 5단계: 서비스 재시작 (선택사항)

변경사항을 적용하려면 서비스를 재시작해야 할 수 있습니다:

```bash
# 프로젝트 디렉토리로 이동
cd /opt/performproject/docker

# 수정 사항 적용 스크립트 실행
chmod +x apply-fixes.sh
./apply-fixes.sh

# 또는 수동으로 재시작
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

---

## 전체 작업 흐름

### 로컬 (Windows)

```bash
# 1. 변경사항 확인
git status

# 2. 변경사항 스테이징
git add docker/docker-compose.prod.yml
git add docker/docker-compose.yml
git add docker/*.sh
git add .gitignore

# 3. 커밋
git commit -m "Fix: MinIO Init 이미지 태그 수정 및 Redis env_file 추가"

# 4. 푸시
git push origin main
```

### EC2 서버 (Linux)

```bash
# 1. 프로젝트 디렉토리로 이동
cd /opt/performproject

# 2. 변경사항 Pull
git pull origin main

# 3. 변경사항 확인
git log --oneline -1

# 4. 서비스 재시작 (필요한 경우)
cd docker
./apply-fixes.sh
```

---

## 문제 해결

### 문제 1: "Your branch is ahead of 'origin/main' by X commits"

**원인**: 로컬에 커밋이 있지만 푸시하지 않음

**해결**:
```bash
git push origin main
```

### 문제 2: "Your branch is behind 'origin/main' by X commits"

**원인**: 원격 저장소에 새로운 커밋이 있음

**해결**:
```bash
git pull origin main
```

### 문제 3: Merge conflict 발생

**원인**: 로컬과 원격 저장소의 변경사항이 충돌

**해결**:
```bash
# 충돌 파일 확인
git status

# 충돌 파일 수정
nano <conflicted-file>

# 수정 후 스테이징 및 커밋
git add <conflicted-file>
git commit -m "Resolve merge conflict"
```

### 문제 4: .env.prod 파일이 Git에 포함됨

**원인**: .gitignore에 .env.prod가 없거나, 이미 Git에 추가됨

**해결**:
```bash
# .gitignore에 .env.prod 추가
echo ".env.prod" >> .gitignore

# Git에서 제거 (파일은 로컬에 유지)
git rm --cached docker/.env.prod

# 커밋
git add .gitignore
git commit -m "Add .env.prod to .gitignore"
git push origin main
```

### 문제 5: EC2 서버에서 Git 인증 오류

**원인**: Git 저장소가 private이고 인증이 필요함

**해결**:
```bash
# SSH 키 사용 (권장)
# GitHub에 SSH 키 추가 후
git remote set-url origin git@github.com:username/repository.git

# 또는 Personal Access Token 사용
git remote set-url origin https://username:token@github.com/username/repository.git
```

### 문제 6: EC2 서버에서 Git이 설치되지 않음

**원인**: Git이 설치되지 않음

**해결**:
```bash
# Amazon Linux 2
sudo yum install git -y

# Ubuntu
sudo apt update
sudo apt install git -y
```

---

## 보안 주의사항

### 1. 환경변수 파일 보호

- `.env.prod` 파일은 절대 Git에 커밋하지 마세요
- `.gitignore`에 `.env.prod`가 포함되어 있는지 확인하세요
- EC2 서버에서 `.env.prod` 파일은 별도로 관리하세요

### 2. Git 저장소 확인

커밋하기 전에 다음 명령어로 확인:

```bash
# 스테이징된 파일 확인
git status

# .env.prod 파일이 포함되어 있지 않은지 확인
git diff --cached --name-only | grep -E "\.env|\.env\.prod"
```

### 3. 커밋 전 확인

```bash
# 커밋할 파일 목록 확인
git diff --cached --name-only

# 민감한 정보가 포함되어 있지 않은지 확인
git diff --cached | grep -i "password\|secret\|key"
```

---

## 자동화 스크립트

### 로컬 업로드 스크립트 (Windows)

`upload-to-git.bat` 파일 생성:

```batch
@echo off
echo ==========================================
echo Git 업로드 스크립트
echo ==========================================

echo.
echo 1. 변경사항 확인...
git status

echo.
echo 2. 변경사항 스테이징...
git add docker/docker-compose.prod.yml
git add docker/docker-compose.yml
git add docker/*.sh
git add .gitignore

echo.
echo 3. 커밋...
git commit -m "Fix: MinIO Init 이미지 태그 수정 및 Redis env_file 추가"

echo.
echo 4. 원격 저장소에 푸시...
git push origin main

echo.
echo ==========================================
echo 업로드 완료!
echo ==========================================
pause
```

### EC2 서버 Pull 스크립트

`pull-from-git.sh` 파일 생성:

```bash
#!/bin/bash

echo "=========================================="
echo "Git Pull 스크립트"
echo "=========================================="

# 프로젝트 디렉토리로 이동
cd /opt/performproject || exit 1

echo ""
echo "1. 현재 상태 확인..."
git status

echo ""
echo "2. 원격 저장소에서 변경사항 가져오기..."
git fetch origin

echo ""
echo "3. 변경사항 확인..."
git log HEAD..origin/main --oneline

echo ""
echo "4. 변경사항 적용..."
git pull origin main

echo ""
echo "5. 변경사항 확인..."
git log --oneline -5

echo ""
echo "=========================================="
echo "Pull 완료!"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "  cd docker"
echo "  ./apply-fixes.sh"
echo ""
```

---

## 참고 자료

- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub 문서](https://docs.github.com/)
- [Git 기본 명령어](https://git-scm.com/docs)

---

## 다음 단계

1. 로컬에서 변경사항 커밋 및 푸시
2. EC2 서버에서 Git Pull
3. 서비스 재시작 (필요한 경우)
4. 서비스 상태 확인

