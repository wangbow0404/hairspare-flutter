/// 앱 전역 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 인증 관련 예외
class AuthenticationException extends AppException {
  AuthenticationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 서버 오류 예외
class ServerException extends AppException {
  final int? statusCode;
  
  ServerException(String message, {String? code, this.statusCode, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 유효성 검사 예외
class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 권한 관련 예외
class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 데이터를 찾을 수 없음 예외
class NotFoundException extends AppException {
  NotFoundException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
