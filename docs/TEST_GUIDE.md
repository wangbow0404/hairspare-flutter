# Flutter 앱 테스트 가이드

## 사전 요구사항

### 1. Flutter SDK 설치

#### macOS
```bash
# Homebrew를 사용한 설치 (권장)
brew install --cask flutter

# 또는 공식 사이트에서 다운로드
# https://flutter.dev/docs/get-started/install/macos
```

#### 설치 확인
```bash
flutter --version
flutter doctor
```

### 2. 개발 환경 설정

#### Android Studio (Android 앱 테스트용)
- Android Studio 설치
- Android SDK 설치
- Android 에뮬레이터 설정

#### Xcode (iOS 앱 테스트용 - macOS만)
- Xcode 설치 (App Store)
- CocoaPods 설치: `sudo gem install cocoapods`

### 3. 프로젝트 설정

```bash
cd /Users/yoram/hairspare_flutter

# 패키지 설치
flutter pub get

# Flutter 환경 확인
flutter doctor
```

## 테스트 실행 방법

### 1. 연결된 디바이스 확인
```bash
flutter devices
```

### 2. 앱 실행

#### Android 에뮬레이터
```bash
# 에뮬레이터 시작 (Android Studio에서)
flutter run
```

#### iOS 시뮬레이터 (macOS만)
```bash
# 시뮬레이터 시작
open -a Simulator

# 앱 실행
flutter run
```

#### 실제 디바이스
- USB로 디바이스 연결
- 개발자 모드 활성화
- `flutter devices`로 확인 후 `flutter run`

### 3. 웹 브라우저에서 테스트 (빠른 테스트용)
```bash
flutter run -d chrome
```

## API 서버 설정

앱이 정상 작동하려면 백엔드 API 서버가 실행 중이어야 합니다.

### 1. Next.js 서버 실행
```bash
cd /Users/yoram/hairspare
npm run dev
```

서버가 `http://localhost:3000`에서 실행됩니다.

### 2. API Base URL 확인

`lib/utils/api_client.dart` 파일에서 Base URL이 올바르게 설정되어 있는지 확인:
```dart
static const String _baseUrl = 'http://localhost:3000/api';
```

**참고**: 
- Android 에뮬레이터: `http://10.0.2.2:3000/api` 사용
- iOS 시뮬레이터: `http://localhost:3000/api` 사용 가능
- 실제 디바이스: 컴퓨터의 로컬 IP 사용 (예: `http://192.168.0.100:3000/api`)

## 테스트 시나리오

### 1. 역할 선택 화면
- [ ] 스페어 버튼 클릭 → 스페어 로그인 화면으로 이동
- [ ] 미용실 버튼 클릭 → 미용실 로그인 화면으로 이동

### 2. 로그인 화면
- [ ] 아이디/비밀번호 입력
- [ ] 로그인 버튼 클릭
- [ ] 회원가입 링크 클릭 → 회원가입 화면으로 이동

### 3. 회원가입 화면
- [ ] 필수 필드 입력 (아이디, 비밀번호, 비밀번호 확인)
- [ ] 선택 필드 입력 (이메일, 이름, 전화번호, 추천 코드)
- [ ] 회원가입 버튼 클릭
- [ ] 성공 시 홈 화면으로 이동

### 4. 홈 화면
- [ ] 지역 선택 버튼 표시 확인
- [ ] 급구 공고 목록 표시 확인
- [ ] 일반 공고 목록 표시 확인
- [ ] 공고 카드 클릭 → 공고 상세 화면으로 이동
- [ ] Pull to refresh 동작 확인

### 5. 공고 상세 화면
- [ ] 공고 정보 표시 확인
- [ ] 지원하기 버튼 표시 확인

## 문제 해결

### Flutter 명령어를 찾을 수 없음
```bash
# PATH에 Flutter 추가
export PATH="$PATH:`pwd`/flutter/bin"
```

### 패키지 설치 오류
```bash
flutter pub cache repair
flutter pub get
```

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter run
```

### API 연결 오류
- 백엔드 서버가 실행 중인지 확인
- Base URL이 올바른지 확인
- 네트워크 권한 확인 (Android: AndroidManifest.xml)

## 다음 단계

테스트 완료 후:
1. 발견된 버그 수정
2. 추가 기능 구현
3. UI/UX 개선
4. 성능 최적화
