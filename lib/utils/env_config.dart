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
}
