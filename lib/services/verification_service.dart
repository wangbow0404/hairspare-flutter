import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';

class VerificationService {
  final ApiClient _apiClient = ApiClient();

  /// 본인인증 상태 확인 (사용자 정보에서 확인)
  Future<Map<String, dynamic>> getVerificationStatus() async {
    if (ApiConfig.useMockData) return await MockSpareData.getVerificationStatus();
    try {
      // /api/verification/status API가 없으므로 /api/auth/me로 사용자 정보 조회
      final response = await _apiClient.dio.get('/api/auth/me');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        // 사용자 정보에서 verification 정보 추출 (백엔드에서 verification 관계 포함 시)
        return {
          'identityVerified': data['verification']?['identityVerified'] ?? false,
          'identityName': data['verification']?['identityName'],
          'identityPhone': data['verification']?['identityPhone'],
          'identityBirthDate': data['verification']?['identityBirthDate'],
          'identityGender': data['verification']?['identityGender'],
        };
      } else {
        throw ServerException(
          '인증 상태 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// PASS 본인인증 요청
  Future<Map<String, dynamic>> requestPassVerification() async {
    try {
      final response = await _apiClient.dio.post('/api/verification/pass/request');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'PASS 본인인증 요청 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 본인인증 요청 (PASS 인증 URL 반환)
  Future<String> requestIdentityVerification() async {
    try {
      final result = await requestPassVerification();
      return result['url'] as String? ?? '';
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// PASS 본인인증 상태 확인
  Future<Map<String, dynamic>> getPassVerificationStatus() async {
    if (ApiConfig.useMockData) return await MockSpareData.getPassVerificationStatus();
    try {
      final response = await _apiClient.dio.get('/api/verification/pass/status');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'PASS 본인인증 상태 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 자격증 인증 상태 확인
  Future<Map<String, dynamic>> getLicenseVerificationStatus() async {
    if (ApiConfig.useMockData) return await MockSpareData.getLicenseVerificationStatus();
    try {
      final response = await _apiClient.dio.get('/api/verification/license/status');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          '자격증 인증 상태 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증번호 발송
  Future<String> sendVerificationCode(String phone) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/send-verification-code',
        data: {'phone': phone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data['code'] as String? ?? '';
      } else {
        throw ServerException(
          '인증번호 발송 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증번호 확인
  Future<bool> verifyCode(String phone, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/verify-code',
        data: {'phone': phone, 'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['verified'] as bool? ?? false;
      } else {
        throw ServerException(
          '인증번호 확인 실패: ${response.statusMessage}',
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
