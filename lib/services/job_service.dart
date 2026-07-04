import 'package:dio/dio.dart';
import '../models/job.dart';
import '../models/create_job_request.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_auth_data.dart';
import '../mocks/mock_shop_data.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';
import '../providers/auth_provider.dart';

class JobService {
  final Dio _dio = sl<Dio>();

  /// 공고 등록
  /// 공고 등록. (Job, isFirstJob) 레코드 반환.
  Future<(Job, bool)> createJob(CreateJobRequest request) async {
    if (ApiConfig.useMockData) {
      final existingJobs = await MockShopData.getMyJobs();
      final isFirst = existingJobs.isEmpty;
      final job = Job(
        id: 'mock-job-${DateTime.now().millisecondsSinceEpoch}',
        title: request.title,
        shopName: request.shopDisplayName ?? '내 매장',
        date: request.workDate,
        time: request.startTime,
        endTime: request.endTime,
        amount: request.amount,
        energy: request.amount ~/ 1000,
        requiredCount: request.requiredCount,
        regionId: request.districtId,
        description: request.description,
        images: request.imageLocalPaths.isEmpty ? null : request.imageLocalPaths,
        isUrgent: request.isUrgent,
        isPremium: false,
        isOpeningSoon: false,
        createdAt: DateTime.now(),
        status: 'published',
        ownerId: 'me',
      );
      final created = await MockShopData.addMyJob(job);
      return (created, isFirst);
    }
    try {
      final response = await _dio.post(
        '/api/jobs',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final jobJson =
            data is Map<String, dynamic> && data['job'] is Map<String, dynamic>
            ? data['job'] as Map<String, dynamic>
            : (data as Map<String, dynamic>);
        final isFirstJob = data is Map<String, dynamic>
            ? (data['isFirstJob'] as bool? ?? false)
            : false;
        return (Job.fromJson(jobJson), isFirstJob);
      }
      throw ServerException(
        '공고 등록 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 오픈예정 결제 완료 후 공고를 오픈예정 섹션에 노출 설정.
  Future<void> setOpeningSoon(String jobId) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return;
    }
    try {
      await _dio.patch('/api/jobs/$jobId', data: {'isOpeningSoon': true});
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 목록 조회
  Future<List<Job>> getJobs({
    List<String>? regionIds,
    bool? isUrgent,
    bool? isPremium,
    String? dateFrom,
    String? dateTo,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    if (ApiConfig.useMockData) return await MockSpareData.getJobs(searchQuery: searchQuery);
    try {
      final queryParams = <String, dynamic>{};
      if (regionIds != null && regionIds.isNotEmpty) {
        queryParams['regionIds'] = regionIds;
      }
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent;
      if (isPremium != null) queryParams['isPremium'] = isPremium;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
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
    if (ApiConfig.useMockData) {
      return MockShopData.getMyJobs(
        status: status,
        search: search,
        limit: limit,
        offset: offset,
      );
    }
    // TODO: 서버에서도 근무일 경과 시 expired 전환·active 필터 지원 필요.
    try {
      final response = await _dio.get('/api/jobs/my');

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

  /// 샵「내 공고」상세 — mock/API 모두 내 공고 저장소만 조회.
  Future<Job> getMyJobById(String jobId) async {
    if (ApiConfig.useMockData) {
      final job = await MockShopData.getMyJobById(jobId);
      if (job == null) {
        throw NotFoundException('공고를 찾을 수 없습니다');
      }
      return job;
    }
    try {
      final response = await _dio.get('/api/jobs/$jobId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Job.fromJson(data as Map<String, dynamic>);
      }
      throw NotFoundException('공고를 찾을 수 없습니다');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 상세 조회 (내 공고는 [MockShopData] 우선)
  Future<Job> getJobById(String jobId) async {
    if (ApiConfig.useMockData) {
      final mine = await MockShopData.getMyJobById(jobId);
      if (mine != null) return mine;
      return MockSpareData.getJobById(jobId);
    }
    try {
      final response = await _dio.get('/api/jobs/$jobId');

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
    if (ApiConfig.useMockData) {
      // 에너지 검증·차감을 상태 변경보다 먼저 실행해 부분 실패(partial failure) 방지
      final job = await MockSpareData.getJobById(jobId);
      await MockSpareData.applyToJob(jobId); // 스케줄 충돌 검사 (상태 변경 없음)
      await MockSpareData.mockSpendEnergy(   // 에너지 부족 시 여기서 throw → 아래 상태 변경 차단
        job.energy,
        description: '공고 지원 · ${job.title}',
        referenceId: jobId,
      );
      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      await MockShopData.addApplication(
        jobId: jobId,
        spare: {
          'id': user.id,
          'username': user.username,
          'name': user.name,
          'email': user.email,
          'createdAt': user.createdAt.toIso8601String(),
        },
      );
      MockSpareData.recordLockedEnergyForJobApplication(
        jobId: jobId,
        spareId: user.id,
        amount: job.energy,
      );
      MockSpareData.ensureChatForJobApplication(
        jobId: jobId,
        jobTitle: job.title,
        shopName: job.shopName,
        spareId: user.id,
        spareName: user.name ?? user.username,
      );
      return;
    }
    try {
      final response = await _dio.post(
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

  /// 공고 숨김 해제
  Future<void> unhideJob(String jobId) async {
    if (ApiConfig.useMockData) {
      final updated = await MockShopData.unhideMyJob(jobId);
      if (updated == null) {
        throw NotFoundException('공고를 찾을 수 없습니다');
      }
      return;
    }
    try {
      final response = await _dio.patch(
        '/api/jobs/$jobId',
        data: {'isHidden': false},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '숨김 해제 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 숨김 (스페어 목록에서만 비노출, 샵 내 공고에는 유지)
  Future<void> hideJob(String jobId) async {
    if (ApiConfig.useMockData) {
      final updated = await MockShopData.hideMyJob(jobId);
      if (updated == null) {
        throw NotFoundException('공고를 찾을 수 없습니다');
      }
      return;
    }
    try {
      final response = await _dio.patch(
        '/api/jobs/$jobId',
        data: {'isHidden': true},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '공고 숨김 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 수정
  Future<Job> updateJob(String jobId, CreateJobRequest request) async {
    if (ApiConfig.useMockData) {
      final updated = await MockShopData.updateMyJob(jobId, {
        'title': request.title,
        'description': request.description,
        'amount': request.amount,
        'requiredCount': request.requiredCount,
        'regionId': request.districtId,
        'date': request.workDate,
        'time': request.startTime,
        'endTime': request.endTime,
        'isUrgent': request.isUrgent,
      });
      if (updated == null) {
        throw NotFoundException('공고를 찾을 수 없습니다');
      }
      return updated;
    }
    try {
      final response = await _dio.patch(
        '/api/jobs/$jobId',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final jobJson =
            data is Map<String, dynamic> && data['job'] is Map<String, dynamic>
                ? data['job'] as Map<String, dynamic>
                : (data as Map<String, dynamic>);
        return Job.fromJson(jobJson);
      }
      throw ServerException(
        '공고 수정 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 상태 업데이트 (마감/재오픈)
  Future<void> updateJobStatus(String jobId, String status) async {
    if (ApiConfig.useMockData) {
      final updated = await MockShopData.updateMyJob(jobId, {'status': status});
      if (updated == null) {
        throw NotFoundException('공고를 찾을 수 없습니다');
      }
      return;
    }
    try {
      final response = await _dio.patch(
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

  /// 공고 삭제.
  /// 이미 승인된 지원자가 있으면 백엔드가 [reason] 없이는 REASON_REQUIRED로 거부한다.
  Future<void> deleteJob(String jobId, {String? reason}) async {
    if (ApiConfig.useMockData) {
      final ok = await MockShopData.deleteMyJob(jobId);
      if (!ok) throw NotFoundException('공고를 찾을 수 없습니다');
      return;
    }
    try {
      final response = await _dio.delete(
        '/api/jobs/$jobId',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '공고 삭제 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      final code = errorBody is Map
          ? (errorBody['error']?['code'] as String?)
          : null;
      if (code == 'REASON_REQUIRED') {
        final message = errorBody is Map
            ? (errorBody['error']?['message'] as String?)
            : null;
        throw ValidationException(
          message ?? '삭제 사유를 입력해주세요',
          code: 'REASON_REQUIRED',
        );
      }
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 연락처 위반으로 해당 공고 연락·재지원이 차단되었는지.
  Future<bool> isContactBannedForJob(String jobId) async {
    if (ApiConfig.useMockData) {
      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      return MockSpareData.isContactBannedForJob(
        jobId: jobId,
        spareId: user.id,
      );
    }
    try {
      final response = await _dio.get('/api/jobs/$jobId/contact-ban');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['banned'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내 지원 상태 (없으면 null).
  Future<String?> getSpareApplicationStatusForJob(String jobId) async {
    if (ApiConfig.useMockData) {
      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      return MockShopData.spareApplicationStatusForJob(
        jobId: jobId,
        spareId: user.id,
      );
    }
    try {
      final response = await _dio.get('/api/jobs/$jobId/my-application');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['status']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
