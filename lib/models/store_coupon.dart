/// 스토어 쿠폰 — 정액 할인, 최소 구매금액 조건.
class StoreCoupon {
  const StoreCoupon({
    required this.id,
    required this.title,
    required this.discountAmount,
    required this.minPurchaseAmount,
    required this.expiresAt,
  });

  final String id;
  final String title;
  final int discountAmount;
  final int minPurchaseAmount;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool isEligible(int purchaseAmount) =>
      !isExpired && purchaseAmount >= minPurchaseAmount;
}
