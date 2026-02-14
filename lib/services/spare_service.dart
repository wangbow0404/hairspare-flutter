import 'package:dio/dio.dart';
import '../models/spare_profile.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_shop_data.dart';

class SpareService {
  final ApiClient _apiClient = ApiClient();

  /// 스페어 목록 조회
  Future<List<SpareProfile>> getSpares({
    List<String>? regionIds,
    String? role,
    bool? isVerified,
    bool? isLicenseVerified,
    String? sortBy, // "popular" | "newest" | "experience" | "completed"
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    if (ApiConfig.useMockData) return await MockShopData.getSpares();
    try {
      final queryParams = <String, dynamic>{};
      if (regionIds != null && regionIds.isNotEmpty) {
        queryParams['regionIds'] = regionIds;
      }
      if (role != null) {
        queryParams['role'] = role;
      }
      if (isVerified != null) {
        queryParams['isVerified'] = isVerified;
      }
      if (isLicenseVerified != null) {
        queryParams['isLicenseVerified'] = isLicenseVerified;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // FastAPI는 'search' 또는 'searchQuery' 모두 지원
        queryParams['search'] = searchQuery;
        queryParams['searchQuery'] = searchQuery;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (offset != null) {
        queryParams['offset'] = offset;
      }

      final response = await _apiClient.dio.get(
        '/api/spares',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // FastAPI 응답 형식 처리: {"success": True, "data": {"spares": [...], "total": ...}}
        List<dynamic> sparesJson = [];
        
        if (responseData is Map) {
          // success/data/spares 형식 (FastAPI Gateway)
          if (responseData['success'] == true && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map && data['spares'] != null) {
              sparesJson = data['spares'] as List;
            } else if (data is List) {
              sparesJson = data;
            }
          }
          // data/spares 형식
          else if (responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map && data['spares'] != null) {
              sparesJson = data['spares'] as List;
            } else if (data is List) {
              sparesJson = data;
            }
          }
          // 직접 spares 형식
          else if (responseData['spares'] != null) {
            sparesJson = responseData['spares'] as List;
          }
        } else if (responseData is List) {
          sparesJson = responseData;
        }
        
        return sparesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SpareProfile.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '스페어 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스페어 상세 조회
  Future<SpareProfile> getSpareById(String spareId) async {
    if (ApiConfig.useMockData) return await MockShopData.getSpareById(spareId);
    try {
      final response = await _apiClient.dio.get('/api/spares/$spareId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is! Map<String, dynamic>) {
          throw ValidationException('스페어 응답 형식이 올바르지 않습니다');
        }
        return SpareProfile.fromJson(data);
      } else {
        throw ServerException(
          '스페어 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스페어에게 따봉 주기 (Shop 전용)
  Future<void> giveThumbsUpToSpare(String spareId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/spares/$spareId/thumbs-up',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '따봉 전송 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스페어 따봉 취소 (Shop 전용)
  Future<void> removeThumbsUpFromSpare(String spareId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/spares/$spareId/thumbs-up',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '따봉 취소 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 스페어 따봉 상태 확인 (Shop 전용)
  Future<bool> hasThumbsUpForSpare(String spareId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/spares/$spareId/thumbs-up/status',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is Map) {
          return data['hasThumbsUp'] as bool? ?? false;
        }
        return false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }
}
