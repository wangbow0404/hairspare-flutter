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
  NetworkException(super.message, {super.code, super.originalError});
}

/// 인증 관련 예외
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code, super.originalError});
}

/// 서버 오류 예외
class ServerException extends AppException {
  final int? statusCode;
  
  ServerException(super.message, {super.code, this.statusCode, super.originalError});
}

/// 유효성 검사 예외
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.originalError});
}

/// 권한 관련 예외
class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.originalError});
}

/// 데이터를 찾을 수 없음 예외
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.originalError});
}
