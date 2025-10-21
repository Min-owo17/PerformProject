# 악기 연주자 연습 기록 서비스 요구사항

## 1. 프로젝트 개요

악기 연주자들이 연습 기록을 저장하고 공유할 수 있는 웹 서비스입니다. 사용자는 개인 프로필을 통해 연습 기록을 관리하고, AI를 활용한 연주 시간 분석 기능을 제공합니다.

## 2. 핵심 기능

### 2.1 사용자 관리
- **회원가입/로그인**: 이메일 또는 소셜 로그인 지원
- **개인 프로필**: 닉네임, 프로필 이미지, 악기 정보, 성향(학생, 취미 등) 관리
- **사용자 정보 표시**: 인스타그램 해시태그 형태로 간단하게 표시

### 2.2 연습 기록 관리
- **연습 시작/종료**: 버튼 클릭으로 연습 세션 시작 및 종료
- **실시간 녹음**: 연습 중 소리 녹음 (일시적)
- **AI 분석**: 녹음된 소리를 AI로 분석하여 실제 연주 시간 계산
- **자동 삭제**: 분석 완료 후 녹음 파일 자동 삭제
- **연습 기록 저장**: 연습 시간, 날짜, 악기 등 정보 저장

### 2.3 프로필 대시보드
- **캘린더 뷰**: 연습 기록을 캘린더 형태로 시각화
- **통계 정보**: 총 연습 시간, 연습 횟수, 연속 연습 일수 등
- **연습 현황**: 최근 연습 기록 및 진행 상황 표시

### 2.4 공유 기능
- **프로필 공유**: 다른 사용자와 프로필 공유 가능
- **연습 기록 공유**: 특정 연습 세션 공유 기능

## 3. 기술 스택

### 3.1 백엔드
- **Framework**: FastAPI
- **Database**: 미정 (PostgreSQL, MySQL, MongoDB 등 검토 필요)
- **AI 서비스**: 음성 분석을 위한 AI API 연동
- **파일 저장**: 임시 녹음 파일 관리

### 3.2 프론트엔드
- **반응형 웹**: PC/Mobile 모두 지원
- **기술 스택**: React/Vue.js 등 (미정)
- **UI/UX**: 모바일 우선 반응형 디자인

### 3.3 인프라
- **배포**: 클라우드 서비스 (AWS, GCP, Azure 등)
- **파일 저장**: 클라우드 스토리지
- **CDN**: 정적 파일 배포

## 4. 데이터베이스 설계

### 4.1 사용자 테이블 (Users)
- user_id (Primary Key)
- email
- password_hash
- nickname
- profile_image_url
- created_at
- updated_at

### 4.2 사용자 정보 테이블 (User_Profiles)
- profile_id (Primary Key)
- user_id (Foreign Key)
- instruments (악기 목록)
- user_type (학생, 취미 등)
- bio (자기소개)
- hashtags (해시태그 목록)

### 4.3 연습 기록 테이블 (Practice_Sessions)
- session_id (Primary Key)
- user_id (Foreign Key)
- start_time
- end_time
- actual_play_time (AI 분석 결과)
- instrument
- notes (메모)
- created_at

### 4.4 녹음 파일 테이블 (Recording_Files)
- recording_id (Primary Key)
- session_id (Foreign Key)
- file_path
- file_size
- created_at
- deleted_at

## 5. API 설계

### 5.1 인증 관련
- `POST /auth/register` - 회원가입
- `POST /auth/login` - 로그인
- `POST /auth/logout` - 로그아웃
- `GET /auth/me` - 현재 사용자 정보

### 5.2 사용자 프로필
- `GET /users/{user_id}` - 사용자 프로필 조회
- `PUT /users/{user_id}` - 사용자 프로필 수정
- `POST /users/{user_id}/upload-image` - 프로필 이미지 업로드

### 5.3 연습 기록
- `POST /practice/start` - 연습 시작
- `POST /practice/end` - 연습 종료
- `GET /practice/sessions` - 연습 기록 목록
- `GET /practice/sessions/{session_id}` - 특정 연습 기록 조회
- `DELETE /practice/sessions/{session_id}` - 연습 기록 삭제

### 5.4 녹음 및 AI 분석
- `POST /practice/upload-audio` - 녹음 파일 업로드
- `POST /practice/analyze-audio` - AI 음성 분석 요청
- `GET /practice/analysis/{analysis_id}` - 분석 결과 조회

### 5.5 통계 및 대시보드
- `GET /users/{user_id}/dashboard` - 대시보드 데이터
- `GET /users/{user_id}/calendar` - 캘린더 데이터
- `GET /users/{user_id}/statistics` - 통계 데이터

## 6. 보안 및 개인정보 보호

### 6.1 데이터 보안
- 녹음 파일은 분석 후 즉시 삭제
- 사용자 비밀번호 해시화 저장
- API 인증 토큰 관리

### 6.2 개인정보 보호
- 최소한의 개인정보 수집
- 사용자 동의 하에 데이터 처리
- GDPR 준수

## 7. 성능 요구사항

### 7.1 응답 시간
- API 응답 시간: 2초 이내
- 페이지 로딩 시간: 3초 이내
- AI 분석 시간: 30초 이내

### 7.2 동시 사용자
- 초기 목표: 1,000명 동시 접속
- 확장 가능한 아키텍처 설계

## 8. 개발 단계

### 8.1 Phase 1 (MVP)
- 기본 사용자 관리
- 연습 기록 CRUD
- 간단한 프로필 페이지

### 8.2 Phase 2
- AI 음성 분석 기능
- 캘린더 뷰
- 통계 기능

### 8.3 Phase 3
- 공유 기능
- 소셜 기능
- 고급 분석 기능

## 9. 추가 고려사항

### 9.1 확장성
- 마이크로서비스 아키텍처 고려
- 데이터베이스 샤딩
- 캐싱 전략

### 9.2 모니터링
- 로그 관리
- 성능 모니터링
- 에러 추적

### 9.3 테스트
- 단위 테스트
- 통합 테스트
- E2E 테스트

## 10. 기술적 도전 과제

### 10.1 AI 음성 분석
- 실시간 음성 처리
- 연주 시간 정확한 계산
- 다양한 악기 지원

### 10.2 파일 관리
- 임시 파일 생성/삭제
- 대용량 오디오 파일 처리
- 스토리지 최적화

### 10.3 실시간 기능
- 연습 세션 실시간 추적
- WebSocket을 통한 실시간 업데이트

