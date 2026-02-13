# Flutter 앱 테스트 문제 해결 가이드

## 현재 상황
- Flutter 앱이 `localhost:8080`에서 실행되지 않음
- `ERR_CONNECTION_REFUSED` 오류 발생

## 해결 방법

### 1. Flutter 앱 수동 실행

터미널에서 다음 명령어를 실행하세요:

```bash
cd /Users/yoram/hairspare_flutter
flutter run -d chrome
```

또는 특정 포트 지정:

```bash
flutter run -d chrome --web-port=8080
```

### 2. 백엔드 서버 확인

다른 터미널에서 백엔드 서버가 실행 중인지 확인:

```bash
cd /Users/yoram/hairspare
npm run dev
```

서버가 `http://localhost:3000`에서 실행되어야 합니다.

### 3. 웹 빌드 후 직접 실행

```bash
cd /Users/yoram/hairspare_flutter

# 웹 빌드
flutter build web

# 빌드된 파일을 로컬 서버로 실행
cd build/web
python3 -m http.server 8080
```

그 후 브라우저에서 `http://localhost:8080` 접속

### 4. 간단한 테스트 서버 실행

```bash
cd /Users/yoram/hairspare_flutter/build/web
npx serve -p 8080
```

## 빠른 테스트 방법

가장 간단한 방법:

1. **터미널 1** - 백엔드 서버 실행:
```bash
cd /Users/yoram/hairspare
npm run dev
```

2. **터미널 2** - Flutter 앱 실행:
```bash
cd /Users/yoram/hairspare_flutter
flutter run -d chrome
```

Flutter가 자동으로 Chrome 브라우저를 열고 앱을 실행합니다.

## 예상되는 문제

### 문제 1: Flutter 명령어가 느리거나 멈춤
- 해결: `flutter doctor`로 환경 확인
- 해결: `flutter clean` 후 `flutter pub get` 재실행

### 문제 2: 포트 충돌
- 해결: 다른 포트 사용 `flutter run -d chrome --web-port=8081`

### 문제 3: CORS 오류
- 해결: 백엔드 서버의 CORS 설정 확인
- 해결: `lib/utils/api_config.dart`에서 Base URL 확인

## 다음 단계

앱이 실행되면:
1. 역할 선택 화면 확인
2. 로그인/회원가입 테스트
3. 홈 화면에서 공고 목록 확인
4. 공고 상세 화면 확인
