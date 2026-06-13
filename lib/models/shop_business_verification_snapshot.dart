/// 샵 사업자 인증 조회 결과 (서버·목업 공통). [status]는 UI 분기의 단일 소스입니다.
///
/// 값: `not_started` | `pending` | `approved` | `rejected`
class ShopBusinessVerificationSnapshot {
  const ShopBusinessVerificationSnapshot({
    required this.status,
    this.rejectionReason,
    this.verifiedAt,
    this.businessNumber,
    this.businessName,
    this.representativeName,
    this.businessType,
    this.businessCategory,
    this.address,
  });

  final String status;
  final String? rejectionReason;
  final String? verifiedAt;
  final String? businessNumber;
  final String? businessName;
  final String? representativeName;
  final String? businessType;
  final String? businessCategory;
  final String? address;
}
