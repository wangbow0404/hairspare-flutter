import 'package:dio/dio.dart';
import '../models/application.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_shop_data.dart';

class ApplicationService {
  final ApiClient _apiClient = ApiClient();

  /// 스페어용: 내 지원 목록 조회
  Future<List<Application>> getMyApplications() async {
    if (ApiConfig.useMockData) return await MockShopData.getMyApplications();
    try {
      final response = await _apiClient.dio.get('/api/applications/my');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> applicationsJson = data is List
            ? data
            : (data is Map && data['applications'] != null
                ? (data['applications'] as List)
                : []);
        return applicationsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Application.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '지원자 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 미용실용: 매장 공고에 지원한 목록 조회
  Future<List<Application>> getShopApplications() async {
    if (ApiConfig.useMockData) return await MockShopData.getShopApplications();
    try {
      final response = await _apiClient.dio.get('/api/applications/shop');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> applicationsJson = data is List
            ? data
            : (data is Map && data['applications'] != null
                ? (data['applications'] as List)
                : []);
        return applicationsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Application.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '지원자 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 지원 승인
  Future<void> approveApplication(String applicationId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/applications/$applicationId/approve',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '승인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 지원 거절
  Future<void> rejectApplication(String applicationId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/applications/$applicationId/reject',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '거절 실패: ${response.statusMessage}',
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
