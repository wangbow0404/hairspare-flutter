import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_admin_data.dart';
import '../core/di/service_locator.dart';

/// 관리자 서비스
class AdminService {
  final Dio _dio = sl<Dio>();

  /// 대시보드 통계 조회
  Future<Map<String, dynamic>> getDashboardStats() async {
    if (ApiConfig.useMockData) return await MockAdminData.getDashboardStats();
    try {
      final response = await _dio.get('/api/admin/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        // Next.js API 응답 형식 확인: { "stats": {...} } 또는 { "data": { "stats": {...} } }
        debugPrint('[AdminService] Raw response: $data');

        if (data is Map<String, dynamic>) {
          // Next.js API는 { "stats": {...} } 형식으로 반환
          if (data['stats'] != null) {
            debugPrint('[AdminService] Found stats in response');
            return data['stats'] as Map<String, dynamic>;
          }
          // 또는 { "data": { "stats": {...} } } 형식
          if (data['data'] != null && data['data'] is Map) {
            final innerData = data['data'] as Map<String, dynamic>;
            if (innerData['stats'] != null) {
              debugPrint('[AdminService] Found stats in data.stats');
              return innerData['stats'] as Map<String, dynamic>;
            }
            // 또는 data 자체가 stats인 경우
            debugPrint('[AdminService] Using data as stats');
            return innerData;
          }
        }

        debugPrint('[AdminService] Returning raw data');
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          '통계 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 최근 활동 목록 조회
  Future<Map<String, dynamic>> getRecentActivities() async {
    if (ApiConfig.useMockData) return await MockAdminData.getRecentActivities();
    try {
      final response = await _dio.get('/api/admin/activities');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '최근 활동 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원 목록 조회
  Future<Map<String, dynamic>> getUsers({
    String? role,
    String? memberCategory,
    String? search,
    String? signupMethod,
    String? accountStatus,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getUsers(
        page: page,
        limit: limit,
        role: role,
        memberCategory: memberCategory,
        search: search,
      );
    }
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (memberCategory != null && memberCategory.isNotEmpty) {
        queryParams['memberCategory'] = memberCategory;
      } else if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (signupMethod != null &&
          signupMethod.isNotEmpty &&
          signupMethod != 'all') {
        queryParams['signupMethod'] = signupMethod;
      }
      if (accountStatus != null && accountStatus.isNotEmpty) {
        queryParams['accountStatus'] = accountStatus;
      }
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      debugPrint(
        '[AdminService.getUsers] GET /api/admin/users, params: $queryParams',
      );

      final response = await _dio.get(
        '/api/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        debugPrint(
          '[AdminService.getUsers] Raw response type: ${raw.runtimeType}',
        );
        if (raw is Map) {
          debugPrint('[AdminService.getUsers] Raw keys: ${raw.keys.toList()}');
        }

        final data = raw is Map ? (raw['data'] ?? raw) : raw;
        // API가 {users, pagination} 직접 반환 또는 {data: {users, pagination}} 래핑
        dynamic usersRaw;
        if (data is Map) {
          usersRaw =
              data['users'] ??
              (data['data'] is List
                  ? data['data']
                  : (data['data'] is Map ? data['data']['users'] : null)) ??
              data['items'];
        } else {
          usersRaw = null;
        }
        final usersList = usersRaw is List
            ? usersRaw
            : (usersRaw != null ? [usersRaw] : []);
        final usersCount = usersList.length;
        debugPrint('[AdminService.getUsers] Parsed users count: $usersCount');

        final pagination = data is Map
            ? (data['pagination'] ??
                  {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 1})
            : {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 1};
        return {'users': usersList, 'pagination': pagination};
      } else {
        throw ServerException(
          '회원 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원 상세 정보 조회
  Future<Map<String, dynamic>> getUserDetail(String userId) async {
    if (ApiConfig.useMockData) return await MockAdminData.getUserDetail(userId);
    try {
      final response = await _dio.get('/api/admin/users/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '회원 상세 정보 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원 활동내역(공고·지원·스케줄·에너지·노쇼·정산취소·신고) 조회
  Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getUserActivities(userId);
    try {
      final response = await _dio.get('/api/admin/users/$userId/activities');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final items = data is Map ? data['items'] : null;
        if (items is! List) return [];
        return items.whereType<Map<String, dynamic>>().toList();
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원 계정 삭제. permanent=false(기본)면 비활성화(로그인 차단, 기록 보존),
  /// permanent=true면 User 행 자체를 완전히 삭제(복구 불가).
  Future<void> deleteUser(String userId, {bool permanent = false}) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.deleteUser(userId, permanent: permanent);
    }
    try {
      await _dio.delete(
        permanent
            ? '/api/admin/users/$userId/permanent'
            : '/api/admin/users/$userId',
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원이 올린 사진 중 하나 삭제. source: 'profile' | 'model' | 'portfolio'
  Future<void> deleteUserPhoto(
    String userId, {
    required String source,
    required String url,
  }) async {
    try {
      await _dio.delete(
        '/api/admin/users/$userId/photos',
        data: {'source': source, 'url': url},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 크리에이터 프로필 조회. 크리에이터가 아니면 null 반환.
  Future<Map<String, dynamic>?> getUserChallengeProfile(String userId) async {
    try {
      final response = await _dio.get(
        '/api/admin/users/$userId/challenge-profile',
      );
      final data = response.data['data'] ?? response.data;
      return data['profile'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 회원이 올린 챌린지 영상 목록 (숨김 처리된 것 포함 전체)
  Future<List<Map<String, dynamic>>> getUserChallengeVideos(
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/admin/users/$userId/challenge-videos',
      );
      final data = response.data['data'] ?? response.data;
      final videos = data['videos'] as List? ?? [];
      return videos.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 영상 숨김 (is_public=false)
  Future<void> hideChallengeVideo(String videoId) async {
    try {
      await _dio.patch('/api/admin/challenge-videos/$videoId/hide');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 챌린지 영상 삭제
  Future<void> deleteChallengeVideo(String videoId) async {
    try {
      await _dio.delete('/api/admin/challenge-videos/$videoId');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 목록 조회
  Future<Map<String, dynamic>> getJobs({
    String? status,
    bool? isUrgent,
    bool? isOpeningSoon,
    String? dateFrom,
    String? dateTo,
    String? sort,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getJobs(page: page, limit: limit);
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent;
      if (isOpeningSoon != null) queryParams['isOpeningSoon'] = isOpeningSoon;
      if (dateFrom != null && dateFrom.isNotEmpty)
        queryParams['dateFrom'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) queryParams['dateTo'] = dateTo;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/admin/jobs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '공고 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 상세 정보 조회
  Future<Map<String, dynamic>> getJobDetail(String jobId) async {
    if (ApiConfig.useMockData) return await MockAdminData.getJobDetail(jobId);
    try {
      final response = await _dio.get('/api/admin/jobs/$jobId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '공고 상세 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 결제 상세 정보 조회
  Future<Map<String, dynamic>> getPaymentDetail(String paymentId) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getPaymentDetail(paymentId);
    try {
      final response = await _dio.get('/api/admin/payments/$paymentId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '결제 상세 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 결제 목록 조회
  Future<Map<String, dynamic>> getPayments({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getPayments(page: page, limit: limit);
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _dio.get(
        '/api/admin/payments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '결제 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 에너지 거래 내역 조회
  Future<Map<String, dynamic>> getEnergyTransactions({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getEnergyTransactions(
        page: page,
        limit: limit,
      );
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _dio.get(
        '/api/admin/energy',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '에너지 거래 내역 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 지원 목록 조회 (관리자)
  Future<Map<String, dynamic>> getApplications({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getApplications(
        status: status,
        search: search,
        page: page,
        limit: limit,
      );
    }
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/admin/applications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data is Map<String, dynamic>
            ? data
            : {
                'applications': [],
                'pagination': {
                  'page': 1,
                  'limit': 20,
                  'total': 0,
                  'totalPages': 1,
                },
              };
      } else {
        throw ServerException(
          '지원 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          'applications': [],
          'pagination': {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 1},
        };
      }
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 지원 강제 취소 (연락처 교환 등 약관 위반 시 관리자가 처리)
  Future<void> cancelApplication(
    String applicationId, {
    required String reason,
  }) async {
    try {
      await _dio.patch(
        '/api/admin/applications/$applicationId/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 체크인/스케줄 목록 조회
  Future<Map<String, dynamic>> getSchedules({
    String? search,
    String? dateFilter,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getSchedules(page: page, limit: limit);
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (dateFilter != null && dateFilter.isNotEmpty)
        queryParams['dateFilter'] = dateFilter;

      final response = await _dio.get(
        '/api/admin/schedules',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data is Map<String, dynamic>
            ? data
            : {
                'schedules': [],
                'pagination': {
                  'page': 1,
                  'limit': 20,
                  'total': 0,
                  'totalPages': 1,
                },
              };
      } else {
        throw ServerException(
          '체크인 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // API 미구현(404) 시 빈 목록 반환
      if (e.response?.statusCode == 404) {
        return {
          'schedules': [],
          'pagination': {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 1},
        };
      }
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 노쇼 이력 조회
  Future<Map<String, dynamic>> getNoShowHistory({
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData)
      return await MockAdminData.getNoShowHistory(page: page, limit: limit);
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      final response = await _dio.get(
        '/api/admin/noshow',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data;
      } else {
        throw ServerException(
          '노쇼 이력 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 정산취소 요청 목록 조회 (샵이 이미 정산된 근무의 취소를 요청한 건)
  Future<List<dynamic>> getSettlementCancelRequests({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/admin/settlement-cancel-requests',
        queryParameters: {if (status != null) 'status': status},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return (data is Map ? data['requests'] : null) ?? [];
      }
      throw ServerException(
        '정산취소 요청 목록 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 정산취소 요청 승인 — 실제로 스케줄이 취소되고 스페어 노쇼 횟수가 올라간다.
  Future<void> approveSettlementCancelRequest(
    String id, {
    String? adminNote,
  }) async {
    try {
      await _dio.post(
        '/api/admin/settlement-cancel-requests/$id/approve',
        data: {if (adminNote != null) 'adminNote': adminNote},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 정산취소 요청 반려
  Future<void> rejectSettlementCancelRequest(
    String id, {
    String? adminNote,
  }) async {
    try {
      await _dio.post(
        '/api/admin/settlement-cancel-requests/$id/reject',
        data: {if (adminNote != null) 'adminNote': adminNote},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 노쇼 신고 목록 조회 (샵이 신고한 건)
  Future<List<dynamic>> getNoShowReports({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/admin/no-show-reports',
        queryParameters: {if (status != null) 'status': status},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return (data is Map ? data['reports'] : null) ?? [];
      }
      throw ServerException(
        '노쇼 신고 목록 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 노쇼 신고 확정 — 스페어 노쇼 횟수가 올라가고 통보된다.
  Future<void> confirmNoShowReport(String id, {String? adminNote}) async {
    try {
      await _dio.post(
        '/api/admin/no-show-reports/$id/confirm',
        data: {if (adminNote != null) 'adminNote': adminNote},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 노쇼 신고 반려
  Future<void> dismissNoShowReport(String id, {String? adminNote}) async {
    try {
      await _dio.post(
        '/api/admin/no-show-reports/$id/dismiss',
        data: {if (adminNote != null) 'adminNote': adminNote},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // M2. 인증 심사 큐
  // ──────────────────────────────────────────────────────────────────

  /// 인증 심사 대기/처리 목록 조회
  Future<Map<String, dynamic>> getVerifications({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getVerifications(status: status, type: type);
    }
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _dio.get(
        '/api/admin/verifications',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '인증 심사 목록 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증 승인 (감사로그 기록 대상)
  Future<void> approveVerification(String id, {String? note}) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setVerificationStatus(id, 'approved');
      return;
    }
    try {
      await _dio.post(
        '/api/admin/verifications/$id/approve',
        data: {if (note != null) 'note': note},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증 반려 (감사로그 기록 대상)
  Future<void> rejectVerification(String id, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setVerificationStatus(id, 'rejected');
      return;
    }
    try {
      await _dio.post(
        '/api/admin/verifications/$id/reject',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증 심사 상세 (OCR·NTS·증빙)
  Future<Map<String, dynamic>> getVerificationDetail(String id) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getVerificationDetail(id);
    }
    try {
      final response = await _dio.get('/api/admin/verifications/$id');
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '인증 상세 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // M12. 신고/제재 케이스
  // ──────────────────────────────────────────────────────────────────

  /// 신고 케이스 목록 조회
  Future<Map<String, dynamic>> getReports({
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getReports(status: status, category: category);
    }
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '/api/admin/reports',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '신고 목록 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 신고 케이스 처리 — 제재/반려 (감사로그 기록 대상)
  /// [action]: dismiss | warn | suspend | ban
  Future<void> resolveReport(
    String id, {
    required String action,
    String? reason,
    int? durationDays,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setReportStatus(id, 'resolved');
      return;
    }
    try {
      await _dio.post(
        '/api/admin/reports/$id/resolve',
        data: {
          'action': action,
          if (reason != null) 'reason': reason,
          if (durationDays != null) 'durationDays': durationDays,
        },
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 신고 케이스 상세
  Future<Map<String, dynamic>> getReportDetail(String id) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getReportDetail(id);
    }
    try {
      final response = await _dio.get('/api/admin/reports/$id');
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '신고 상세 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 채팅 로그 감사 뷰 (M12)
  Future<Map<String, dynamic>> getChatTranscript(String chatId) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getChatTranscript(chatId);
    }
    try {
      final response = await _dio.get('/api/admin/chats/$chatId/transcript');
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '채팅 로그 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // M15. 비즈니스 설정
  // ──────────────────────────────────────────────────────────────────

  /// 비즈니스 설정 그룹/항목 조회
  Future<Map<String, dynamic>> getBusinessSettings() async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getBusinessSettings();
    }
    try {
      final response = await _dio.get('/api/admin/settings');
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '비즈니스 설정 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 비즈니스 설정 값 변경 (감사로그 기록 대상)
  Future<void> updateBusinessSetting(String key, dynamic value) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    try {
      await _dio.patch('/api/admin/settings/$key', data: {'value': value});
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // M18. 감사 로그
  // ──────────────────────────────────────────────────────────────────

  /// 감사 로그 조회 (읽기 전용 · 불변)
  Future<Map<String, dynamic>> getAuditLogs({
    String? action,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) {
      return await MockAdminData.getAuditLogs(action: action, search: search);
    }
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (action != null && action.isNotEmpty) queryParams['action'] = action;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/admin/audit-logs',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw ServerException(
        '감사 로그 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ── M1 회원 mutation ──
  Future<void> suspendUser(
    String userId, {
    required String reason,
    DateTime? until,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setUserSuspended(userId, suspended: true);
      return;
    }
    await _dio.post(
      '/api/admin/users/$userId/suspend',
      data: {
        'reason': reason,
        if (until != null) 'until': until.toIso8601String(),
      },
    );
  }

  Future<void> unsuspendUser(String userId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setUserSuspended(userId, suspended: false);
      return;
    }
    await _dio.post(
      '/api/admin/users/$userId/unsuspend',
      data: {'reason': reason},
    );
  }

  Future<void> adjustEnergy(
    String userId,
    int delta, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/users/$userId/energy',
      data: {'delta': delta, 'reason': reason},
    );
  }

  Future<void> adjustPoints(
    String userId,
    int delta, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/users/$userId/points',
      data: {'delta': delta, 'reason': reason},
    );
  }

  // ── M3 공고 mutation ──
  Future<void> hideJob(
    String jobId, {
    required String reason,
    bool hide = true,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setJobHidden(jobId, hide: hide);
      return;
    }
    await _dio.patch(
      '/api/admin/jobs/$jobId/hide',
      data: {'hide': hide, 'reason': reason},
    );
  }

  Future<void> forceCloseJob(String jobId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setJobClosed(jobId);
      return;
    }
    await _dio.patch('/api/admin/jobs/$jobId/close', data: {'reason': reason});
  }

  Future<void> deleteJob(String jobId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.delete('/api/admin/jobs/$jobId', data: {'reason': reason});
  }

  // ── M4 스케줄 mutation ──
  Future<void> forceCompleteSchedule(
    String scheduleId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setScheduleState(scheduleId, 'completed');
      return;
    }
    await _dio.post(
      '/api/admin/schedules/$scheduleId/complete',
      data: {'reason': reason},
    );
  }

  Future<void> forceCancelSchedule(
    String scheduleId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setScheduleState(scheduleId, 'cancelled');
      return;
    }
    await _dio.post(
      '/api/admin/schedules/$scheduleId/cancel',
      data: {'reason': reason},
    );
  }

  Future<void> markNoShow(
    String scheduleId, {
    required String reason,
    required String party,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.setScheduleState(scheduleId, 'noshow');
      return;
    }
    await _dio.post(
      '/api/admin/schedules/$scheduleId/noshow',
      data: {'reason': reason, 'party': party},
    );
  }

  // ── M5 모델 매칭 ──
  Future<Map<String, dynamic>> getMatches({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.useMockData) return MockAdminData.getMatches(status: status);
    final response = await _dio.get(
      '/api/admin/matches',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> forceCancelMatch(
    String matchId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/matches/$matchId/cancel',
      data: {'reason': reason},
    );
  }

  // ── M6 공간 대여 ──
  Future<Map<String, dynamic>> getSpaces({String? status}) async {
    if (ApiConfig.useMockData) return MockAdminData.getSpaces(status: status);
    final response = await _dio.get(
      '/api/admin/spaces',
      queryParameters: {if (status != null) 'status': status},
    );
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getSpaceBookings({String? status}) async {
    if (ApiConfig.useMockData)
      return MockAdminData.getSpaceBookings(status: status);
    final response = await _dio.get(
      '/api/admin/space-bookings',
      queryParameters: {if (status != null) 'status': status},
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> forceCancelBooking(
    String bookingId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/space-bookings/$bookingId/cancel',
      data: {'reason': reason},
    );
  }

  // ── M7 교육 ──
  Future<Map<String, dynamic>> getEducations({String? status}) async {
    if (ApiConfig.useMockData)
      return MockAdminData.getEducations(status: status);
    final response = await _dio.get(
      '/api/admin/educations',
      queryParameters: {if (status != null) 'status': status},
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> hideEducation(
    String educationId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.patch(
      '/api/admin/educations/$educationId/hide',
      data: {'reason': reason},
    );
  }

  Future<void> refundEnrollment(
    String enrollmentId, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/enrollments/$enrollmentId/refund',
      data: {'reason': reason},
    );
  }

  // ── M8 결제 mutation ──
  Future<void> refundPayment(
    String paymentId, {
    required int amount,
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/payments/$paymentId/refund',
      data: {'amount': amount, 'reason': reason},
    );
  }

  // ── M9 에너지 mutation ──
  Future<void> grantEnergy(
    String userId,
    int amount, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/energy/grant',
      data: {'userId': userId, 'amount': amount, 'reason': reason},
    );
  }

  Future<void> deductEnergy(
    String userId,
    int amount, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/energy/deduct',
      data: {'userId': userId, 'amount': amount, 'reason': reason},
    );
  }

  // ── M10 포인트·미션 ──
  Future<Map<String, dynamic>> getPointTransactions({String? type}) async {
    if (ApiConfig.useMockData)
      return MockAdminData.getPointTransactions(type: type);
    final response = await _dio.get(
      '/api/admin/points',
      queryParameters: {if (type != null) 'type': type},
    );
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getMissions() async {
    if (ApiConfig.useMockData) return MockAdminData.getMissions();
    final response = await _dio.get('/api/admin/missions');
    return response.data['data'] ?? response.data;
  }

  Future<void> grantPoints(
    String userId,
    int amount, {
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/points/grant',
      data: {'userId': userId, 'amount': amount, 'reason': reason},
    );
  }

  // ── M11 구독 ──
  Future<Map<String, dynamic>> getSubscriptions() async {
    if (ApiConfig.useMockData) return MockAdminData.getSubscriptions();
    final response = await _dio.get('/api/admin/subscriptions');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getCreators() async {
    if (ApiConfig.useMockData) return MockAdminData.getCreators();
    final response = await _dio.get('/api/admin/creators');
    return response.data['data'] ?? response.data;
  }

  Future<void> verifyCreator(String creatorId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/creators/$creatorId/verify',
      data: {'reason': reason},
    );
  }

  // ── M13 제재 ──
  Future<Map<String, dynamic>> getSanctions({String? status}) async {
    if (ApiConfig.useMockData)
      return MockAdminData.getSanctions(status: status);
    final response = await _dio.get(
      '/api/admin/sanctions',
      queryParameters: {if (status != null) 'status': status},
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> applySanction(
    String userId, {
    required String type,
    required String reason,
    int? durationDays,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/sanctions',
      data: {
        'userId': userId,
        'type': type,
        'reason': reason,
        if (durationDays != null) 'durationDays': durationDays,
      },
    );
  }

  Future<void> liftSanction(String sanctionId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.delete(
      '/api/admin/sanctions/$sanctionId',
      data: {'reason': reason},
    );
  }

  // ── M14 콘텐츠 ──
  Future<Map<String, dynamic>> getContentItems({
    String? type,
    String? flagged,
  }) async {
    if (ApiConfig.useMockData)
      return MockAdminData.getContentItems(type: type, flagged: flagged);
    final response = await _dio.get(
      '/api/admin/content',
      queryParameters: {
        if (type != null) 'type': type,
        if (flagged != null) 'flagged': flagged,
      },
    );
    return response.data['data'] ?? response.data;
  }

  Future<void> hideContent(String contentId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.patch(
      '/api/admin/content/$contentId/hide',
      data: {'reason': reason},
    );
  }

  Future<void> deleteContent(String contentId, {required String reason}) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.delete(
      '/api/admin/content/$contentId',
      data: {'reason': reason},
    );
  }

  // ── M16 알림 ──
  Future<Map<String, dynamic>> getNotificationData() async {
    if (ApiConfig.useMockData) return MockAdminData.getNotificationData();
    final response = await _dio.get('/api/admin/notifications');
    return response.data['data'] ?? response.data;
  }

  Future<void> broadcastNotification({
    required String audience,
    required String title,
    required String body,
    required String reason,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return;
    }
    await _dio.post(
      '/api/admin/notifications/broadcast',
      data: {
        'audience': audience,
        'title': title,
        'body': body,
        'reason': reason,
      },
    );
  }

  // ── M17 레퍼런스 ──
  Future<Map<String, dynamic>> getReferenceData({String? tab}) async {
    if (ApiConfig.useMockData) return MockAdminData.getReferenceData(tab: tab);
    final response = await _dio.get(
      '/api/admin/reference',
      queryParameters: {if (tab != null) 'tab': tab},
    );
    return response.data['data'] ?? response.data;
  }
}
