import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';

class Review {
  final String id;
  final String shopName;
  final String shopId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.shopName,
    required this.shopId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      shopName: json['shopName'] as String? ?? json['shop']?['name'] as String? ?? '',
      shopId: json['shopId'] as String? ?? json['shopId'] as String? ?? '',
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  /// 리뷰 목록 조회
  Future<List<Review>> getReviews() async {
    if (ApiConfig.useMockData) return await MockSpareData.getReviews();
    try {
      final response = await _apiClient.dio.get('/api/reviews');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> reviewsJson = data is List
            ? data
            : (data is Map && data['reviews'] != null
                ? (data['reviews'] as List)
                : []);
        return reviewsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Review.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '리뷰 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// shopName으로 shopId 찾기
  Future<String?> findShopIdByName(String shopName) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/shops/search',
        queryParameters: {'name': shopName},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is List && data.isNotEmpty) {
          // 첫 번째 매칭되는 shop의 ID 반환
          return data[0]['id']?.toString() ?? data[0]['shopId']?.toString();
        } else if (data is Map) {
          return data['id']?.toString() ?? data['shopId']?.toString();
        }
      }
      return null;
    } on DioException catch (e) {
      // shop을 찾지 못한 경우 null 반환 (새 shop으로 처리)
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 리뷰 등록
  Future<Review> createReview({
    required String shopName,
    String? shopId,
    required int rating,
    required String comment,
  }) async {
    try {
      // shopId가 없으면 shopName으로 찾기 시도
      String? finalShopId = shopId;
      if (finalShopId == null || finalShopId.isEmpty) {
        finalShopId = await findShopIdByName(shopName);
      }

      final response = await _apiClient.dio.post(
        '/api/reviews',
        data: {
          'shopName': shopName,
          if (finalShopId != null && finalShopId.isNotEmpty) 'shopId': finalShopId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return Review.fromJson(data);
      } else {
        throw ServerException(
          '리뷰 등록 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 따봉 전송 (work check용)
  Future<void> sendThumbsUp({
    required String jobId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/reviews/thumbs-up',
        data: {
          'jobId': jobId,
        },
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
}
