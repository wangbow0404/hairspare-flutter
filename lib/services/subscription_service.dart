import 'package:dio/dio.dart';
import '../models/subscription.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  /// 구독하기
  Future<void> subscribe(String creatorId) async {
    try {
      final response = await _apiClient.dio.post('/api/subscriptions/$creatorId');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '구독 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구독 취소
  Future<void> unsubscribe(String creatorId) async {
    try {
      final response = await _apiClient.dio.delete('/api/subscriptions/$creatorId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '구독 취소 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구독 상태 확인
  Future<bool> checkSubscriptionStatus(String creatorId) async {
    try {
      final response = await _apiClient.dio.get('/api/users/$creatorId/subscription-status');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['isSubscribed'] as bool? ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      // 404 등 에러는 구독하지 않은 것으로 처리
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 내가 구독한 크리에이터 목록 조회
  Future<List<Creator>> getMySubscriptions() async {
    try {
      final response = await _apiClient.dio.get('/api/subscriptions/my');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> creatorsJson = data is List
            ? data
            : (data is Map && data['creators'] != null
                ? (data['creators'] as List)
                : []);
        return creatorsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Creator.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '구독 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구독자 목록 조회 (크리에이터용)
  Future<List<Subscription>> getSubscribers(String creatorId) async {
    try {
      final response = await _apiClient.dio.get('/api/users/$creatorId/subscribers');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> subscriptionsJson = data is List
            ? data
            : (data is Map && data['subscribers'] != null
                ? (data['subscribers'] as List)
                : []);
        return subscriptionsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Subscription.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '구독자 목록 조회 실패: ${response.statusMessage}',
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
