import 'package:dio/dio.dart';
import '../models/job.dart';
import '../models/schedule.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../utils/schedule_cancellation_policy.dart';
import '../utils/schedule_conflict.dart';
import '../utils/schedule_work_session.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';

class ScheduleService {
  final Dio _dio = sl<Dio>();

  /// [jobId]에 연결된 스페어 스케줄 1건 (없으면 null).
  Future<Schedule?> findScheduleForJob(String jobId) async {
    final list = await getSchedules(ownerId: 'me');
    for (final s in list) {
      if (s.jobId == jobId) return s;
    }
    return null;
  }

  /// [scheduleId] 수락 시 겹치는 확정·제안 일정.
  Future<List<Schedule>> findAcceptProposalConflicts(String scheduleId) async {
    final list = await getSchedules(ownerId: 'me');
    Schedule? target;
    for (final s in list) {
      if (s.id == scheduleId) {
        target = s;
        break;
      }
    }
    if (target == null) return [];
    final window = ScheduleConflict.windowFromSchedule(target);
    if (window == null) return [];
    return ScheduleConflict.findBlockingSchedules(
      all: list,
      candidate: window,
      ignoreScheduleId: scheduleId,
    );
  }

  /// [jobId] 지원 시 겹치는 확정·제안 일정.
  Future<List<Schedule>> findApplyConflictsForJob(Job job) async {
    final window = ScheduleConflict.windowFromJob(job);
    if (window == null) return [];
    final list = await getSchedules(ownerId: 'me');
    return ScheduleConflict.findBlockingSchedules(
      all: list,
      candidate: window,
    );
  }

  /// 근무 제안 수락
  Future<Schedule> acceptWorkProposal(String scheduleId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.acceptWorkProposal(scheduleId);
    }
    try {
      final response = await _dio.post(
        '/api/schedules/$scheduleId/accept-proposal',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return Schedule.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '근무 제안 수락 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 근무 제안 거절
  Future<void> rejectWorkProposal(String scheduleId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.rejectWorkProposal(scheduleId);
    }
    try {
      final response = await _dio.post(
        '/api/schedules/$scheduleId/reject-proposal',
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          '근무 제안 거절 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스케줄 목록 조회
  Future<List<Schedule>> getSchedules({
    String? dateFrom,
    String? dateTo,
    String? status,
    String? ownerId, // 'me'로 설정하면 자신의 스케줄만 조회
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getSchedules(
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
        ownerId: ownerId,
      );
    }
    try {
      final queryParams = <String, dynamic>{};
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (status != null) queryParams['status'] = status;
      if (ownerId != null) queryParams['ownerId'] = ownerId;

      final response = await _dio.get(
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

  /// 스케줄 취소 (v2: 시작 전까지 — mock·클라이언트 가드).
  Future<void> cancelSchedule(
    String scheduleId, {
    String? cancelReason,
    CancellationActor actor = CancellationActor.spare,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.cancelSchedule(
        scheduleId,
        cancelReason: cancelReason,
        actor: actor,
      );
    }
    try {
      final response = await _dio.post(
        '/api/schedules/$scheduleId/cancel',
        data: {
          if (cancelReason != null && cancelReason.isNotEmpty)
            'cancelReason': cancelReason,
          'actor': actor.name,
          'cancellationPolicyVersion':
              ScheduleCancellationPolicy.activeVersion.name,
        },
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

  /// 스케줄 변경 요청(날짜/시간 조정)
  Future<void> requestScheduleChange({
    required String scheduleId,
    required DateTime newDate,
    String? reason,
  }) async {
    if (ApiConfig.useMockData) {
      return;
    }
    try {
      final response = await _dio.post(
        '/api/schedules/$scheduleId/change-request',
        data: {
          'newDate': newDate.toIso8601String(),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          '스케줄 변경 요청 실패: ${response.statusMessage}',
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
      final response = await _dio.get('/api/work-check/stats');

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
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final list = await MockSpareData.getSchedules();
      final idx = list.indexWhere((s) => s.id == scheduleId);
      if (idx < 0) {
        throw ServerException('스케줄을 찾을 수 없습니다.', statusCode: 404);
      }
      final existing = list[idx];
      final json = existing.toJson();
      json['status'] = 'completed';
      json['checkInTime'] = DateTime.now().toIso8601String();
      return Schedule.fromJson(json);
    }
    try {
      final response = await _dio.post(
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
    if (ApiConfig.useMockData) {
      return MockSpareData.confirmWork(
        scheduleId: scheduleId,
        thumbsUp: thumbsUp,
      );
    }
    final schedules = await getMySchedules();
    final schedule = schedules.cast<Schedule?>().firstWhere(
          (s) => s!.id == scheduleId,
          orElse: () => null,
        );
    if (schedule != null) {
      final blocked = ScheduleWorkSession.settlementBlockedMessage(schedule);
      if (blocked != null) {
        throw ValidationException(blocked);
      }
    }
    try {
      final response = await _dio.post(
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
