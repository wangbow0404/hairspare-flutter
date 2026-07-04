import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_layout_metrics.dart';
import '../../theme/home_text_styles.dart';
import 'shop_home_spare_photo.dart';

/// 샵 홈 가로 스크롤 — 상단 커버 사진 + 하단 정보.
class ShopHomeSpareFeatureCard extends StatelessWidget {
  const ShopHomeSpareFeatureCard({
    super.key,
    required this.spare,
    this.onTap,
    this.showHotBadge = false,
  });

  final SpareProfile spare;
  final VoidCallback? onTap;
  final bool showHotBadge;

  static const double cardWidth = HomeLayoutMetrics.horizontalCardWidth;

  static const double _cardHeight =
      HomeLayoutMetrics.horizontalCarouselHeight - 8;

  static const double _photoHeight = HomeLayoutMetrics.horizontalCardHeroHeight;

  @override
  Widget build(BuildContext context) {
    final metaLine =
        '경력 ${spare.experience}년 · 완료 ${spare.completedJobs}건 · '
        '따봉 ${spare.thumbsUpCount}';

    return SizedBox(
      width: cardWidth,
      height: _cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Material(
          color: AppTheme.backgroundWhite,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: _photoHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ShopHomeSparePhoto(
                          spare: spare,
                          width: cardWidth,
                          height: _photoHeight,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppTheme.radiusLg),
                            topRight: Radius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0),
                                  Colors.black.withValues(alpha: 0.28),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (showHotBadge)
                          const Positioned(
                            top: AppTheme.spacing2,
                            left: AppTheme.spacing2,
                            child: _HotBadge(),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spare.name,
                            style: HomeTextStyles.homeCardTitle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacing1),
                          Text(
                            metaLine,
                            style: HomeTextStyles.homeCardMeta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (spare.specialties.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacing1),
                            Row(
                              children: [
                                for (var i = 0;
                                    i < spare.specialties.take(2).length;
                                    i++) ...[
                                  if (i > 0)
                                    const SizedBox(width: AppTheme.spacing1),
                                  Flexible(
                                    child: _SpecialtyChip(
                                      label: spare.specialties[i],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.purple100,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: HomeTextStyles.homeCardTag.copyWith(
          color: AppTheme.purple700,
          fontSize: 11,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 신규 지원자 — 왼쪽 사진 썸네일 + 정보 Row.
class ShopHomeSpareListTile extends StatelessWidget {
  const ShopHomeSpareListTile({
    super.key,
    required this.spare,
    this.onTap,
    this.showPopularBadge = false,
  });

  final SpareProfile spare;
  final VoidCallback? onTap;
  final bool showPopularBadge;

  static const double _photoSize = 72;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.borderGray),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing3),
          child: Row(
            children: [
              ShopHomeSparePhoto(
                spare: spare,
                width: _photoSize,
                height: _photoSize,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spare.name,
                            style: HomeTextStyles.homeCardTitle.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showPopularBadge) ...[
                          const SizedBox(width: AppTheme.spacing2),
                          const _HotBadge(compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '경력 ${spare.experience}년 · 완료 ${spare.completedJobs}건 · '
                      '따봉 ${spare.thumbsUpCount}',
                      style: HomeTextStyles.homeCardMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (spare.specialties.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacing2),
                      Wrap(
                        spacing: AppTheme.spacing1,
                        runSpacing: AppTheme.spacing1,
                        children: spare.specialties.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.purple100,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              tag,
                              style: HomeTextStyles.homeCardTag.copyWith(
                                color: AppTheme.purple700,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotBadge extends StatelessWidget {
  const _HotBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : AppTheme.spacing2,
        vertical: compact ? 2 : AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'HOT',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
