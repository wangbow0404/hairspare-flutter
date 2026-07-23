# 소셜 로그인 SDK 설정 가이드

소셜 로그인 SDK 통합이 완료되었습니다. 실제로 작동하려면 각 플랫폼별 설정이 필요합니다.

## 1. 카카오 로그인 설정

### 1.1 카카오 개발자 콘솔 설정
1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 내 애플리케이션 > 애플리케이션 추가하기
3. 플랫폼 설정:
   - Android: 패키지 이름과 키 해시 등록
   - iOS: 번들 ID 등록
4. 카카오 로그인 활성화
5. 네이티브 앱 키 복사

### 1.2 Flutter 설정
`lib/main.dart` 파일에서 카카오 네이티브 앱 키를 설정하세요:

```dart
kakao.KakaoSdk.init(
  nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY', // 여기에 실제 키 입력
);
```

### 1.3 Android 설정
`android/app/src/main/AndroidManifest.xml`에 다음 추가:

```xml
<activity
    android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakao{YOUR_KAKAO_NATIVE_APP_KEY}" />
    </intent-filter>
</activity>
```

### 1.4 iOS 설정
`ios/Runner/Info.plist`에 다음 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao{YOUR_KAKAO_NATIVE_APP_KEY}</string>
        </array>
    </dict>
</array>
```

## 2. 네이버 로그인 설정

### 2.1 네이버 개발자 센터 설정
1. [네이버 개발자 센터](https://developers.naver.com/apps/#/register) 접속
2. **애플리케이션 등록** (이용 API: **네이버 로그인**)
3. **Client ID**, **Client Secret** 발급
4. **로그인 오픈 API** 환경 등록:
   - **Android**: 패키지명 `kr.co.hairspare.app`
   - **iOS**: Bundle ID `kr.co.hairspare.app`, URL Scheme `hairsparenaver`
5. 제공 정보: **이름, 이메일** (필수 권장)

### 2.2 Android 설정
> `.example` 템플릿은 `android/app/`에 둔다 — `res/values/` 안에 두면 Android 리소스 병합기가 `.xml`로 안 끝나는 파일을 거부해서 빌드가 깨진다.
1. 예시 파일을 복사한 뒤 키를 입력합니다:
   ```bash
   cp android/app/naver_strings.xml.example \
      android/app/src/main/res/values/naver_strings.xml
   ```
2. `naver_strings.xml`에 Client ID / Secret 입력 (`naver_strings.xml`은 Git 커밋 금지)
3. `AndroidManifest.xml` — Naver SDK meta-data (이미 추가됨)
4. `MainActivity` — `FlutterFragmentActivity` 사용 (이미 적용)

### 2.3 iOS 설정
`ios/Runner/Info.plist`에서 다음 값을 네이버 콘솔 값으로 교체:
- `NidClientID` → Client ID
- `NidClientSecret` → Client Secret
- `NidUrlScheme` / URL Scheme → `hairsparenaver` (콘솔과 동일)
- `NidAppName` → `HairSpare`

`ios/Runner/AppDelegate.swift` — NidOAuth URL 핸들러 (이미 적용)

iOS 빌드 전:
```bash
cd ios && pod install
```

## 3. 구글 로그인 설정

### 3.1 Google Cloud Console 설정 (처음부터)

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 (예: `HairSpare`)
3. **API 및 서비스 > OAuth 동의 화면**
   - User Type: 외부 (테스트 단계에서는 테스트 사용자 추가)
   - 범위: `email`, `profile`, `openid`
4. **사용자 인증 정보 > OAuth 2.0 클라이언트 ID** 3개 생성:

| 유형 | 설정값 | 용도 |
|------|--------|------|
| **Web** | 이름: `HairSpare Web` | Android `serverClientId` + Railway `GOOGLE_CLIENT_ID` |
| **iOS** | Bundle ID: `kr.co.hairspare.app` | iOS `GoogleSignIn.clientId` |
| **Android** | 패키지: `kr.co.hairspare.app`, SHA-1 | Android 네이티브 인증 |

Android SHA-1 확인:

```bash
cd android
./gradlew signingReport
# 또는
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

발급 후 기록:
- `GOOGLE_WEB_CLIENT_ID` — Web 타입 (`xxxxx.apps.googleusercontent.com`)
- `GOOGLE_IOS_CLIENT_ID` — iOS 타입 (`yyyyy.apps.googleusercontent.com`)
- iOS URL Scheme — `com.googleusercontent.apps.{iOS_CLIENT_ID_숫자부분}`

### 3.2 Flutter dart-define (권장)

```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

### 3.3 Android 설정

1. 예시 파일 복사 후 Web Client ID 입력:

```bash
cp android/app/google_strings.xml.example \
   android/app/src/main/res/values/google_strings.xml
```

2. `google_strings.xml`의 `google_web_client_id` 수정 (`google_strings.xml`은 Git 커밋 금지)
3. `build.gradle.kts`가 `default_web_client_id`를 자동 주입 (Dart `serverClientId`가 우선)

### 3.4 iOS 설정

`ios/Runner/Info.plist`에서 다음을 실제 iOS Client ID로 교체:

- `GIDClientID` → `YOUR_IOS_CLIENT_ID.apps.googleusercontent.com`
- `CFBundleURLSchemes` 구글 항목 → `com.googleusercontent.apps.YOUR_IOS_CLIENT_NUM`

iOS 빌드 전:

```bash
cd ios && pod install
```

### 3.5 백엔드 (Railway)

`hairspare-backend` Variables:

```
GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

진단: `GET /api/auth/health/social` → `googleClientIdSet: true`

## 4. 패키지 설치

터미널에서 다음 명령어 실행:

```bash
flutter pub get
```

## 5. 테스트

각 소셜 로그인 버튼을 클릭하여 실제 로그인 화면이 나타나는지 확인하세요.

## 주의사항

- 각 플랫폼의 실제 앱 키/ID로 설정을 완료해야 실제로 작동합니다.
- 개발 환경과 프로덕션 환경의 키가 다를 수 있습니다.
- Android의 경우 키 해시를 정확히 등록해야 합니다.
