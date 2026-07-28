/// 스토어 판매자 신청 상태.
enum StoreSellerStatus {
  pending('심사중'),
  approved('승인됨'),
  rejected('반려됨');

  const StoreSellerStatus(this.label);
  final String label;
}

/// 스토어 판매자(셀러) — 스페어·샵 계정 누구나 신청 가능, 관리자 승인 후 활동.
class StoreSeller {
  const StoreSeller({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.status,
    required this.appliedAt,
    this.businessNumber,
    this.approvedAt,
    this.rejectReason,
    this.logoUrl,
  });

  final String id;
  final String shopName;
  final String ownerName;
  final StoreSellerStatus status;
  final DateTime appliedAt;
  final String? businessNumber;
  final DateTime? approvedAt;
  final String? rejectReason;
  final String? logoUrl;

  bool get isApproved => status == StoreSellerStatus.approved;
}
