import 'package:dio/dio.dart';
import '../models/point_transaction.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';

/// 포인트 서비스
class PointService {
  final ApiClient _apiClient = ApiClient();

  /// 포인트 잔액 조회
  Future<int> getBalance() async {
    if (ApiConfig.useMockData) return await MockSpareData.getPointBalance();
    try {
      final response = await _apiClient.dio.get('/api/points/balance');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final balance = data['balance'] ?? data;
        return balance is int ? balance : int.tryParse(balance.toString()) ?? 0;
      }
      throw ServerException(
        '포인트 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 포인트 내역 조회
  Future<List<PointTransaction>> getHistory({
    int limit = 50,
    int offset = 0,
    String? type, // 'earn' | 'spend'
  }) async {
    if (ApiConfig.useMockData) {
      return await MockSpareData.getPointHistory(limit: limit, offset: offset, type: type);
    }
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
        '/api/points/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data['transactions'] ?? data;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((j) => PointTransaction.fromJson(j))
              .toList();
        }
      }
      throw ServerException(
        '포인트 내역 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 미션 완료 (포인트 적립)
  Future<bool> completeMission(String missionId) async {
    if (ApiConfig.useMockData) {
      return await MockSpareData.completePointMission(missionId);
    }
    try {
      final response = await _apiClient.dio.post(
        '/api/points/missions/$missionId/complete',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
