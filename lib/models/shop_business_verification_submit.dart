/// 샵 사업자 인증 제출 본문. 실제 API는 멀티파트로 전송하고, 목업은 경로만 검증합니다.
class ShopBusinessVerificationSubmit {
  const ShopBusinessVerificationSubmit({
    required this.businessNumber,
    required this.businessName,
    required this.representativeName,
    required this.businessType,
    required this.businessCategory,
    required this.address,
    required this.businessRegistrationLocalPath,
    this.idCardLocalPath,
    this.ocrRequestId,
  });

  final String businessNumber;
  final String businessName;
  final String representativeName;
  final String businessType;
  final String businessCategory;
  final String address;
  final String businessRegistrationLocalPath;
  final String? idCardLocalPath;
  /// OCR 요청 correlation ID (서버 Phase 2).
  final String? ocrRequestId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'businessNumber': businessNumber,
        'businessName': businessName,
        'representativeName': representativeName,
        'businessType': businessType,
        'businessCategory': businessCategory,
        'address': address,
        'hasBusinessRegistrationImage': businessRegistrationLocalPath.isNotEmpty,
        'hasIdCardImage': idCardLocalPath != null && idCardLocalPath!.isNotEmpty,
        if (ocrRequestId != null) 'ocrRequestId': ocrRequestId,
      };
}
