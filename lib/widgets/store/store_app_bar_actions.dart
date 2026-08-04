import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 계열 화면 상단바의 "찜한 상품" 액션 — 찜 개수 뱃지 포함.
/// 스토어 홈·스토어 프로필 등 여러 화면이 같은 아이콘/뱃지를 쓰도록 공용화.
class StoreWishlistAction extends StatelessWidget {
  const StoreWishlistAction({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreWishlistProvider>(
      builder: (context, wishlist, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.favorite_border,
                size: 24,
                color: HairSpareColors.textSecondary,
              ),
              onPressed: onPressed,
              tooltip: '찜한 상품',
            ),
            if (wishlist.count > 0)
              _CountBadge(
                count: wishlist.count,
                color: HairSpareColors.statusUrgent,
              ),
          ],
        );
      },
    );
  }
}

/// 스토어 계열 화면 상단바의 "장바구니" 액션 — 담긴 수량 뱃지 포함.
class StoreCartAction extends StatelessWidget {
  const StoreCartAction({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 24,
                color: HairSpareColors.textSecondary,
              ),
              onPressed: onPressed,
              tooltip: '장바구니',
            ),
            if (cart.totalCount > 0)
              _CountBadge(
                count: cart.totalCount,
                color: HairSpareColors.brandPrimary,
              ),
          ],
        );
      },
    );
  }
}

/// 아이콘 우측 상단에 겹쳐지는 개수 뱃지.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 6,
      top: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        constraints: const BoxConstraints(minWidth: 16),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
