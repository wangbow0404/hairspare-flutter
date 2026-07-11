import 'package:dio/dio.dart';

/// 배포·서버 재시작 등으로 잠깐 끊기는 요청을 자동 재시도한다.
class TransientNetworkRetry {
  TransientNetworkRetry._();

  static const _defaultMaxAttempts = 4;
  static const _baseDelayMs = 700;

  /// 연결 실패·타임아웃·502/503/504 는 일시적 오류로 본다.
  static bool isTransient(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = error.response?.statusCode;
    return status == 502 || status == 503 || status == 504;
  }

  static Future<T> run<T>(
    Future<T> Function() action, {
    int maxAttempts = _defaultMaxAttempts,
  }) async {
    DioException? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await action();
      } on DioException catch (e) {
        lastError = e;
        final isLast = attempt >= maxAttempts - 1;
        if (!isTransient(e) || isLast) rethrow;
        await Future.delayed(
          Duration(milliseconds: _baseDelayMs * (attempt + 1)),
        );
      }
    }
    throw lastError ?? DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.unknown,
    );
  }
}
