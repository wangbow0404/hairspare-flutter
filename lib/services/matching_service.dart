import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_matching_data.dart';
import '../models/hair_model.dart';
import '../models/match_like.dart';
import '../models/match_profile.dart';
import '../utils/api_config.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';

/// 상호 좋아요(하트) 매칭 — mock-first.
class MatchingService {
  final Dio _dio = sl<Dio>();

  Future<List<MatchLike>> getReceivedLikes({required String modelUserId}) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.getReceivedLikes(modelUserId: modelUserId);
    }
    try {
      final response = await _dio.get('/api/matching/received');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data is List ? data : [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_matchLikeFromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<List<MatchLike>> getMatches({required String modelUserId}) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.getMatches(modelUserId: modelUserId);
    }
    try {
      final response = await _dio.get('/api/matching/matches');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data is List ? data : [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_matchLikeFromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<MatchLike?> getLikeById(String likeId) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.getLikeById(likeId);
    }
    return null;
  }

  /// 스페어 → 모델 하트 전송 (pending).
  Future<MatchLike> sendLikeToModel({
    required MatchProfile fromProfile,
    required HairModel targetModel,
  }) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.registerSentLike(
        fromProfile: fromProfile,
        toProfile: MockMatchingData.profileFromHairModel(targetModel),
      );
    }
    try {
      final response = await _dio.post(
        '/api/matching/likes',
        data: {'targetModelId': targetModel.id},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return _matchLikeFromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '하트 전송 실패',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<String> acceptLike(String likeId) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.acceptLike(likeId);
    }
    try {
      final response = await _dio.post('/api/matching/likes/$likeId/accept');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data['chatId']?.toString() ?? '';
      }
      throw ServerException(
        '매칭 수락 실패',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<void> declineLike(String likeId) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.declineLike(likeId);
    }
    try {
      await _dio.post('/api/matching/likes/$likeId/decline');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<void> cancelMatchByChatId(String chatId) async {
    if (ApiConfig.useMockData) {
      return MockMatchingData.cancelMatchByChatId(chatId);
    }
    try {
      await _dio.post(
        '/api/matching/cancel',
        data: {'chatId': chatId},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  bool isModelDesignerChat(String chatId) =>
      MockMatchingData.isModelDesignerChatId(chatId);

  MatchLike _matchLikeFromJson(Map<String, dynamic> json) {
    return MatchLike(
      id: json['id']?.toString() ?? '',
      fromProfile: _profileFromJson(json['fromProfile'] as Map? ?? {}),
      toProfile: _profileFromJson(json['toProfile'] as Map? ?? {}),
      status: MatchLikeStatus.values.firstWhere(
        (s) => s.name == json['status']?.toString(),
        orElse: () => MatchLikeStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      chatId: json['chatId']?.toString(),
    );
  }

  MatchProfile _profileFromJson(Map<dynamic, dynamic> json) {
    return MatchProfile(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'spare',
      displayName: json['displayName']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      intro: json['intro']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      portfolioImages: (json['portfolioImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      treatment: json['treatment']?.toString(),
      region: json['region']?.toString(),
    );
  }
}
