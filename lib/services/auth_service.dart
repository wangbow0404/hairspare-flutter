import 'package:dio/dio.dart';
import 'dart:io';
import '../models/login_portal.dart';
import '../models/spare_subtype.dart';
import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_auth_data.dart';
import '../core/di/service_locator.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final Dio _dio = sl<Dio>();

  Future<User> login({
    required String username,
    required String password,
    LoginPortal? portal,
  }) async {
    if (ApiConfig.useMockData) {
      if (username.isEmpty || password.isEmpty) {
        throw ValidationException('아이디와 비밀번호를 입력해주세요');
      }
      final user = portal != null
          ? MockAuthData.userForCredentialsOnPortal(
              username,
              password,
              portal,
            )
          : MockAuthData.userForCredentials(username, password);
      if (user == null) {
        if (portal == LoginPortal.shop &&
            username == MockAuthData.devShopUsername &&
            MockAuthData.isShopAccountTerminated) {
          throw ValidationException(
            MockAuthData.loginBlockedMessageForTerminatedShop(),
            code: 'SHOP_ACCOUNT_TERMINATED',
          );
        }
        throw ValidationException(
          portal != null &&
                  MockAuthData.userForCredentials(username, password) !=
                      null
              ? '등록되지 않은 아이디입니다.'
              : '아이디 또는 비밀번호가 올바르지 않습니다',
        );
      }
      await _apiClient.setAuthToken(MockAuthData.mockTokenForUser(user));
      return user;
    }
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('로그인 응답 형식이 올바르지 않습니다');
        }
        final user = User.fromJson(userData);
        
        // 토큰 저장 (NextAuth 세션 쿠키 사용 시 별도 처리 필요)
        if (data['token'] != null) {
          await _apiClient.setAuthToken(data['token'].toString());
        }

        return user;
      } else {
        throw ServerException(
          '로그인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<User> register({
    required String username,
    required String password,
    required UserRole role,
    SpareSubtype? spareSubtype,
    String? email,
    String? name,
    String? phone,
    String? referralCode,
    Map<String, dynamic>? profilePayload,
  }) async {
    if (ApiConfig.useMockData) {
      if (username.isEmpty || password.isEmpty) {
        throw ValidationException('아이디와 비밀번호를 입력해주세요');
      }
      if (role == UserRole.shop) {
        MockAuthData.assertCanRegisterShop(
          phone: phone,
          username: username,
        );
      }
      await _apiClient.setAuthToken('mock_token');
      return MockAuthData.registerSpareUser(
        username: username,
        name: name,
        email: email,
        phone: phone,
        spareSubtype: spareSubtype ?? SpareSubtype.professional,
        profilePayload: profilePayload,
      );
    }
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'password': password,
          'role': role.name,
          if (spareSubtype != null) 'spareSubtype': spareSubtype.name,
          if (email != null && email.isNotEmpty) 'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (referralCode != null && referralCode.isNotEmpty)
            'referralCode': referralCode,
          if (profilePayload != null && profilePayload.isNotEmpty)
            'profile': profilePayload,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('회원가입 응답 형식이 올바르지 않습니다');
        }
        final user = User.fromJson(userData);
        return user;
      } else {
        throw ServerException(
          '회원가입 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<User?> getCurrentUser() async {
    if (ApiConfig.useMockData) {
      final token = await _apiClient.getAuthToken();
      return MockAuthData.userForMockToken(token);
    }
    try {
      final response = await _dio.get('/api/auth/me');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is! Map<String, dynamic>) {
          return null;
        }
        return User.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _apiClient.clearAuthToken();
      }
      // 인증 오류는 null 반환 (로그인 필요)
      return null;
    } catch (e) {
      // 기타 오류도 null 반환
      return null;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearAuthToken();
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    int? birthYear,
    String? gender, // 'M' or 'F'
    String? profileImage,
    List<String>? profileImages,
  }) async {
    try {
      final response = await _dio.put(
        '/api/users/profile',
        data: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (birthYear != null) 'birthYear': birthYear,
          if (gender != null && (gender == 'M' || gender == 'F')) 'gender': gender,
          if (profileImage != null && profileImage.isNotEmpty) 'profileImage': profileImage,
          if (profileImages != null && profileImages.isNotEmpty) 'profileImages': profileImages,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final userData = data['user'] ?? data;
        if (userData is! Map<String, dynamic>) {
          throw ValidationException('프로필 업데이트 응답 형식이 올바르지 않습니다');
        }
        return User.fromJson(userData);
      } else {
        throw ServerException(
          '프로필 업데이트 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '비밀번호 변경 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 비밀번호 재설정 (인증번호 확인 후)
  Future<void> resetPassword({
    required String id,
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/reset-password',
        data: {
          'id': id,
          'phone': phone,
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '비밀번호 재설정 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 아이디 찾기
  Future<Map<String, String>> findUsername({required String phone}) async {
    try {
      final response = await _dio.post(
        '/api/auth/find-id',
        data: {
          'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'id': data['id'] as String,
          'name': data['name'] as String? ?? '',
          'maskedId': data['maskedId'] as String? ?? data['id'] as String,
        };
      } else {
        throw ServerException(
          '아이디 찾기 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount({String? password}) async {
    try {
      final response = await _dio.delete(
        '/api/auth/delete-account',
        data: {
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '계정 삭제 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
      
      // 계정 삭제 후 토큰 제거
      await _apiClient.clearAuthToken();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 프로필 이미지 업로드
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/api/auth/profile-image/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data['imageUrl']?.toString() ?? data['url']?.toString() ?? '';
      } else {
        throw ServerException(
          '이미지 업로드 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 프로필 이미지 여러 개 업로드
  Future<List<String>> uploadProfileImages(List<File> imageFiles) async {
    try {
      final formData = FormData.fromMap({
        'images': await Future.wait(
          imageFiles.asMap().entries.map((entry) async {
            return MultipartFile.fromFile(
              entry.value.path,
              filename: 'profile-${DateTime.now().millisecondsSinceEpoch}-${entry.key}.jpg',
            );
          }),
        ),
      });

      final response = await _dio.post(
        '/api/auth/profile-images/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> urls = data['imageUrls'] ?? data['urls'] ?? [];
        return urls.map((url) => url.toString()).toList();
      } else {
        throw ServerException(
          '이미지 업로드 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 추천 이력 조회
  Future<List<Map<String, dynamic>>> getReferralHistory() async {
    try {
      final response = await _dio.get('/api/auth/referral-history');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> historyJson = data is List
            ? data
            : (data is Map && data['history'] != null
                ? (data['history'] as List)
                : []);
        return historyJson
            .whereType<Map<String, dynamic>>()
            .toList();
      } else {
        throw ServerException(
          '추천 이력 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
