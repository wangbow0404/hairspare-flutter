# HairSpare Flutter 앱

HairSpare 모바일 앱 - 미용실 스페어 급구 해결 플랫폼

## 프로젝트 구조

```
lib/
├── main.dart
├── models/          # 데이터 모델
├── services/        # API 서비스
├── providers/       # 상태 관리
├── screens/         # 화면
│   ├── common/      # 공통 화면
│   ├── spare/       # 스페어 화면
│   └── shop/        # 미용실 화면
├── widgets/         # 재사용 위젯
└── utils/           # 유틸리티
```

## 시작하기

### 사전 요구사항

- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상

### 설치

```bash
flutter pub get
```

### 실행

```bash
flutter run
```

## API 연동

현재는 기존 Next.js API Routes를 사용합니다.

Base URL: `https://your-domain.com/api/`

## 문서

모든 문서는 [`docs/`](docs/) 폴더에 있습니다.

- [프로젝트 현황](docs/PROJECT_STATUS.md)
- [아키텍처](docs/ARCHITECTURE.md)
- [빠른 시작](docs/QUICK_START.md)

## 개발 참고

- 백엔드 API: `/Users/yoram/hairspare/app/api/` 또는 `/Users/yoram/backend-new/`
- 웹 화면 참고: `/Users/yoram/hairspare/app/`
