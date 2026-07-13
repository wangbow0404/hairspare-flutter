import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../config/business_config.dart';
import '../mocks/mock_model_match_data.dart';
import '../models/hair_model.dart';
import '../models/model_application_search_item.dart';
import '../models/model_discovery_item.dart';
import '../models/model_match_preference.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';

/// 모델 매칭 후보 조회·하루 매칭 한도 관리.
class ModelMatchService {
  final Dio _dio = sl<Dio>();

  int get dailyMatchLimit => BusinessConfig.modelDailyMatchLimit;

  /// 조건에 맞는 모델 후보 목록.
  Future<List<HairModel>> getCandidates(ModelMatchPreference pref) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      return MockModelMatchData.getCandidates(pref);
    }
    try {
      final response = await _dio.get('/api/model-match/candidates');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data is List
            ? data
            : (data is Map && data['candidates'] != null
                ? data['candidates'] as List
                : []);
        return list
            .whereType<Map<String, dynamic>>()
            .map(HairModel.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// "날짜검색" — 특정 날짜(없으면 오늘 이후 전체) + 조건(기장·시술·이미지) 키워드로
  /// 모델 신청 글이 있는 모델 목록을 조회.
  Future<List<ModelApplicationSearchItem>> getApplicationPostsByDate({
    String? date,
    Set<String> keywords = const {},
  }) async {
    try {
      final response = await _dio.get(
        '/api/models/application-posts/discovery',
        queryParameters: {
          if (date != null) 'date': date,
          if (keywords.isNotEmpty) 'keywords': keywords.join(','),
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final items = data is Map ? data['items'] : null;
        if (items is! List) return [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(ModelApplicationSearchItem.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 추천 소진 후 인기·신규 모델 탐색 피드.
  Future<List<ModelDiscoveryItem>> getDiscoveryModels({
    Set<String> excludeIds = const {},
  }) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      return MockModelMatchData.getDiscoveryModels(excludeIds: excludeIds);
    }
    try {
      final response = await _dio.get(
        '/api/model-match/discovery',
        queryParameters: {
          if (excludeIds.isNotEmpty) 'exclude': excludeIds.join(','),
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data is List
            ? data
            : (data is Map && data['items'] != null
                ? data['items'] as List
                : []);
        return list.whereType<Map<String, dynamic>>().map((json) {
          final kindRaw = json['kind']?.toString() ?? 'popular';
          final kind = kindRaw == 'new' || kindRaw == 'newlyJoined'
              ? ModelDiscoveryKind.newlyJoined
              : ModelDiscoveryKind.popular;
          return ModelDiscoveryItem(
            model: HairModel.fromJson(
              json['model'] is Map<String, dynamic>
                  ? json['model'] as Map<String, dynamic>
                  : json,
            ),
            kind: kind,
          );
        }).toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 오늘 남은 매칭(하트) 횟수.
  Future<int> remainingMatchesToday() async {
    if (ApiConfig.useMockData) {
      return MockModelMatchData.remainingMatchesToday();
    }
    try {
      final response = await _dio.get('/api/model-match/quota');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final remaining = data['remaining'];
        return remaining is int
            ? remaining
            : int.tryParse(remaining?.toString() ?? '') ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 매칭 1회 소모(하트). 남은 횟수가 없으면 false.
  Future<bool> consumeMatch() async {
    if (ApiConfig.useMockData) {
      return MockModelMatchData.consumeMatch();
    }
    try {
      final response = await _dio.post('/api/model-match/like');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
