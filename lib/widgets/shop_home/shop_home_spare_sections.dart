import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../theme/home_text_styles.dart';
import 'shop_home_spare_card.dart';
import 'shop_home_spare_portrait_card.dart';

typedef ShopSpareTap = void Function(SpareProfile spare);

class _ShopHomeSectionHeader extends StatelessWidget {
  const _ShopHomeSectionHeader({
    required this.title,
    required this.onSeeMore,
    this.subtitle,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onSeeMore;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: HomeTextStyles.sectionTitle),
                      if (badge != null) ...[
                        const SizedBox(width: AppTheme.spacing2),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeMore,
              style: TextButton.styleFrom(
                foregroundColor: HairSpareColors.brandPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                ),
              ),
              child: const Text('더보기'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PortraitCarousel extends StatelessWidget {
  const _PortraitCarousel({
    required this.spares,
    required this.onSpareTap,
  });

  final List<SpareProfile> spares;
  final ShopSpareTap onSpareTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: spares.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacing3),
        itemBuilder: (context, index) {
          final spare = spares[index];
          return ShopHomeSparePortraitCard(
            spare: spare,
            onTap: () => onSpareTap(spare),
          );
        },
      ),
    );
  }
}

/// 인기 스페어 — 프로필 카드 가로 캐러셀.
class ShopHomePopularSparesSection extends StatelessWidget {
  const ShopHomePopularSparesSection({
    super.key,
    required this.spares,
    required this.onSeeMore,
    required this.onSpareTap,
  });

  final List<SpareProfile> spares;
  final VoidCallback onSeeMore;
  final ShopSpareTap onSpareTap;

  @override
  Widget build(BuildContext context) {
    if (spares.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopHomeSectionHeader(
            title: '인기 스페어',
            onSeeMore: onSeeMore,
            badge: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Text('HOT', style: HomeTextStyles.sectionBadge),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _PortraitCarousel(spares: spares, onSpareTap: onSpareTap),
        ],
      ),
    );
  }
}

/// 신규 스페어 — 최근 가입·활동 프로필.
class ShopHomeNewSparesSection extends StatelessWidget {
  const ShopHomeNewSparesSection({
    super.key,
    required this.spares,
    required this.onSeeMore,
    required this.onSpareTap,
  });

  final List<SpareProfile> spares;
  final VoidCallback onSeeMore;
  final ShopSpareTap onSpareTap;

  @override
  Widget build(BuildContext context) {
    if (spares.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppTheme.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopHomeSectionHeader(
            title: '신규 스페어',
            subtitle: '최근 등록된 스페어·디자이너',
            onSeeMore: onSeeMore,
          ),
          const SizedBox(height: AppTheme.spacing4),
          _PortraitCarousel(spares: spares, onSpareTap: onSpareTap),
        ],
      ),
    );
  }
}

/// 내 지역 스페어 — 샵 주변 지역 필터.
class ShopHomeNearbySparesSection extends StatelessWidget {
  const ShopHomeNearbySparesSection({
    super.key,
    required this.spares,
    required this.regionLabel,
    required this.onSeeMore,
    required this.onSpareTap,
  });

  final List<SpareProfile> spares;
  final String regionLabel;
  final VoidCallback onSeeMore;
  final ShopSpareTap onSpareTap;

  @override
  Widget build(BuildContext context) {
    if (spares.isEmpty) return const SizedBox.shrink();

    return ColoredBox(
      color: AppTheme.backgroundGray,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing6,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShopHomeSectionHeader(
              title: '내 지역 스페어',
              subtitle: '$regionLabel 주변',
              onSeeMore: onSeeMore,
              badge: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: HairSpareColors.brandPrimary),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: HairSpareColors.brandPrimary,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '주변',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: HairSpareColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            _PortraitCarousel(spares: spares, onSpareTap: onSpareTap),
          ],
        ),
      ),
    );
  }
}

/// 일반 스페어 — 전국 기타 지역 리스트.
class ShopHomeRegularSparesSection extends StatelessWidget {
  const ShopHomeRegularSparesSection({
    super.key,
    required this.spares,
    required this.onSeeMore,
    required this.onSpareTap,
  });

  final List<SpareProfile> spares;
  final VoidCallback onSeeMore;
  final ShopSpareTap onSpareTap;

  @override
  Widget build(BuildContext context) {
    if (spares.isEmpty) return const SizedBox.shrink();

    final preview = spares.take(6).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopHomeSectionHeader(
            title: '일반 스페어',
            subtitle: '다른 지역의 스페어·디자이너',
            onSeeMore: onSeeMore,
          ),
          const SizedBox(height: AppTheme.spacing3),
          ...preview.map(
            (spare) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
              child: ShopHomeSpareListTile(
                spare: spare,
                onTap: () => onSpareTap(spare),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
