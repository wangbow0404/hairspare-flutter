import 'package:dio/dio.dart';
import 'app_exception.dart';

/// 에러 핸들러 유틸리티
class ErrorHandler {
  /// DioException을 AppException으로 변환
  static AppException handleDioException(DioException error) {
    // 네트워크 연결 오류
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(
        '서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.',
        code: 'NETWORK_ERROR',
        originalError: error,
      );
    }

    // 응답이 있는 경우 (서버 오류)
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      // 인증 오류
      if (statusCode == 401) {
        final message = _extractErrorMessage(responseData) ?? '인증이 필요합니다. 다시 로그인해주세요.';
        return AuthenticationException(
          message,
          code: 'UNAUTHORIZED',
          originalError: error,
        );
      }

      // 권한 오류
      if (statusCode == 403) {
        final message = _extractErrorMessage(responseData) ?? '접근 권한이 없습니다.';
        return PermissionException(
          message,
          code: 'FORBIDDEN',
          originalError: error,
        );
      }

      // 찾을 수 없음
      if (statusCode == 404) {
        final message = _extractErrorMessage(responseData) ?? '요청한 데이터를 찾을 수 없습니다.';
        return NotFoundException(
          message,
          code: 'NOT_FOUND',
          originalError: error,
        );
      }

      // 유효성 검사 오류
      if (statusCode == 400) {
        final message = _extractErrorMessage(responseData) ?? '잘못된 요청입니다.';
        return ValidationException(
          message,
          code: 'BAD_REQUEST',
          originalError: error,
        );
      }

      // 서버 오류
      if (statusCode != null && statusCode >= 500) {
        final message = _extractErrorMessage(responseData) ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        return ServerException(
          message,
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          originalError: error,
        );
      }

      // 기타 HTTP 오류
      final message = _extractErrorMessage(responseData) ?? '요청 처리 중 오류가 발생했습니다.';
      return ServerException(
        message,
        code: 'HTTP_ERROR',
        statusCode: statusCode,
        originalError: error,
      );
    }

    // 응답이 없는 경우 (네트워크 오류)
    return NetworkException(
      '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.',
      code: 'CONNECTION_ERROR',
      originalError: error,
    );
  }

  /// 일반 Exception을 AppException으로 변환
  static AppException handleException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return handleDioException(error);
    }

    if (error is Exception) {
      final message = error.toString();
      
      // 네트워크 관련 메시지 확인
      if (message.contains('connection') ||
          message.contains('network') ||
          message.contains('timeout') ||
          message.contains('XMLHttpRequest')) {
        return NetworkException(
          '서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.',
          code: 'NETWORK_ERROR',
          originalError: error,
        );
      }

      // 일반 예외
      return ServerException(
        message,
        code: 'UNKNOWN_ERROR',
        originalError: error,
      );
    }

    // 알 수 없는 오류
    return ServerException(
      '알 수 없는 오류가 발생했습니다.',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }

  /// 응답 데이터에서 에러 메시지 추출
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      // Next.js API 응답 형식: { error: { message: "..." } }
      if (responseData['error'] != null) {
        if (responseData['error'] is Map) {
          return responseData['error']['message']?.toString();
        }
        return responseData['error'].toString();
      }

      // 직접 메시지가 있는 경우
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }
    }

    if (responseData is String) {
      return responseData;
    }

    return null;
  }

  /// 사용자 친화적인 에러 메시지 반환
  static String getUserFriendlyMessage(AppException error) {
    if (error is NetworkException) {
      return '인터넷 연결을 확인하고 다시 시도해주세요.';
    }

    if (error is AuthenticationException) {
      return '로그인이 필요합니다. 다시 로그인해주세요.';
    }

    if (error is PermissionException) {
      return '접근 권한이 없습니다.';
    }

    if (error is NotFoundException) {
      return '요청한 데이터를 찾을 수 없습니다.';
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is ServerException) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }

    return error.message;
  }
}
