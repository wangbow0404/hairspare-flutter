# Flutter 앱 빠른 시작 가이드

## 1단계: Flutter 설치 확인

```bash
flutter --version
```

Flutter가 설치되어 있지 않다면:
```bash
# macOS
brew install --cask flutter

# 설치 확인
flutter doctor
```

## 2단계: 프로젝트 설정

```bash
cd /Users/yoram/hairspare_flutter

# 패키지 설치
flutter pub get
```

## 3단계: 백엔드 서버 실행

다른 터미널에서:
```bash
cd /Users/yoram/hairspare
npm run dev
```

서버가 `http://localhost:3000`에서 실행되어야 합니다.

## 4단계: 앱 실행

### 웹 브라우저에서 테스트 (가장 빠름)
```bash
flutter run -d chrome
```

### Android 에뮬레이터
1. Android Studio에서 에뮬레이터 시작
2. `flutter run`

### iOS 시뮬레이터 (macOS만)
1. `open -a Simulator`
2. `flutter run`

## 5단계: 테스트

1. 역할 선택 화면에서 "스페어로 시작하기" 또는 "미용실로 시작하기" 클릭
2. 로그인 또는 회원가입 진행
3. 홈 화면에서 공고 목록 확인
4. 공고 카드 클릭하여 상세 화면 확인

## 문제 해결

### API 연결 오류
- 백엔드 서버가 실행 중인지 확인
- `lib/utils/api_config.dart`에서 Base URL 확인
- Android 에뮬레이터 사용 시 `http://10.0.2.2:3000/api` 사용

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter run
```
