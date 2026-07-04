import 'package:dio/dio.dart';
import 'dart:io';
import '../models/challenge_profile.dart';
import '../models/challenge_comment.dart';
import '../models/challenge_feed.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';

class ChallengeService {
  final Dio _dio = sl<Dio>();

  /// 사용자 챌린지 프로필 조회
  Future<ChallengeProfile> getChallengeProfile(String userId) async {
    if (ApiConfig.useMockData) return await MockSpareData.getChallengeProfile(userId);
    try {
      final response = await _dio.get('/api/users/$userId/challenge-profile');

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
      final response = await _dio.put(
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

  /// 크리에이터 공개 영상 목록
  Future<List<MyChallenge>> getCreatorPublicVideos(
    String creatorId, {
    String? filter,
    String? sortBy,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getCreatorPublicVideos(
        creatorId,
        filter: filter,
        sortBy: sortBy,
      );
    }
    try {
      final queryParams = <String, dynamic>{};
      if (filter != null && filter != 'all') queryParams['filter'] = filter;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '/api/challenges/creator/$creatorId/videos',
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
          '크리에이터 영상 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인기 영상 (프로필 가로 리스트용)
  Future<List<MyChallenge>> getCreatorFeaturedVideos(String creatorId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getCreatorFeaturedVideos(creatorId);
    }
    final videos = await getCreatorPublicVideos(creatorId, sortBy: 'popular');
    return videos.take(5).toList();
  }

  /// 프로필 재생 — 크리에이터 영상만 구성된 피드
  Future<List<Challenge>> getCreatorChallengeFeed(String creatorId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getCreatorChallengeFeed(creatorId);
    }
    try {
      final response =
          await _dio.get('/api/challenges/creator/$creatorId/feed');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> json = data is List
            ? data
            : (data is Map && data['challenges'] != null
                ? (data['challenges'] as List)
                : []);
        return json
            .whereType<Map<String, dynamic>>()
            .map(Challenge.fromJson)
            .toList();
      }
      throw ServerException(
        '크리에이터 피드 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 크리에이터 영상 이후 유사 추천
  /// 추천 챌린지 피드 조회. [excludeCreatorId]가 없으면 전체 추천 피드.
  Future<List<Challenge>> getSimilarChallenges({
    String? excludeCreatorId,
    List<String>? referenceTags,
    List<String> excludeIds = const [],
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getSimilarChallenges(
        excludeCreatorId: excludeCreatorId ?? '',
        referenceTags: referenceTags,
        excludeIds: excludeIds,
      );
    }
    try {
      final response = await _dio.get(
        '/api/challenges/recommended',
        queryParameters: {
          if (excludeCreatorId != null && excludeCreatorId.isNotEmpty)
            'excludeCreatorId': excludeCreatorId,
          if (referenceTags != null && referenceTags.isNotEmpty)
            'tags': referenceTags.join(','),
          if (excludeIds.isNotEmpty) 'excludeIds': excludeIds.join(','),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> json = data is List
            ? data
            : (data is Map && data['challenges'] != null
                ? (data['challenges'] as List)
                : []);
        return json
            .whereType<Map<String, dynamic>>()
            .map(Challenge.fromJson)
            .toList();
      }
      throw ServerException(
        '추천 챌린지 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
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
    if (ApiConfig.useMockData) {
      return MockSpareData.getMyChallenges(
        filter: filter,
        sortBy: sortBy,
      );
    }
    try {
      final queryParams = <String, dynamic>{};
      if (filter != null && filter != 'all') queryParams['filter'] = filter;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
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
    if (ApiConfig.useMockData) return await MockSpareData.getSubscribedChallenges();
    try {
      final response = await _dio.get('/api/challenges/subscribed');

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
    if (ApiConfig.useMockData) return await MockSpareData.getChallengeComments(challengeId);
    try {
      final response = await _dio.get('/api/challenges/$challengeId/comments');

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
      final response = await _dio.post(
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
      final response = await _dio.post(
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
      final response = await _dio.post(
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
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'challenge-profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
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

  /// 챌린지 영상 파일 업로드 → R2 URL 반환
  Future<String> uploadChallengeVideo(File videoFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          videoFile.path,
          filename: 'challenge-${DateTime.now().millisecondsSinceEpoch}.mp4',
        ),
      });

      final response = await _dio.post(
        '/api/challenges/upload-video',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data['url']?.toString() ?? '';
      } else {
        throw ServerException(
          '영상 업로드 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 영상 게시글 생성
  Future<Challenge> createChallenge({
    required String videoUrl,
    required String title,
    String? description,
    List<String>? tags,
    String? thumbnailUrl,
    bool isPublic = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/challenges',
        data: {
          'videoUrl': videoUrl,
          'title': title,
          if (description != null) 'description': description,
          if (tags != null) 'tags': tags,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          'isPublic': isPublic,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return Challenge.fromJson(data);
      } else {
        throw ServerException(
          '챌린지 등록 실패: ${response.statusMessage}',
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
