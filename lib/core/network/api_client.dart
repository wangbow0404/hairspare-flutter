import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/api_config.dart';
import 'auth_interceptor.dart';

/// 앱 전역 Dio 클라이언트.
///
/// - Access Token: `flutter_secure_storage`
/// - Refresh Token(HttpOnly): `cookie_jar` + `dio_cookie_manager`
class ApiClient {
  ApiClient._internal();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const _accessTokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final CookieJar _cookieJar = CookieJar();

  late final Dio _dio;
  late final Dio _refreshDio;
  bool _initialized = false;

  String get _baseUrl => ApiConfig.getBaseUrl();
  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;

  void init({
    required SessionExpiredHandler onSessionExpired,
    required SessionMessageHandler onSessionExpiredMessage,
  }) {
    if (_initialized) return;

    final baseOptions = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const <String, dynamic>{
        'Content-Type': 'application/json',
      },
      // 웹에서 크로스도메인 HttpOnly 쿠키(Refresh Token)를 주고받으려면 필요.
      // 네이티브에서는 이 값이 무시된다.
      extra: const <String, dynamic>{'withCredentials': true},
    );

    _dio = Dio(baseOptions);
    _refreshDio = Dio(baseOptions);

    // 웹(브라우저)에서는 브라우저가 HttpOnly 쿠키를 자동 처리하므로
    // dio_cookie_manager를 붙이지 않는다. (웹 미지원 → 붙이면 요청이 깨질 수 있음)
    // 네이티브(iOS/Android)에서만 cookie_jar로 Refresh 쿠키를 관리한다.
    if (!kIsWeb) {
      final cookieManager = CookieManager(_cookieJar);
      _dio.interceptors.add(cookieManager);
      _refreshDio.interceptors.add(cookieManager);
    }

    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        refreshDio: _refreshDio,
        storage: _storage,
        onSessionExpired: onSessionExpired,
        onSessionExpiredMessage: onSessionExpiredMessage,
      ),
    );

    _initialized = true;
  }

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _cookieJar.deleteAll();
  }

  Future<String?> getAuthToken() async {
    return _storage.read(key: _accessTokenKey);
  }
}
