import 'dart:io';

import 'package:dio/dio.dart';
import '../models/business_registration_ocr_result.dart';
import '../models/business_registration_validation.dart';
import '../models/shop_business_verification_snapshot.dart';
import '../models/shop_business_verification_submit.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';
import '../mocks/mock_shop_data.dart';
import '../core/di/service_locator.dart';

class VerificationService {
  final Dio _dio = sl<Dio>();

  /// 샵 사업자 인증 스냅샷 조회
  Future<ShopBusinessVerificationSnapshot> getShopBusinessVerification() async {
    if (ApiConfig.useMockData) {
      return const ShopBusinessVerificationSnapshot(status: 'not_started');
    }
    try {
      final response = await _dio.get('/api/shop/business-verification');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final map = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};
        return ShopBusinessVerificationSnapshot(
          status: (map['status']?.toString() ?? 'not_started'),
          rejectionReason: map['rejectionReason']?.toString(),
          verifiedAt: map['verifiedAt']?.toString(),
          businessNumber: map['businessNumber']?.toString(),
          businessName: map['businessName']?.toString(),
          representativeName: map['representativeName']?.toString(),
          businessType: map['businessType']?.toString(),
          businessCategory: map['businessCategory']?.toString(),
          address: map['address']?.toString(),
        );
      }
      throw ServerException(
        '사업자 인증 정보 조회 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 사업자등록증 OCR — Phase 2: POST /api/shop/business-verification/ocr (multipart).
  Future<BusinessRegistrationOcrResult> scanBusinessRegistration(
    File image,
  ) async {
    if (ApiConfig.useMockData) {
      return MockShopData.mockScanBusinessRegistration();
    }
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'business_registration.jpg',
        ),
      });
      final response = await _dio.post(
        '/api/shop/business-verification/ocr',
        data: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return BusinessRegistrationOcrResult.fromJson(
          data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        '사업자등록증 인식 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 국세청 진위·상태 검증 — Phase 2: POST /api/shop/business-verification/validate.
  Future<BusinessRegistrationValidation> validateBusinessRegistration({
    required String businessNumber,
    required String businessName,
    required String representativeName,
    required String businessType,
    required String businessCategory,
    required String address,
    String? ocrRequestId,
  }) async {
    if (ApiConfig.useMockData) {
      return MockShopData.mockValidateBusinessRegistration(
        businessNumber: businessNumber,
        ocrRequestId: ocrRequestId,
      );
    }
    try {
      final response = await _dio.post(
        '/api/shop/business-verification/validate',
        data: {
          'businessNumber': businessNumber,
          'businessName': businessName,
          'representativeName': representativeName,
          'businessType': businessType,
          'businessCategory': businessCategory,
          'address': address,
          if (ocrRequestId != null) 'ocrRequestId': ocrRequestId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return BusinessRegistrationValidation.fromJson(
          data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        '사업자 검증 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 이미지 파일을 R2에 업로드하고 URL을 받는다 (사업자등록증·신분증 공용).
  Future<String> _uploadVerificationImage(File file, String folder) async {
    final response = await _dio.post(
      '/api/auth/upload-image',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: '$folder-${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      }),
      queryParameters: {'folder': folder},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'] ?? response.data;
      final url = data is Map ? data['url']?.toString() : null;
      if (url == null || url.isEmpty) {
        throw ServerException('이미지 업로드 응답이 올바르지 않습니다');
      }
      return url;
    }
    throw ServerException(
      '이미지 업로드 실패: ${response.statusMessage}',
      statusCode: response.statusCode,
    );
  }

  /// 샵 사업자 인증 신청(최초) / 재신청(수정) 제출.
  /// 등록증·신분증 이미지를 먼저 업로드해 URL을 받은 뒤 JSON으로 전송한다.
  Future<ShopBusinessVerificationSnapshot> submitShopBusinessVerification(
    ShopBusinessVerificationSubmit submit,
  ) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const ShopBusinessVerificationSnapshot(status: 'pending');
    }
    try {
      final businessLicenseUrl = await _uploadVerificationImage(
        File(submit.businessRegistrationLocalPath),
        'shop-licenses',
      );
      String? idCardUrl;
      if (submit.idCardLocalPath != null && submit.idCardLocalPath!.isNotEmpty) {
        idCardUrl = await _uploadVerificationImage(
          File(submit.idCardLocalPath!),
          'shop-id-cards',
        );
      }

      final response = await _dio.post(
        '/api/shop/business-verification',
        data: {
          'businessNumber': submit.businessNumber,
          'businessName': submit.businessName,
          'representativeName': submit.representativeName,
          'businessType': submit.businessType,
          'businessCategory': submit.businessCategory,
          'address': submit.address,
          'businessLicenseUrl': businessLicenseUrl,
          if (idCardUrl != null) 'idCardUrl': idCardUrl,
        },
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          '사업자 인증 신청 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
      final data = response.data['data'] ?? response.data;
      final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
      return ShopBusinessVerificationSnapshot(
        status: map['status']?.toString() ?? 'pending',
        rejectionReason: map['rejectionReason']?.toString(),
        verifiedAt: map['verifiedAt']?.toString(),
        businessNumber: map['businessNumber']?.toString(),
        businessName: map['businessName']?.toString(),
        representativeName: map['representativeName']?.toString(),
        businessType: map['businessType']?.toString(),
        businessCategory: map['businessCategory']?.toString(),
        address: map['address']?.toString(),
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 샵 대리인 인증 신청 제출
  Future<void> submitShopProxyVerification({
    required String name,
    required String relation,
    required String phone,
  }) async {
    if (ApiConfig.useMockData) return;
    try {
      final response = await _dio.post(
        '/api/shop/proxy-verification',
        data: {
          'name': name,
          'relation': relation,
          'phone': phone,
        },
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw ServerException(
          '대리인 인증 신청 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 본인인증 상태 확인 (사용자 정보에서 확인)
  Future<Map<String, dynamic>> getVerificationStatus() async {
    if (ApiConfig.useMockData) return await MockSpareData.getVerificationStatus();
    try {
      // /api/verification/status API가 없으므로 /api/auth/me로 사용자 정보 조회
      final response = await _dio.get('/api/auth/me');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        // 사용자 정보에서 verification 정보 추출 (백엔드에서 verification 관계 포함 시)
        return {
          'identityVerified': data['verification']?['identityVerified'] ?? false,
          'identityName': data['verification']?['identityName'],
          'identityPhone': data['verification']?['identityPhone'],
          'identityBirthDate': data['verification']?['identityBirthDate'],
          'identityGender': data['verification']?['identityGender'],
        };
      } else {
        throw ServerException(
          '인증 상태 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// PASS 본인인증 요청
  Future<Map<String, dynamic>> requestPassVerification() async {
    try {
      final response = await _dio.post('/api/verification/pass/request');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'PASS 본인인증 요청 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 본인인증 요청 (PASS 인증 URL 반환)
  Future<String> requestIdentityVerification() async {
    try {
      final result = await requestPassVerification();
      return result['url'] as String? ?? '';
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// PASS 본인인증 상태 확인
  Future<Map<String, dynamic>> getPassVerificationStatus() async {
    if (ApiConfig.useMockData) return await MockSpareData.getPassVerificationStatus();
    try {
      final response = await _dio.get('/api/verification/pass/status');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'PASS 본인인증 상태 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증번호 발송
  Future<String> sendVerificationCode(String phone) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return '123456';
    }
    try {
      final response = await _dio.post(
        '/api/auth/send-verification-code',
        data: {'phone': phone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return data['code'] as String? ?? '';
      } else {
        throw ServerException(
          '인증번호 발송 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 인증번호 확인
  Future<bool> verifyCode(String phone, String code) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return code.trim().length == 6;
    }
    try {
      final response = await _dio.post(
        '/api/auth/verify-code',
        data: {'phone': phone, 'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['verified'] as bool? ?? false;
      } else {
        throw ServerException(
          '인증번호 확인 실패: ${response.statusMessage}',
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
