import 'package:dio/dio.dart';
import '../models/schedule.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';

class ScheduleService {
  final ApiClient _apiClient = ApiClient();

  /// 스케줄 목록 조회
  Future<List<Schedule>> getSchedules({
    String? dateFrom,
    String? dateTo,
    String? status,
    String? ownerId, // 'me'로 설정하면 자신의 스케줄만 조회
  }) async {
    if (ApiConfig.useMockData) return await MockSpareData.getSchedules();
    try {
      final queryParams = <String, dynamic>{};
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (status != null) queryParams['status'] = status;
      if (ownerId != null) queryParams['ownerId'] = ownerId;

      final response = await _apiClient.dio.get(
        '/api/schedules',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> schedulesJson = data is List
            ? data
            : (data is Map && data['schedules'] != null
                ? (data['schedules'] as List)
                : []);
        return schedulesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Schedule.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '스케줄 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스케줄 취소
  Future<void> cancelSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/schedules/$scheduleId/cancel',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '스케줄 취소 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 근무 체크 통계 조회
  Future<Map<String, dynamic>> getWorkCheckStats() async {
    if (ApiConfig.useMockData) return await MockSpareData.getWorkCheckStats();
    try {
      final response = await _apiClient.dio.get('/api/work-check/stats');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'consecutiveDays': data['consecutiveDays'] ?? 0,
          'energyFromWork': data['energyFromWork'] ?? 0,
        };
      } else {
        throw ServerException(
          '근무 통계 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스케줄 체크인
  Future<Schedule> checkInSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/schedules/$scheduleId/check-in',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return Schedule.fromJson(data);
      } else {
        throw ServerException(
          '체크인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 미용실용 스케줄 조회 (자신이 등록한 공고의 스케줄)
  Future<List<Schedule>> getMySchedules({
    String? dateFrom,
    String? dateTo,
    String? status,
  }) async {
    return getSchedules(
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      ownerId: 'me',
    );
  }

  /// 오늘 일정 조회
  Future<List<Schedule>> getTodaySchedules() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getSchedules(
      dateFrom: todayStr,
      dateTo: todayStr,
      status: 'scheduled',
      ownerId: 'me',
    );
  }

  /// 근무 확인 및 정산 (Shop용)
  Future<Map<String, dynamic>> confirmWork({
    required String scheduleId,
    required bool thumbsUp,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/schedules/$scheduleId/confirm',
        data: {'thumbsUp': thumbsUp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return {
          'amount': data['amount'] ?? 0,
          'returnedEnergy': data['returnedEnergy'] ?? 0,
        };
      } else {
        throw ServerException(
          '정산 실패: ${response.statusMessage}',
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
