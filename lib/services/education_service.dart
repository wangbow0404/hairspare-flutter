import 'package:dio/dio.dart';

import '../mocks/mock_spare_data.dart';
import '../models/create_education_request.dart';
import '../models/education_enrollment.dart';
import '../models/education_post_result.dart';
import '../screens/spare/education_screen.dart';
import '../utils/api_config.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';
import '../core/di/service_locator.dart';

class EducationService {
  final Dio _dio = sl<Dio>();

  Future<EducationPostResult> createEducation(
    CreateEducationRequest request,
  ) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return EducationPostResult(
        id: 'mock-education-${DateTime.now().millisecondsSinceEpoch}',
        title: request.title,
      );
    }

    try {
      final response = await _dio.post(
        '/api/educations',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final result =
            data is Map<String, dynamic> ? data : <String, dynamic>{};
        return EducationPostResult(
          id: result['id']?.toString() ?? '',
          title: result['title']?.toString() ?? request.title,
        );
      }

      throw ServerException(
        '교육 등록 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Education?> getEducationById(String educationId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getEducationById(educationId);
    }
    try {
      final response = await _dio.get('/api/educations/$educationId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is! Map<String, dynamic>) return null;
        return _educationFromApiJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<EducationEnrollment?> getEnrollmentByEducationId(
    String educationId,
  ) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getEnrollmentByEducationId(educationId);
    }
    try {
      final response =
          await _dio.get('/api/educations/$educationId/enrollment-status');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data == null) return null;
        if (data is Map && data['enrolled'] == false) return null;
        if (data is Map<String, dynamic> && data['enrollment'] != null) {
          return EducationEnrollment.fromJson(
            data['enrollment'] as Map<String, dynamic>,
          );
        }
        if (data is Map<String, dynamic> && data['id'] != null) {
          return EducationEnrollment.fromJson(data);
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 에너지로 교육 신청 — 서버가 energyCost 검증·차감·enrollment 발급.
  Future<EducationEnrollment> enrollWithEnergy(String educationId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.mockEnrollInEducation(educationId);
    }
    try {
      final response = await _dio.post(
        '/api/educations/$educationId/enroll',
        data: {'payWith': 'energy'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return EducationEnrollment.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '교육 신청 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<EducationEnrollment> getEnrollment(String enrollmentId) async {
    if (ApiConfig.useMockData) {
      final found = await MockSpareData.getEducationEnrollmentById(enrollmentId);
      if (found == null) {
        throw NotFoundException('신청 내역을 찾을 수 없습니다.');
      }
      return found;
    }
    try {
      final response =
          await _dio.get('/api/educations/enrollments/$enrollmentId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return EducationEnrollment.fromJson(data as Map<String, dynamic>);
      }
      throw NotFoundException('신청 내역을 찾을 수 없습니다.');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<EducationEnrollment>> getMyEnrollments() async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getMyEducationEnrollments();
    }
    try {
      final response = await _dio.get('/api/educations/my-enrollments');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final list = data is List ? data : (data['enrollments'] as List? ?? []);
        return list
            .whereType<Map<String, dynamic>>()
            .map(EducationEnrollment.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Education _educationFromApiJson(Map<String, dynamic> json) {
    return Education(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      district: json['district']?.toString(),
      regionId: json['regionId']?.toString(),
      price: json['price'] is int
          ? json['price'] as int
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      energyCost: json['energyCost'] is int
          ? json['energyCost'] as int
          : int.tryParse(json['energyCost']?.toString() ?? '1') ?? 1,
      isUrgent: json['isUrgent'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? '') ??
          DateTime.now(),
      applicants: json['applicants'] is int
          ? json['applicants'] as int
          : 0,
      maxApplicants: json['maxApplicants'] is int
          ? json['maxApplicants'] as int
          : 20,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
