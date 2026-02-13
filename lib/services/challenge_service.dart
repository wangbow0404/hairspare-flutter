import 'package:dio/dio.dart';
import 'dart:io';
import '../models/challenge_profile.dart';
import '../models/challenge_comment.dart';
import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../screens/spare/challenge_screen.dart';

class ChallengeService {
  final ApiClient _apiClient = ApiClient();

  /// 사용자 챌린지 프로필 조회
  Future<ChallengeProfile> getChallengeProfile(String userId) async {
    try {
      final response = await _apiClient.dio.get('/api/users/$userId/challenge-profile');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ChallengeProfile.fromJson(data);
      } else {
        throw ServerException(
          '챌린지 프로필 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 프로필 업데이트
  Future<ChallengeProfile> updateChallengeProfile(ChallengeProfile profile) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/users/${profile.userId}/challenge-profile',
        data: profile.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return ChallengeProfile.fromJson(data);
      } else {
        throw ServerException(
          '챌린지 프로필 업데이트 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내가 업로드한 챌린지 영상 목록 조회
  Future<List<MyChallenge>> getMyChallenges({
    String? filter, // 'all', 'public', 'private'
    String? sortBy, // 'latest', 'popular', 'views'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filter != null && filter != 'all') queryParams['filter'] = filter;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _apiClient.dio.get(
        '/api/challenges/my',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> challengesJson = data is List
            ? data
            : (data is Map && data['challenges'] != null
                ? (data['challenges'] as List)
                : []);
        return challengesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => MyChallenge.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '내 영상 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 구독한 크리에이터의 챌린지 영상 목록 조회
  Future<List<Challenge>> getSubscribedChallenges() async {
    try {
      final response = await _apiClient.dio.get('/api/challenges/subscribed');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> challengesJson = data is List
            ? data
            : (data is Map && data['challenges'] != null
                ? (data['challenges'] as List)
                : []);
        return challengesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Challenge.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '구독 피드 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 댓글 목록 조회
  Future<List<ChallengeComment>> getChallengeComments(String challengeId) async {
    try {
      final response = await _apiClient.dio.get('/api/challenges/$challengeId/comments');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> commentsJson = data is List
            ? data
            : (data is Map && data['comments'] != null
                ? (data['comments'] as List)
                : []);
        return commentsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => ChallengeComment.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '댓글 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 댓글 등록
  Future<ChallengeComment> createChallengeComment({
    required String challengeId,
    required String content,
    String? parentId, // 대댓글인 경우 부모 댓글 ID
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/challenges/$challengeId/comments',
        data: {
          'content': content,
          if (parentId != null) 'parentId': parentId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return ChallengeComment.fromJson(data);
      } else {
        throw ServerException(
          '댓글 등록 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 댓글 좋아요/좋아요 취소
  Future<void> toggleCommentLike(String challengeId, String commentId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/challenges/$challengeId/comments/$commentId/like',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '댓글 좋아요 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 싫어요/싫어요 취소
  Future<void> toggleChallengeDislike(String challengeId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/challenges/$challengeId/dislike',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '싫어요 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 프로필 이미지 업로드
  Future<String> uploadChallengeProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'challenge-profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.dio.post(
        '/api/challenges/profile-image/upload',
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
}
