import 'package:dio/dio.dart';
import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../core/di/service_locator.dart';

/// 소셜 로그인 서비스
class SocialAuthService {
  final ApiClient _apiClient = ApiClient();
  final Dio _dio = sl<Dio>();

  Future<User> _parseSocialResponse(Response response, String providerLabel) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'] ?? response.data;
      final userData = data['user'] ?? data;
      if (userData is! Map<String, dynamic>) {
        throw ValidationException('$providerLabel 로그인 응답 형식이 올바르지 않습니다');
      }
      final user = User.fromJson(userData);

      final accessToken = data['access_token'] ?? data['token'];
      if (accessToken != null) {
        await _apiClient.setAuthToken(accessToken.toString());
      }

      return user;
    }
    throw ServerException(
      '$providerLabel 로그인 실패: ${response.statusMessage}',
      statusCode: response.statusCode,
    );
  }

  /// 카카오 로그인
  Future<User> loginWithKakao(String accessToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/social/kakao',
        data: {'accessToken': accessToken},
      );
      return _parseSocialResponse(response, '카카오');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 네이버 로그인
  Future<User> loginWithNaver(String accessToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/social/naver',
        data: {'accessToken': accessToken},
      );
      return _parseSocialResponse(response, '네이버');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구글 로그인
  Future<User> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/social/google',
        data: {'idToken': idToken},
      );
      return _parseSocialResponse(response, '구글');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// Apple 로그인 (iOS 전용)
  Future<User> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? email,
    String? givenName,
    String? familyName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/social/apple',
        data: {
          'identityToken': identityToken,
          if (authorizationCode != null) 'authorizationCode': authorizationCode,
          if (email != null) 'email': email,
          if (givenName != null) 'givenName': givenName,
          if (familyName != null) 'familyName': familyName,
        },
      );
      return _parseSocialResponse(response, 'Apple');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
