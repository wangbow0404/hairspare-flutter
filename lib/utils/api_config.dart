import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API URL·mock 여부는 [assets/env/app.env] 및 `--dart-define` 으로만 구성합니다.
/// 릴리스 빌드에서는 mock 데이터가 항상 비활성화됩니다(JWT 필수 플로우).
class ApiConfig {
  ApiConfig._();

  /// `true`일 때만 목 데이터 사용. **release 에서는 항상 false.**
  static bool get useMockData {
    if (kReleaseMode) return false;
    const fromDefine =
        String.fromEnvironment('USE_MOCK_DATA', defaultValue: '');
    if (fromDefine.toLowerCase() == 'true' || fromDefine == '1') return true;
    final v = dotenv.maybeGet('USE_MOCK_DATA')?.toLowerCase() ?? '';
    return v == 'true' || v == '1';
  }

  static String getBaseUrl() {
    const fromDefine =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromDot = dotenv.maybeGet('API_BASE_URL')?.trim();
    if (fromDot != null && fromDot.isNotEmpty) return fromDot;

    if (kDebugMode) {
      if (kIsWeb) return 'http://localhost:8000';
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      return 'http://localhost:8000';
    }

    throw StateError(
      'API_BASE_URL이 설정되지 않았습니다. '
      'assets/env/app.env 또는 --dart-define=API_BASE_URL=... 를 설정하세요.',
    );
  }
}
