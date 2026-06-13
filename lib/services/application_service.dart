import 'package:dio/dio.dart';
import '../models/application.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_shop_data.dart';
import '../core/di/service_locator.dart';
import '../providers/auth_provider.dart';

class ApplicationService {
  final Dio _dio = sl<Dio>();

  /// 스페어용: 내 지원 목록 조회
  Future<List<Application>> getMyApplications() async {
    if (ApiConfig.useMockData) {
      final userId = sl<AuthProvider>().currentUser?.id ?? 'mock-spare-1';
      return MockShopData.getSpareApplications(userId);
    }
    try {
      final response = await _dio.get('/api/applications/my');

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
      final response = await _dio.get('/api/applications/shop');

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

  /// 지원 승인. mock에서 모집 충족 시 [jobAutoClosed] true.
  Future<({bool jobAutoClosed})> approveApplication(
    String applicationId,
  ) async {
    if (ApiConfig.useMockData) {
      return MockShopData.approveShopApplication(applicationId);
    }
    try {
      final response = await _dio.post(
        '/api/applications/$applicationId/approve',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '승인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
      final data = response.data;
      final autoClosed = data is Map &&
          (data['jobAutoClosed'] == true ||
              data['data'] is Map &&
                  (data['data'] as Map)['jobAutoClosed'] == true);
      return (jobAutoClosed: autoClosed);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 지원 거절
  Future<void> rejectApplication(String applicationId) async {
    if (ApiConfig.useMockData) {
      final ok = await MockShopData.rejectShopApplication(applicationId);
      if (!ok) {
        throw ServerException('지원 정보를 찾을 수 없습니다');
      }
      return;
    }
    try {
      final response = await _dio.post(
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
