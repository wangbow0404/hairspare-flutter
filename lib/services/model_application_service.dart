import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';

/// 모델 신청 글의 개별 날짜 — 날짜마다 상태를 독립적으로 가짐.
class ModelApplicationDate {
  const ModelApplicationDate({
    required this.id,
    required this.date,
    required this.status,
  });

  factory ModelApplicationDate.fromJson(Map<String, dynamic> json) {
    return ModelApplicationDate(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }

  final String id;
  final String date;
  final String status; // active | matched | expired | cancelled
}

/// 모델 신청 글 — 모델이 올린 "이 날짜·시간에 가능해요" 공고.
class ModelApplicationPost {
  const ModelApplicationPost({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.keywords,
    required this.memo,
    required this.dates,
    required this.createdAt,
  });

  factory ModelApplicationPost.fromJson(Map<String, dynamic> json) {
    final datesJson = json['dates'];
    return ModelApplicationPost(
      id: json['id']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      keywords: json['keywords'] is List
          ? (json['keywords'] as List).map((e) => e.toString()).toList()
          : <String>[],
      memo: json['memo']?.toString(),
      dates: datesJson is List
          ? datesJson
              .whereType<Map<String, dynamic>>()
              .map(ModelApplicationDate.fromJson)
              .toList()
          : <ModelApplicationDate>[],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  final String id;
  final String startTime;
  final String endTime;
  final List<String> keywords;
  final String? memo;
  final List<ModelApplicationDate> dates;
  final DateTime? createdAt;
}

class ModelApplicationService {
  ModelApplicationService({Dio? dio}) : _dio = dio ?? sl<Dio>();

  final Dio _dio;

  Future<ModelApplicationPost> createPost({
    required List<String> dates,
    required String startTime,
    required String endTime,
    required List<String> keywords,
    String? memo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/models/me/application-posts',
        data: {
          'dates': dates,
          'startTime': startTime,
          'endTime': endTime,
          'keywords': keywords,
          if (memo != null && memo.isNotEmpty) 'memo': memo,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return ModelApplicationPost.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '모델 신청 등록 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<ModelApplicationPost>> getMyPosts() async {
    try {
      final response = await _dio.get('/api/models/me/application-posts');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final postsJson = data is Map ? data['posts'] : null;
        if (postsJson is! List) return [];
        return postsJson
            .whereType<Map<String, dynamic>>()
            .map(ModelApplicationPost.fromJson)
            .toList();
      }
      throw ServerException(
        '모델 신청 목록 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> cancelDate(String postId, String dateId) async {
    try {
      final response = await _dio.delete(
        '/api/models/me/application-posts/$postId/dates/$dateId',
      );
      if (response.statusCode != 200) {
        throw ServerException(
          '취소 실패: ${response.statusMessage}',
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
