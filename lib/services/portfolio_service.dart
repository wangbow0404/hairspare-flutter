import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_portfolio_data.dart';
import '../utils/api_config.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';

/// 작업 포트폴리오 — 스페어·샵 본인 작업 사진 (모델 매칭·프로필 노출).
class PortfolioService {
  PortfolioService({Dio? dio}) : _dio = dio ?? sl<Dio>();

  final Dio _dio;

  Future<List<String>> getImageUrls({
    required String ownerId,
    required String ownerRole,
  }) async {
    if (ApiConfig.useMockData) {
      return MockPortfolioData.getImages(
        ownerRole: ownerRole,
        ownerId: ownerId,
      );
    }
    try {
      final response = await _dio.get('/api/users/$ownerId/portfolio');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data is Map ? data['images'] : data;
        if (list is List) {
          return list.map((e) => e.toString()).toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<List<String>> addLocalImage({
    required String ownerId,
    required String ownerRole,
    required String localPath,
  }) async {
    if (ApiConfig.useMockData) {
      final current = MockPortfolioData.getImages(
        ownerRole: ownerRole,
        ownerId: ownerId,
      );
      return MockPortfolioData.setImages(
        ownerRole: ownerRole,
        ownerId: ownerId,
        images: [...current, localPath],
      );
    }
    try {
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(localPath),
        'ownerRole': ownerRole,
      });
      final response = await _dio.post(
        '/api/users/$ownerId/portfolio',
        data: form,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final list = data is Map ? data['images'] : data;
        if (list is List) {
          return list.map((e) => e.toString()).toList();
        }
      }
      throw ServerException(
        '포트폴리오 업로드 실패',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  Future<List<String>> removeAt({
    required String ownerId,
    required String ownerRole,
    required int index,
  }) async {
    if (ApiConfig.useMockData) {
      final current = MockPortfolioData.getImages(
        ownerRole: ownerRole,
        ownerId: ownerId,
      );
      if (index < 0 || index >= current.length) return current;
      final next = [...current]..removeAt(index);
      return MockPortfolioData.setImages(
        ownerRole: ownerRole,
        ownerId: ownerId,
        images: next,
      );
    }
    try {
      final response = await _dio.delete(
        '/api/users/$ownerId/portfolio/$index',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data is Map ? data['images'] : data;
        if (list is List) {
          return list.map((e) => e.toString()).toList();
        }
      }
      throw ServerException(
        '포트폴리오 삭제 실패',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    }
  }

  /// 샵 스페어 상세 등 [SpareProfile] 조회 시 images 필드 병합.
  Future<List<String>> imagesForSpareProfile(String spareProfileId) async {
    final ownerId =
        MockPortfolioData.portfolioOwnerIdForSpareProfile(spareProfileId);
    if (ownerId == null) return const [];
    return getImageUrls(ownerId: ownerId, ownerRole: 'spare');
  }
}
