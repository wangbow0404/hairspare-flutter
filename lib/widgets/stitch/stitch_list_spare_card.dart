import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';
import '../common/spare_profile_thumbnail.dart';

/// Stitch 세로 리스트용 스페어 카드 — [StitchListJobCard]와 동일 레이아웃.
class StitchListSpareCard extends StatelessWidget {
  const StitchListSpareCard({
    super.key,
    required this.spare,
    this.showPopularBadge = false,
    this.onTap,
    this.margin,
  });

  final SpareProfile spare;
  final bool showPopularBadge;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  String get _metaLine {
    final region = RegionHelper.getRegionName(spare.regionId).trim();
    final base = '경력 ${spare.experience}년 · 완료 ${spare.completedJobs}건';
    if (region.isNotEmpty && region != spare.regionId) {
      return '$region · $base';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Material(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: AppTheme.stitchSoftShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpareProfileThumbnail(
                    spare: spare,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPopularBadge) ...[
                          const _Badge(
                            label: '인기',
                            background: Color(0x1A9333EA),
                            foreground: AppTheme.stitchPrimary,
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                        ],
                        Text(
                          spare.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.stitchTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing1),
                        Text(
                          _metaLine,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.stitchTextSecondary,
                          ),
                          maxLines: 2,
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
                                  horizontal: AppTheme.spacing2,
                                  vertical: AppTheme.spacing1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurpleLight,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.stitchTextSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing2),
                        Row(
                          children: [
                            const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                              color: AppTheme.stitchPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '따봉 ${spare.thumbsUpCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.stitchPrimary,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            const Text(
                              '·',
                              style: TextStyle(
                                color: AppTheme.stitchTextSecondary,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              '★ ${spare.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.stitchTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
