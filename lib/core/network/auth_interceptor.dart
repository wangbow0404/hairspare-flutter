import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef SessionExpiredHandler = Future<void> Function();
typedef SessionMessageHandler = void Function(String message);

/// JWT Access Token + HttpOnly Refresh Cookie 기반 인증 인터셉터.
///
/// - 요청 시 `Authorization: Bearer <token>` 자동 주입
/// - 401 시 단일 refresh 플로우만 실행(동시성 제어)
/// - refresh 성공 후 대기 중 요청까지 재시도
/// - refresh 실패/재시도 401은 즉시 세션 만료 처리
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required FlutterSecureStorage storage,
    required SessionExpiredHandler onSessionExpired,
    required SessionMessageHandler onSessionExpiredMessage,
  })  : _dio = dio,
        _refreshDio = refreshDio,
        _storage = storage,
        _onSessionExpired = onSessionExpired,
        _onSessionExpiredMessage = onSessionExpiredMessage;

  static const _authorizationHeader = 'Authorization';
  static const _bearerPrefix = 'Bearer ';
  static const _accessTokenKey = 'auth_token';
  static const _refreshPath = '/api/auth/refresh';
  static const _retryMark = 'auth_retry_attempted';

  final Dio _dio;
  final Dio _refreshDio;
  final FlutterSecureStorage _storage;
  final SessionExpiredHandler _onSessionExpired;
  final SessionMessageHandler _onSessionExpiredMessage;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;
  bool _hasHandledSessionExpired = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers[_authorizationHeader] = '$_bearerPrefix$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    if (statusCode != 401 || _isRefreshRequest(requestOptions)) {
      handler.next(err);
      return;
    }

    if (requestOptions.extra[_retryMark] == true) {
      await _handleSessionExpired();
      handler.reject(err);
      return;
    }

    try {
      await _ensureRefreshedAccessToken();
    } catch (_) {
      await _handleSessionExpired();
      handler.reject(err);
      return;
    }

    try {
      final response = await _retryRequest(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _handleSessionExpired();
      }
      handler.reject(retryError);
    } catch (_) {
      handler.reject(err);
    }
  }

  bool _isRefreshRequest(RequestOptions options) =>
      options.path.endsWith(_refreshPath) || options.path == _refreshPath;

  Future<void> _ensureRefreshedAccessToken() async {
    if (_isRefreshing) {
      final completer = _refreshCompleter;
      if (completer != null) {
        await completer.future;
      }
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final response = await _refreshDio.post(_refreshPath);
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final token = payload['access_token'] ?? payload['accessToken'] ?? payload['token'];
      final accessToken = token?.toString() ?? '';
      if (accessToken.isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Missing access token in refresh response',
        );
      }

      await _storage.write(key: _accessTokenKey, value: accessToken);
      _refreshCompleter?.complete();
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _storage.read(key: _accessTokenKey);
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      headers[_authorizationHeader] = '$_bearerPrefix$token';
    } else {
      headers.remove(_authorizationHeader);
    }

    final copiedOptions = requestOptions.copyWith(
      headers: headers,
      extra: <String, dynamic>{
        ...requestOptions.extra,
        _retryMark: true,
      },
    );

    return _dio.fetch<dynamic>(copiedOptions);
  }

  Future<void> _handleSessionExpired() async {
    if (_hasHandledSessionExpired) return;
    _hasHandledSessionExpired = true;

    await _storage.delete(key: _accessTokenKey);
    _onSessionExpiredMessage('세션이 만료되었습니다.');
    await _onSessionExpired();
  }
}
