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
1. [네이버 개발자 센터](https://developers.naver.com/) 접속
2. 애플리케이션 등록
3. Client ID와 Client Secret 발급
4. Android/iOS 플랫폼 등록

### 2.2 Android 설정
`android/app/src/main/AndroidManifest.xml`에 다음 추가:

```xml
<activity
    android:name="com.navercorp.nid.oauth.view.NidOAuthLoginActivity"
    android:exported="true"
    android:screenOrientation="portrait" />
```

`android/app/build.gradle`에 다음 추가:

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            naverClientId: "YOUR_NAVER_CLIENT_ID",
            naverClientSecret: "YOUR_NAVER_CLIENT_SECRET"
        ]
    }
}
```

### 2.3 iOS 설정
`ios/Runner/Info.plist`에 다음 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>naverlogin</string>
        </array>
    </dict>
</array>
```

## 3. 구글 로그인 설정

### 3.1 Google Cloud Console 설정
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. API 및 서비스 > 사용자 인증 정보
4. OAuth 2.0 클라이언트 ID 생성
   - Android: 패키지 이름과 SHA-1 인증서 지문 등록
   - iOS: 번들 ID 등록
5. Client ID 복사

### 3.2 Android 설정
`android/app/build.gradle`에 다음 추가:

```gradle
android {
    defaultConfig {
        resValue "string", "default_web_client_id", "YOUR_GOOGLE_CLIENT_ID"
    }
}
```

### 3.3 iOS 설정
`ios/Runner/Info.plist`에 다음 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

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
