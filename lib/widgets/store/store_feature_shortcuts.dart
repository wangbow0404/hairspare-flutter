import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 홈 바로가기 숏컷 — 장바구니/찜/주문내역/전체스토어/쿠폰함/최근본상품.
class StoreFeatureShortcuts extends StatelessWidget {
  const StoreFeatureShortcuts({
    super.key,
    required this.cartCount,
    required this.wishlistCount,
    required this.onCart,
    required this.onWishlist,
    required this.onOrders,
    required this.onAllSellers,
    required this.onCouponBox,
    required this.onRecentlyViewed,
  });

  final int cartCount;
  final int wishlistCount;
  final VoidCallback onCart;
  final VoidCallback onWishlist;
  final VoidCallback onOrders;
  final VoidCallback onAllSellers;
  final VoidCallback onCouponBox;
  final VoidCallback onRecentlyViewed;

  @override
  Widget build(BuildContext context) {
    final items = <_ShortcutItem>[
      _ShortcutItem(Icons.shopping_cart_outlined, '장바구니', cartCount, onCart),
      _ShortcutItem(
        Icons.favorite_border,
        '찜한 상품',
        wishlistCount,
        onWishlist,
      ),
      _ShortcutItem(Icons.receipt_long_outlined, '주문내역', 0, onOrders),
      _ShortcutItem(
        Icons.storefront_outlined,
        '전체 스토어',
        0,
        onAllSellers,
      ),
      _ShortcutItem(
        Icons.confirmation_number_outlined,
        '쿠폰함',
        0,
        onCouponBox,
      ),
      _ShortcutItem(Icons.history, '최근 본 상품', 0, onRecentlyViewed),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
      child: Wrap(
        children: [
          for (final item in items)
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: _ShortcutTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem(this.icon, this.label, this.badge, this.onTap);

  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.item});

  final _ShortcutItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: HairSpareColors.brandPrimarySoft,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
                if (item.badge > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: HairSpareColors.statusUrgent,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        '${item.badge}',
                        textAlign: TextAlign.center,
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
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: HairSpareColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
