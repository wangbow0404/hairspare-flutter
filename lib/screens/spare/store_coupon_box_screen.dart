import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/store_coupon.dart';
import '../../providers/store_coupon_provider.dart';
import '../../services/store_coupon_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 보유 쿠폰함 — 스토어 홈 바로가기 숏컷에서 진입.
class StoreCouponBoxScreen extends StatefulWidget {
  const StoreCouponBoxScreen({super.key});

  @override
  State<StoreCouponBoxScreen> createState() => _StoreCouponBoxScreenState();
}

class _StoreCouponBoxScreenState extends State<StoreCouponBoxScreen> {
  final StoreCouponService _couponService = sl<StoreCouponService>();
  List<StoreCoupon> _coupons = [];
  bool _isLoading = true;

  static final _priceFmt = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coupons = await _couponService.getCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = coupons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '쿠폰함',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
          ? const Center(child: Text('보유한 쿠폰이 없습니다'))
          : Consumer<StoreCouponProvider>(
              builder: (context, couponState, _) {
                return ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  itemCount: _coupons.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacing3),
                  itemBuilder: (context, index) {
                    final coupon = _coupons[index];
                    final claimed = couponState.isClaimed(coupon.id);
                    return _CouponTile(
                      coupon: coupon,
                      claimed: claimed,
                      onClaim: () => couponState.claim(coupon.id),
                      priceFmt: _priceFmt,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.claimed,
    required this.onClaim,
    required this.priceFmt,
  });

  final StoreCoupon coupon;
  final bool claimed;
  final VoidCallback onClaim;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: HairSpareColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${priceFmt.format(coupon.minPurchaseAmount)}원 이상 구매 시 · '
                  '${DateFormat('yyyy.MM.dd').format(coupon.expiresAt)}까지',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HairSpareColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: claimed ? null : onClaim,
            child: Text(claimed ? '받음' : '받기'),
          ),
        ],
      ),
    );
  }
}
