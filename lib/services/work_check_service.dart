import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_shop_data.dart';

class WorkCheckService {
  final ApiClient _apiClient = ApiClient();

  /// 미용실용 VIP 통계 조회
  Future<Map<String, dynamic>> getShopStats() async {
    if (ApiConfig.useMockData) return await MockShopData.getShopStats();
    try {
      final response = await _apiClient.dio.get('/api/work-check/shop-stats');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'totalCompleted': data['totalCompleted'] ?? 0,
          'vipLevel': data['vipLevel'] ?? data['tier'] ?? 'bronze',
          'tier': data['tier'] ?? data['vipLevel'] ?? 'bronze',
          'nextCount': data['nextCount'] ?? 1,
          'progress': data['progress'] ?? 0,
        };
      } else {
        throw ServerException(
          'VIP 통계 조회 실패: ${response.statusMessage}',
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
