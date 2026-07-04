import 'dart:io';

import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../utils/api_config.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';

/// 모델 본인 프로필 — 가입 시 입력한 정보(기장·선호시술·경력·자기소개·사진 등) 조회/수정.
class ModelSelfProfile {
  const ModelSelfProfile({
    required this.hairLength,
    required this.preferredTreatments,
    required this.imageTags,
    required this.career,
    required this.shootAgreement,
    required this.intro,
    required this.region,
    required this.imageUrls,
  });

  factory ModelSelfProfile.fromJson(Map<String, dynamic> json) {
    List<String> stringList(Object? v) =>
        v is List ? v.map((e) => e.toString()).toList() : <String>[];
    return ModelSelfProfile(
      hairLength: json['hairLength']?.toString() ?? '',
      preferredTreatments: stringList(json['preferredTreatments']),
      imageTags: stringList(json['imageTags']),
      career: json['career']?.toString() ?? '',
      shootAgreement: json['shootAgreement']?.toString() ?? '',
      intro: json['intro']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      imageUrls: stringList(json['imageUrls']),
    );
  }

  final String hairLength;
  final List<String> preferredTreatments;
  final List<String> imageTags;
  final String career;
  final String shootAgreement;
  final String intro;
  final String region;
  final List<String> imageUrls;
}

class ModelSelfProfileService {
  ModelSelfProfileService({Dio? dio}) : _dio = dio ?? sl<Dio>();

  final Dio _dio;

  Future<ModelSelfProfile> getMyProfile() async {
    try {
      final response = await _dio.get('/api/models/me/profile');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ModelSelfProfile.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '모델 프로필 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<ModelSelfProfile> updateMyProfile({
    String? hairLength,
    List<String>? preferredTreatments,
    List<String>? imageTags,
    String? career,
    String? intro,
    String? region,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _dio.put(
        '/api/model-match/profile',
        data: {
          if (hairLength != null) 'hairLength': hairLength,
          if (preferredTreatments != null)
            'preferredTreatments': preferredTreatments,
          if (imageTags != null) 'imageTags': imageTags,
          if (career != null) 'career': career,
          if (intro != null) 'intro': intro,
          if (region != null) 'region': region,
          if (imageUrls != null) 'imageUrls': imageUrls,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return ModelSelfProfile.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '모델 프로필 수정 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 사진 업로드 (R2) — 목록에 바로 추가할 URL을 받는다.
  Future<String> uploadPhoto(File file) async {
    if (ApiConfig.useMockData) {
      return 'https://via.placeholder.com/400';
    }
    try {
      final response = await _dio.post(
        '/api/auth/upload-image',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: 'model-${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        }),
        queryParameters: {'folder': 'model-photos'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final url = data is Map ? data['url']?.toString() : null;
        if (url == null || url.isEmpty) {
          throw ServerException('사진 업로드 응답이 올바르지 않습니다');
        }
        return url;
      }
      throw ServerException(
        '사진 업로드 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
