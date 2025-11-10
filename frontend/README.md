# PerformProject Frontend

PerformProject의 React 프론트엔드 애플리케이션입니다.

## 📋 목차

- [설치](#설치)
- [개발 서버 실행](#개발-서버-실행)
- [빌드](#빌드)
- [프로젝트 구조](#프로젝트-구조)
- [주요 기능](#주요-기능)

## 설치

```bash
# 의존성 설치
npm install
```

## 개발 서버 실행

```bash
# 개발 서버 시작 (http://localhost:3000)
npm run dev
```

## 빌드

```bash
# 프로덕션 빌드
npm run build

# 빌드 결과 미리보기
npm run preview
```

## 프로젝트 구조

```
frontend/
├── src/
│   ├── components/      # 화면 컴포넌트 (screen 폴더에서 복사 필요)
│   ├── context/         # React Context (screen/context에서 복사 필요)
│   ├── hooks/           # 커스텀 훅 (screen/hooks에서 복사 필요)
│   ├── services/        # API 서비스 (screen/services에서 복사 필요)
│   ├── styles/          # 스타일 유틸리티 (screen/styles에서 복사 필요)
│   ├── types.ts         # TypeScript 타입 정의 (screen/types.ts에서 복사 필요)
│   ├── utils/           # 유틸리티 함수 (screen/utils에서 복사 필요)
│   ├── App.tsx          # 메인 App 컴포넌트
│   ├── main.tsx         # 진입점
│   └── index.css        # 전역 스타일
├── public/              # 정적 파일
├── package.json         # 패키지 의존성
├── vite.config.ts       # Vite 설정
├── tailwind.config.js   # Tailwind CSS 설정
└── tsconfig.json        # TypeScript 설정
```

## 주요 기능

- 사용자 인증 (이메일, 소셜 로그인)
- 연습 기록 관리
- 캘린더 뷰
- 그룹 기능
- 게시판
- 프로필 관리
- 설정

## 다음 단계

1. `screen/` 폴더의 파일들을 `src/` 폴더로 복사:
   - `screen/components/` → `src/components/`
   - `screen/context/` → `src/context/`
   - `screen/hooks/` → `src/hooks/`
   - `screen/services/` → `src/services/`
   - `screen/styles/` → `src/styles/`
   - `screen/types.ts` → `src/types.ts`
   - `screen/utils/` → `src/utils/`

2. Navigation 컴포넌트 생성 (필요한 경우)

3. API 연동 설정

4. 환경변수 설정 (.env 파일)

## 환경변수

`.env` 파일을 생성하고 다음 변수를 설정하세요:

```env
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000
```

