import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

/// 관리자 서비스
class AdminService {
  final ApiClient _apiClient = ApiClient();

  /// 대시보드 통계 조회
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/api/admin/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        // Next.js API 응답 형식 확인: { "stats": {...} } 또는 { "data": { "stats": {...} } }
        print('[AdminService] Raw response: $data');
        
        if (data is Map<String, dynamic>) {
          // Next.js API는 { "stats": {...} } 형식으로 반환
          if (data['stats'] != null) {
            print('[AdminService] Found stats in response');
            return data['stats'] as Map<String, dynamic>;
          }
          // 또는 { "data": { "stats": {...} } } 형식
          if (data['data'] != null && data['data'] is Map) {
            final innerData = data['data'] as Map<String, dynamic>;
            if (innerData['stats'] != null) {
              print('[AdminService] Found stats in data.stats');
              return innerData['stats'] as Map<String, dynamic>;
            }
            // 또는 data 자체가 stats인 경우
            print('[AdminService] Using data as stats');
            return innerData;
          }
        }
        
        print('[AdminService] Returning raw data');
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
    try {
      final response = await _apiClient.dio.get('/api/admin/activities');
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
    String? search,
    String? signupMethod,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (signupMethod != null && signupMethod.isNotEmpty && signupMethod != 'all') {
        queryParams['signupMethod'] = signupMethod;
      }

      debugPrint('[AdminService.getUsers] GET /api/admin/users, params: $queryParams');

      final response = await _apiClient.dio.get(
        '/api/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        debugPrint('[AdminService.getUsers] Raw response type: ${raw.runtimeType}');
        if (raw is Map) {
          debugPrint('[AdminService.getUsers] Raw keys: ${raw.keys.toList()}');
        }

        final data = raw is Map ? (raw['data'] ?? raw) : raw;
        // API가 {users, pagination} 직접 반환 또는 {data: {users, pagination}} 래핑
        dynamic usersRaw;
        if (data is Map) {
          usersRaw = data['users'] ??
              (data['data'] is List ? data['data'] : (data['data'] is Map ? data['data']['users'] : null)) ??
              data['items'];
        } else {
          usersRaw = null;
        }
        final usersList = usersRaw is List ? usersRaw : (usersRaw != null ? [usersRaw] : []);
        final usersCount = usersList is List ? usersList.length : 0;
        debugPrint('[AdminService.getUsers] Parsed users count: $usersCount');

        final pagination = data is Map
            ? (data['pagination'] ?? {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 1})
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
    try {
      final response = await _apiClient.dio.get('/api/admin/users/$userId');

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

  /// 공고 목록 조회
  Future<Map<String, dynamic>> getJobs({
    String? status,
    bool? isUrgent,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
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
    try {
      final response = await _apiClient.dio.get('/api/admin/jobs/$jobId');
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
    try {
      final response = await _apiClient.dio.get('/api/admin/payments/$paymentId');
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
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
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
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
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

  /// 노쇼 이력 조회
  Future<Map<String, dynamic>> getNoShowHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.dio.get(
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
}
