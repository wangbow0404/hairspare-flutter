import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_layout_metrics.dart';
import '../../theme/home_text_styles.dart';

/// 샵 홈 가로 스크롤용 — 스페어 홈 [PopularJobsSection] 카드와 동일한 세로 레이아웃.
class ShopHomeSpareFeatureCard extends StatelessWidget {
  const ShopHomeSpareFeatureCard({
    super.key,
    required this.spare,
    this.onTap,
    this.showHotBadge = false,
    this.heroGradient,
  });

  final SpareProfile spare;
  final VoidCallback? onTap;
  final bool showHotBadge;
  final Gradient? heroGradient;

  static const double cardWidth = HomeLayoutMetrics.horizontalCardWidth;

  static const double _cardHeight =
      HomeLayoutMetrics.horizontalCarouselHeight - 8;

  @override
  Widget build(BuildContext context) {
    final gradient = heroGradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x663B82F6),
            Color(0x669333EA),
            Color(0x66EC4899),
          ],
        );

    final metaLine =
        '경력 ${spare.experience}년 · 완료 ${spare.completedJobs}건 · '
        '따봉 ${spare.thumbsUpCount} · ★ ${spare.rating.toStringAsFixed(1)}';

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
                  Stack(
                    children: [
                      Container(
                        height: HomeLayoutMetrics.horizontalCardHeroHeight,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppTheme.radiusLg),
                            topRight: Radius.circular(AppTheme.radiusLg),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: _AvatarCircle(spare: spare, size: 64),
                        ),
                      ),
                      if (showHotBadge)
                        const Positioned(
                          top: AppTheme.spacing2,
                          left: AppTheme.spacing2,
                          child: _HotBadge(),
                        ),
                      if (spare.isLicenseVerified)
                        const Positioned(
                          top: AppTheme.spacing2,
                          right: AppTheme.spacing2,
                          child: _LicenseChip(),
                        ),
                    ],
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

/// 일반 지원자 리스트 — 전체 너비, 콘텐츠 높이에 맞춤.
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
              _AvatarCircle(spare: spare, size: 52),
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
                        if (spare.isLicenseVerified) ...[
                          const SizedBox(width: AppTheme.spacing2),
                          const _LicenseChip(compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '경력 ${spare.experience}년 · 완료 ${spare.completedJobs}건 · 따봉 ${spare.thumbsUpCount}',
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

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.spare, required this.size});

  final SpareProfile spare;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppTheme.shadowMd,
      ),
      child: spare.profileImage != null
          ? ClipOval(
              child: Image.network(
                spare.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initial(),
              ),
            )
          : _initial(),
    );
  }

  Widget _initial() {
    return Center(
      child: Text(
        spare.name.isNotEmpty ? spare.name[0] : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
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

class _LicenseChip extends StatelessWidget {
  const _LicenseChip({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : AppTheme.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        '면허인증',
        style: TextStyle(
          color: AppTheme.purple700,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
