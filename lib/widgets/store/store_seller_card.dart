import 'package:flutter/material.dart';

import '../../models/store_seller.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 홈 "인기 스토어" 섹션 카드 — 아바타·이름·상품수·별점·팔로우 버튼.
class StoreSellerCard extends StatelessWidget {
  const StoreSellerCard({
    super.key,
    required this.summary,
    required this.isFollowing,
    required this.followerCount,
    required this.onTap,
    required this.onFollowToggle,
  });

  final StoreSellerSummary summary;
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing3,
            horizontal: AppTheme.spacing2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: HairSpareColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: HairSpareColors.brandPrimarySoft,
                child: Text(
                  summary.seller.shopName.substring(0, 1),
                  style: const TextStyle(
                    color: HairSpareColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                summary.seller.shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '상품 ${summary.productCount} · ★${summary.averageRating.toStringAsFixed(1)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: HairSpareColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: OutlinedButton(
                  onPressed: onFollowToggle,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                      color: isFollowing
                          ? HairSpareColors.border
                          : HairSpareColors.brandPrimary,
                    ),
                    foregroundColor: isFollowing
                        ? HairSpareColors.textSecondary
                        : HairSpareColors.brandPrimary,
                  ),
                  child: Text(
                    isFollowing ? '팔로잉' : '+ 팔로우',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
