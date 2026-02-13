import 'package:dio/dio.dart';
import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

/// 소셜 로그인 서비스
class SocialAuthService {
  final ApiClient _apiClient = ApiClient();

  /// 카카오 로그인
  /// 
  /// [accessToken] 카카오 액세스 토큰
  Future<User> loginWithKakao(String accessToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/social/kakao',
        data: {
          'accessToken': accessToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('카카오 로그인 응답 형식이 올바르지 않습니다');
        }
        final user = User.fromJson(userData);
        
        // 토큰 저장
        if (data['token'] != null) {
          await _apiClient.setAuthToken(data['token'].toString());
        }

        return user;
      } else {
        throw ServerException(
          '카카오 로그인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 네이버 로그인
  /// 
  /// [accessToken] 네이버 액세스 토큰
  Future<User> loginWithNaver(String accessToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/social/naver',
        data: {
          'accessToken': accessToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('네이버 로그인 응답 형식이 올바르지 않습니다');
        }
        final user = User.fromJson(userData);
        
        // 토큰 저장
        if (data['token'] != null) {
          await _apiClient.setAuthToken(data['token'].toString());
        }

        return user;
      } else {
        throw ServerException(
          '네이버 로그인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구글 로그인
  /// 
  /// [idToken] 구글 ID 토큰
  Future<User> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/social/google',
        data: {
          'idToken': idToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('구글 로그인 응답 형식이 올바르지 않습니다');
        }
        final user = User.fromJson(userData);
        
        // 토큰 저장
        if (data['token'] != null) {
          await _apiClient.setAuthToken(data['token'].toString());
        }

        return user;
      } else {
        throw ServerException(
          '구글 로그인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
