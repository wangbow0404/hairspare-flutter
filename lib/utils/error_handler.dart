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

      // 중복 등 충돌 (아이디 중복 등) — 서버가 준 메시지를 그대로 보여줌
      if (statusCode == 409) {
        final message = _extractErrorMessage(responseData) ?? '이미 사용 중인 정보입니다.';
        return ValidationException(
          message,
          code: 'CONFLICT',
          originalError: error,
        );
      }

      // 입력값 검증 실패 (FastAPI 422) — 어떤 항목이 왜 틀렸는지 사용자에게 알려줌
      if (statusCode == 422) {
        final message = _extractFastApiValidationMessage(responseData) ??
            _extractErrorMessage(responseData) ??
            '입력하신 정보를 다시 확인해주세요.';
        return ValidationException(
          message,
          code: 'VALIDATION_ERROR',
          originalError: error,
        );
      }

      // 서버 오류 — 응답 본문을 파싱하지 않음(스택/쿼리 노출 방지, SECURITY_PATCH_GUIDE P2)
      if (statusCode != null && statusCode >= 500) {
        return ServerException(
          '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
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

  /// FastAPI 422 응답(`{"detail": [{"loc": [...], "msg": "...", "type": "..."}]}`)에서
  /// 어떤 항목이 왜 틀렸는지 한국어 메시지로 변환.
  static String? _extractFastApiValidationMessage(dynamic responseData) {
    if (responseData is! Map) return null;
    final detail = responseData['detail'];
    if (detail is! List || detail.isEmpty) return null;
    final first = detail.first;
    if (first is! Map) return null;

    final loc = first['loc'];
    final field =
        (loc is List && loc.isNotEmpty) ? loc.last.toString() : '';
    final msg = (first['msg'] ?? '').toString().toLowerCase();
    final label = _fieldLabelKo(field);

    // 최소 길이 미달 (비밀번호 8자, 아이디 3자 등)
    if (msg.contains('at least') ||
        msg.contains('too short') ||
        msg.contains('min_length') ||
        msg.contains('shorter')) {
      final n = RegExp(r'(\d+)').firstMatch(msg)?.group(1);
      if (n != null) return '$label은(는) 최소 $n자 이상 입력해주세요.';
      return '$label을(를) 더 길게 입력해주세요.';
    }
    // 최대 길이 초과
    if (msg.contains('at most') || msg.contains('too long') || msg.contains('longer')) {
      final n = RegExp(r'(\d+)').firstMatch(msg)?.group(1);
      if (n != null) return '$label은(는) $n자 이하로 입력해주세요.';
      return '$label이(가) 너무 깁니다.';
    }
    // 이메일 형식
    if (field == 'email' || msg.contains('email')) {
      return '이메일 형식이 올바르지 않습니다.';
    }
    // 필수값 누락
    if (msg.contains('required') || msg.contains('missing')) {
      return '$label을(를) 입력해주세요.';
    }
    return '$label 입력값을 확인해주세요.';
  }

  /// 백엔드 필드명 → 사용자에게 보여줄 한국어 라벨.
  static String _fieldLabelKo(String field) {
    switch (field) {
      case 'username':
        return '아이디';
      case 'password':
        return '비밀번호';
      case 'email':
        return '이메일';
      case 'name':
        return '이름';
      case 'phone':
        return '전화번호';
      case 'role':
        return '가입 유형';
      default:
        return '입력값';
    }
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

  /// 스택 트레이스·내부 디버그 문자열로 보이면 사용자에게 노출하지 않음
  static bool _looksLikeInternalErrorDetail(String? message) {
    if (message == null || message.isEmpty) return false;
    if (message.length > 800) return true;
    final lower = message.toLowerCase();
    if (lower.contains('traceback') ||
        lower.contains('stacktrace') ||
        lower.contains('exception in thread') ||
        lower.contains('#0      ') ||
        lower.contains('sqlstate') ||
        lower.contains('sql error') ||
        lower.contains('integrityerror') ||
        lower.contains('django.db') ||
        lower.contains('fastapi.exception')) {
      return true;
    }
    return false;
  }

  /// 사용자 친화적인 에러 메시지 반환
  static String getUserFriendlyMessage(AppException error) {
    if (error is NetworkException) {
      return '인터넷 연결을 확인하고 다시 시도해주세요.';
    }

    if (error is AuthenticationException) {
      return error.message.isNotEmpty
          ? error.message
          : '로그인이 필요합니다. 다시 로그인해주세요.';
    }

    if (error is PermissionException) {
      return error.message.isNotEmpty ? error.message : '접근 권한이 없습니다.';
    }

    if (error is NotFoundException) {
      return error.message.isNotEmpty ? error.message : '요청한 데이터를 찾을 수 없습니다.';
    }

    if (error is ValidationException) {
      if (_looksLikeInternalErrorDetail(error.message)) {
        return '요청을 처리할 수 없습니다. 입력 내용을 확인해주세요.';
      }
      return error.message;
    }

    if (error is ServerException) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }

    if (_looksLikeInternalErrorDetail(error.message)) {
      return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
    return error.message;
  }
}
