import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_layout_metrics.dart';
import '../../theme/home_text_styles.dart';
import 'shop_home_spare_card.dart';

typedef ShopSpareTap = void Function(SpareProfile spare);

class _ShopHomeSectionHeader extends StatelessWidget {
  const _ShopHomeSectionHeader({
    required this.title,
    required this.onSeeMore,
    this.badge,
  });

  final String title;
  final VoidCallback onSeeMore;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        TextButton(
          onPressed: onSeeMore,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
          ),
          child: const Text('더보기'),
        ),
      ],
    );
  }
}

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
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopHomeSectionHeader(
            title: '인기 지원자',
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
          SizedBox(
            height: HomeLayoutMetrics.horizontalCarouselHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: spares.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacing4),
              itemBuilder: (context, index) {
                final spare = spares[index];
                return ShopHomeSpareFeatureCard(
                  spare: spare,
                  showHotBadge: true,
                  onTap: () => onSpareTap(spare),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopHomeSectionHeader(
            title: '신규 지원자',
            onSeeMore: onSeeMore,
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            height: HomeLayoutMetrics.horizontalCarouselHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: spares.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacing4),
              itemBuilder: (context, index) {
                final spare = spares[index];
                return ShopHomeSpareFeatureCard(
                  spare: spare,
                  heroGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x802563EB),
                      Color(0x807C3AED),
                      Color(0x8006B6D4),
                    ],
                  ),
                  onTap: () => onSpareTap(spare),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
            title: '일반 지원자',
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
