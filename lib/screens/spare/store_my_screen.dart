import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_order.dart';
import '../../providers/cart_provider.dart';
import '../../services/store_account_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 스토어 마이 — 주문 내역·배송 조회·배송지 관리.
class StoreMyScreen extends StatefulWidget {
  const StoreMyScreen({super.key});

  @override
  State<StoreMyScreen> createState() => _StoreMyScreenState();
}

class _StoreMyScreenState extends State<StoreMyScreen> {
  final StoreAccountService _accountService = sl<StoreAccountService>();
  List<StoreOrder> _orders = [];
  List<StoreShippingAddress> _addresses = [];
  bool _loading = true;

  static final _priceFmt = NumberFormat('#,###');
  static final _dateFmt = DateFormat('M.d (E)', 'ko_KR');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _accountService.getOrders(),
      _accountService.getAddresses(),
    ]);
    if (!mounted) return;
    setState(() {
      _orders = results[0] as List<StoreOrder>;
      _addresses = results[1] as List<StoreShippingAddress>;
      _loading = false;
    });
  }

  void _openCart() => context.push(AppRoutes.spareHomeStoreCart);

  void _showOrderDetail(StoreOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderDetailSheet(order: order, priceFmt: _priceFmt),
    );
  }

  Future<void> _setDefaultAddress(String id) async {
    await _accountService.setDefaultAddress(id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('기본 배송지로 설정했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '스토어 마이',
        showToolbarActions: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing4,
                  AppTheme.spacing3,
                  AppTheme.spacing4,
                  AppTheme.spacing6,
                ),
                children: [
                  _QuickMenuRow(
                    cartCount: context.watch<CartProvider>().totalCount,
                    onCart: _openCart,
                    onStoreHome: () => context.go(AppRoutes.spareHomeStore),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _SellerApplyBanner(
                    onTap: () =>
                        context.push(AppRoutes.spareHomeStoreSellerApply),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  const _SectionTitle(title: '주문·배송 내역'),
                  const SizedBox(height: AppTheme.spacing2),
                  if (_orders.isEmpty)
                    const _EmptyCard(message: '주문 내역이 없습니다.')
                  else
                    ..._orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacing3,
                        ),
                        child: _OrderCard(
                          order: order,
                          priceFmt: _priceFmt,
                          dateFmt: _dateFmt,
                          onTap: () => _showOrderDetail(order),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.spacing2),
                  const _SectionTitle(title: '배송지 관리'),
                  const SizedBox(height: AppTheme.spacing2),
                  ..._addresses.map(
                    (addr) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                      child: _AddressCard(
                        address: addr,
                        onSetDefault: addr.isDefault
                            ? null
                            : () => _setDefaultAddress(addr.id),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('배송지 추가는 준비 중입니다.')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('배송지 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HairSpareColors.textPrimary,
                      side: const BorderSide(
                        color: HairSpareColors.borderStrong,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: HairSpareColors.textPrimary,
      ),
    );
  }
}

class _QuickMenuRow extends StatelessWidget {
  const _QuickMenuRow({
    required this.cartCount,
    required this.onCart,
    required this.onStoreHome,
  });

  final int cartCount;
  final VoidCallback onCart;
  final VoidCallback onStoreHome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickTile(
            icon: Icons.shopping_cart_outlined,
            label: '장바구니',
            badge: cartCount,
            onTap: onCart,
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _QuickTile(
            icon: Icons.storefront_outlined,
            label: '스토어 홈',
            onTap: onStoreHome,
          ),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing4,
            horizontal: AppTheme.spacing3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 22, color: HairSpareColors.textStrong),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: const BoxDecoration(
                          color: HairSpareColors.brandPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HairSpareColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerApplyBanner extends StatelessWidget {
  const _SellerApplyBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.brandPrimarySoft,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: const Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 22,
                color: HairSpareColors.brandPrimary,
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '스토어 판매자 신청하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HairSpareColors.brandPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '내 도구·용품을 스토어에 등록해 판매해보세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: HairSpareColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: HairSpareColors.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.priceFmt,
    required this.dateFmt,
    required this.onTap,
  });

  final StoreOrder order;
  final NumberFormat priceFmt;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  order.productThumbnailUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: HairSpareColors.surfaceMuted,
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusChip(status: order.status),
                        const Spacer(),
                        Text(
                          dateFmt.format(order.orderedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: HairSpareColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HairSpareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${priceFmt.format(order.totalPrice)}원 · ${order.quantity}개',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HairSpareColors.textStrong,
                      ),
                    ),
                    if (order.canTrack) ...[
                      const SizedBox(height: 6),
                      Text(
                        '운송장 ${order.trackingNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: HairSpareColors.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: HairSpareColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StoreOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StoreOrderStatus.shipping => HairSpareColors.brandPrimary,
      StoreOrderStatus.delivered => HairSpareColors.statusSuccess,
      StoreOrderStatus.cancelled => HairSpareColors.textSecondary,
      _ => HairSpareColors.statusMatching,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, this.onSetDefault});

  final StoreShippingAddress address;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: address.isDefault
              ? HairSpareColors.brandPrimary.withValues(alpha: 0.35)
              : HairSpareColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                address.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HairSpareColors.brandPrimarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '기본',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: HairSpareColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${address.recipientName} · ${address.phone}',
            style: const TextStyle(
              fontSize: 13,
              color: HairSpareColors.textStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: const TextStyle(
              fontSize: 13,
              color: HairSpareColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (onSetDefault != null) ...[
            const SizedBox(height: AppTheme.spacing3),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSetDefault,
                child: const Text('기본 배송지로 설정'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: HairSpareColors.textSecondary),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order, required this.priceFmt});

  final StoreOrder order;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: HairSpareColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '주문 상세',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text('주문번호 ${order.id}'),
                const SizedBox(height: AppTheme.spacing2),
                Text(order.productName),
                Text(
                  '${priceFmt.format(order.totalPrice)}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                const Text(
                  '배송 정보',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('받는 분: ${order.recipientName}'),
                Text('주소: ${order.addressSummary}'),
                if (order.canTrack) ...[
                  const SizedBox(height: AppTheme.spacing3),
                  Text('택배사: ${order.carrierName}'),
                  Text('운송장: ${order.trackingNumber}'),
                ],
                const SizedBox(height: AppTheme.spacing4),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: HairSpareColors.brandPrimary,
                  ),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
