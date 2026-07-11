import 'package:dio/dio.dart';

import '../../utils/transient_network_retry.dart';

/// 일시적 네트워크/서버 오류 시 자동 재시도 (전역 적용).
class TransientRetryInterceptor extends Interceptor {
  TransientRetryInterceptor({required Dio dio, this.maxAttempts = 3}) : _dio = dio;

  final Dio _dio;
  final int maxAttempts;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['transient_retry'] as int?) ?? 0;
    if (!TransientNetworkRetry.isTransient(err) || attempt >= maxAttempts - 1) {
      return handler.next(err);
    }

    await Future.delayed(
      Duration(milliseconds: 700 * (attempt + 1)),
    );

    final options = err.requestOptions;
    options.extra['transient_retry'] = attempt + 1;

    try {
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
