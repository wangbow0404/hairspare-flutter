import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 시크릿/API 키는 GitHub 에 커밋하지 않습니다.
/// 주입: `--dart-define=KEY=value` (우선) → `dotenv`(비시크릿 기본값과 동일 자산만).
class EnvConfig {
  EnvConfig._();

  /// 카카오 네이티브 앱 키. 반드시 빌드 시 define 또는 로컬 전용 설정으로 주입(저장소 미커밋).
  static String get kakaoNativeAppKey {
    const fromDefine =
        String.fromEnvironment('KAKAO_NATIVE_APP_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return (dotenv.maybeGet('KAKAO_NATIVE_APP_KEY') ?? '').trim();
  }

  /// 네이버 Client ID (문서/빌드 참고용 — 실제 SDK는 Android/iOS 네이티브 설정 사용).
  static String get naverClientId {
    const fromDefine =
        String.fromEnvironment('NAVER_CLIENT_ID', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return (dotenv.maybeGet('NAVER_CLIENT_ID') ?? '').trim();
  }

  /// 구글 Web OAuth Client ID — Android serverClientId + 백엔드 GOOGLE_CLIENT_ID 와 동일.
  static String get googleWebClientId {
    const fromDefine =
        String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return (dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID') ?? '').trim();
  }

  /// 구글 iOS OAuth Client ID — iOS GoogleSignIn.clientId.
  static String get googleIosClientId {
    const fromDefine =
        String.fromEnvironment('GOOGLE_IOS_CLIENT_ID', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return (dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID') ?? '').trim();
  }

  /// iOS Info.plist CFBundleURLSchemes 용 reversed client id.
  /// 예: 123456-abc.apps.googleusercontent.com → com.googleusercontent.apps.123456-abc
  static String? get googleIosUrlScheme {
    final iosId = googleIosClientId;
    if (iosId.isEmpty || !iosId.endsWith('.apps.googleusercontent.com')) {
      return null;
    }
    final prefix = iosId.replaceAll('.apps.googleusercontent.com', '');
    return 'com.googleusercontent.apps.$prefix';
  }

  static bool get isGoogleSignInConfigured =>
      googleWebClientId.isNotEmpty && googleIosClientId.isNotEmpty;
}
