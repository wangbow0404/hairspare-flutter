import '../models/store_coupon.dart';

/// 스토어 쿠폰 서비스 — 아직 실 백엔드 연동 전이라 mock 데이터만 제공.
class StoreCouponService {
  static final List<StoreCoupon> _coupons = [
    StoreCoupon(
      id: 'coupon-welcome-5000',
      title: '스토어 첫 구매 5,000원 할인',
      discountAmount: 5000,
      minPurchaseAmount: 30000,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    ),
    StoreCoupon(
      id: 'coupon-weekly-3000',
      title: '이번 주 3,000원 할인',
      discountAmount: 3000,
      minPurchaseAmount: 20000,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
    StoreCoupon(
      id: 'coupon-vip-10000',
      title: '10만원 이상 구매 시 10,000원 할인',
      discountAmount: 10000,
      minPurchaseAmount: 100000,
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    ),
  ];

  Future<List<StoreCoupon>> getCoupons() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<StoreCoupon>.from(_coupons);
  }
}
