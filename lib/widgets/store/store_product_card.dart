import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/store_product.dart';
import '../../theme/app_theme.dart';

/// 스토어 상품 카드 — 2열 그리드용, 오늘의집 스타일(썸네일+브랜드+이름+가격).
class StoreProductCard extends StatelessWidget {
  const StoreProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isWishlisted = false,
    this.onWishlistToggle,
  });

  final StoreProduct product;
  final VoidCallback onTap;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;

  static final _priceFmt = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.backgroundGray,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                    if (product.isSoldOut)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const Text(
                          '품절',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (product.isBestSeller && !product.isSoldOut)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _Badge(label: 'BEST', color: AppTheme.orange500),
                      ),
                    if (onWishlistToggle != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _WishlistButton(
                          isWishlisted: isWishlisted,
                          onTap: onWishlistToggle!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.brand,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            if (product.reviewCount > 0) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.star, size: 13, color: AppTheme.yellow500),
                  const SizedBox(width: 3),
                  Text(
                    '${product.averageRating.toStringAsFixed(1)} (${product.reviewCount})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (product.hasDiscount) ...[
                  Text(
                    '${product.discountPercent}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.orange600,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${_priceFmt.format(product.price)}원',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (product.hasDiscount)
              Text(
                '${_priceFmt.format(product.originalPrice)}원',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.isWishlisted, required this.onTap});

  final bool isWishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isWishlisted ? AppTheme.urgentRed : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
