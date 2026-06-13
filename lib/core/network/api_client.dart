import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
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
    );

    _dio = Dio(baseOptions);
    _refreshDio = Dio(baseOptions);

    final cookieManager = CookieManager(_cookieJar);
    _dio.interceptors.add(cookieManager);
    _refreshDio.interceptors.add(cookieManager);

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
