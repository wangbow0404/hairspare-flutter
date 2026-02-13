import 'package:dio/dio.dart';
import '../models/job.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class FavoriteService {
  final ApiClient _apiClient = ApiClient();

  /// 찜 목록 조회
  Future<List<Job>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get('/api/favorites');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> favoritesJson = data is List
            ? data
            : (data is Map && data['favorites'] != null
                ? (data['favorites'] as List)
                : []);
        return favoritesJson
            .whereType<Map<String, dynamic>>()
            .map((json) {
              // favorites API는 { id, jobId, createdAt, job: {...} } 형태일 수 있음
              final jobData = json['job'] ?? json;
              return Job.fromJson(jobData);
            })
            .toList();
      } else {
        throw ServerException(
          '찜 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 찜 추가
  Future<void> addFavorite(String jobId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/favorites',
        data: {'jobId': jobId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '찜 추가 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 찜 삭제
  Future<void> removeFavorite(String jobId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/favorites',
        queryParameters: {'jobId': jobId},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '찜 삭제 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 찜 여부 확인
  Future<bool> isFavorite(String jobId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/favorites/check',
        data: {'jobIds': [jobId]},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final favorites = data['favorites'] ?? {};
        return favorites[jobId] == true;
      }
      return false;
    } on DioException catch (e) {
      return false;
    }
  }
}
