import 'package:dio/dio.dart';
import '../models/job.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class JobService {
  final ApiClient _apiClient = ApiClient();

  /// 공고 목록 조회
  Future<List<Job>> getJobs({
    List<String>? regionIds,
    bool? isUrgent,
    bool? isPremium,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (regionIds != null && regionIds.isNotEmpty) {
        queryParams['regionIds'] = regionIds;
      }
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent;
      if (isPremium != null) queryParams['isPremium'] = isPremium;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.dio.get(
        '/api/jobs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> jobsJson = data is List
            ? data
            : (data is Map && data['jobs'] != null
                ? (data['jobs'] as List)
                : []);
        return jobsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Job.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '공고 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내가 등록한 공고 목록 조회 (미용실용)
  Future<List<Job>> getMyJobs({
    List<String>? regionIds,
    bool? isUrgent,
    String? dateFrom,
    String? dateTo,
    String? status, // 'published' | 'closed' | 'draft'
    String? search, // 검색어
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'ownerId': 'me', // 자신이 등록한 공고만 가져오기
      };
      if (regionIds != null && regionIds.isNotEmpty) {
        queryParams['regionIds'] = regionIds;
      }
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.dio.get(
        '/api/jobs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> jobsJson = data is List
            ? data
            : (data is Map && data['jobs'] != null
                ? (data['jobs'] as List)
                : []);
        return jobsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Job.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '내 공고 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 상세 조회
  Future<Job> getJobById(String jobId) async {
    try {
      final response = await _apiClient.dio.get('/api/jobs/$jobId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Job.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(
          '공고 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 지원
  Future<void> applyToJob(String jobId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/jobs/$jobId/apply',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '공고 지원 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 상태 업데이트 (마감/재오픈)
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/jobs/$jobId',
        data: {'status': status},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '공고 상태 업데이트 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 삭제
  Future<void> deleteJob(String jobId) async {
    try {
      final response = await _apiClient.dio.delete('/api/jobs/$jobId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '공고 삭제 실패: ${response.statusMessage}',
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
