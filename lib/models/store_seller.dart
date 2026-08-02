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
    this.introText,
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

  /// 스토어 프로필 페이지 상단에 노출되는 한 줄 소개글.
  final String? introText;

  bool get isApproved => status == StoreSellerStatus.approved;
}

/// 셀러별 집계 지표(상품수·평균 별점·팔로워수) — [StoreSellerService.getSellerSummaries]가 생성.
class StoreSellerSummary {
  const StoreSellerSummary({
    required this.seller,
    required this.productCount,
    required this.averageRating,
    this.followerCount = 0,
  });

  final StoreSeller seller;
  final int productCount;
  final double averageRating;

  /// 서버(현재는 mock) 기준 팔로워수 — 내가 방금 누른 팔로우는 포함하지 않는다.
  /// 화면에 표시할 값은 `StoreSellerFollowProvider.displayFollowerCount`로 계산.
  final int followerCount;
}
