import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/region_helper.dart';
import '../common/job_thumbnail.dart';

/// a안 홈 가로 스크롤 공고 카드.
class HsJobCardHorizontal extends StatelessWidget {
  const HsJobCardHorizontal({
    super.key,
    required this.job,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
    this.width = 240,
    this.height,
    this.showThumbnail = false,
    this.badgeLabel = '급구',
    this.badgeColor = HairSpareColors.statusUrgent,
  });

  final Job job;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final double width;
  final double? height;
  final bool showThumbnail;
  final String badgeLabel;
  final Color badgeColor;

  String _formatPay(int amount) {
    return '${NumberFormat('#,###').format(amount)}원';
  }

  String _formatScheduleLine(Job job) {
    final parsed = DateTime.tryParse(job.date);
    final dayLabel = parsed == null ? job.date : _relativeDayLabel(parsed);
    final end = job.endTime?.trim();
    final time = end == null || end.isEmpty ? job.time : '${job.time} - $end';
    final region = RegionHelper.getRegionName(job.regionId).trim();
    if (region.isNotEmpty && region != job.regionId) {
      return '$region • $dayLabel, $time';
    }
    return '$dayLabel, $time';
  }

  String _relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    return '${date.month}.${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: HairSpareColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (showThumbnail) _buildThumbnailHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(
                      showThumbnail ? AppTheme.spacing4 : AppTheme.spacing3,
                    ),
                    child: showThumbnail
                        ? _buildBody()
                        : _buildBodyWithStack(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailHeader() {
    return Stack(
      children: [
        JobThumbnail(
          job: job,
          width: width,
          height: width * 9 / 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXl),
            topRight: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        Positioned(
          top: AppTheme.spacing2,
          left: AppTheme.spacing2,
          child: _Badge(label: badgeLabel, color: badgeColor, solid: true),
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: AppTheme.spacing1,
            right: AppTheme.spacing1,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoriteToggle,
              onImage: true,
            ),
          ),
      ],
    );
  }

  Widget _buildBodyWithStack() {
    return Stack(
      children: [
        if (onFavoriteToggle != null)
          Positioned(
            top: 0,
            right: 0,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoriteToggle,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Badge(label: badgeLabel, color: badgeColor),
            const SizedBox(height: AppTheme.spacing2),
            ..._buildInfo(compact: true),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildInfo(compact: false),
    );
  }

  List<Widget> _buildInfo({required bool compact}) {
    final gapBeforeDivider =
        compact ? AppTheme.spacing2 : AppTheme.spacing4;
    final gapAfterDivider =
        compact ? AppTheme.spacing2 : AppTheme.spacing3;

    return [
      Text(
        job.shopName,
        style: TextStyle(
          fontSize: compact ? 15 : 16,
          fontWeight: FontWeight.w700,
          color: HairSpareColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: compact ? 2 : AppTheme.spacing1),
      Text(
        _formatScheduleLine(job),
        style: const TextStyle(
          fontSize: 13,
          color: HairSpareColors.textSecondary,
        ),
        maxLines: compact ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: gapBeforeDivider),
      const Divider(height: 1, color: HairSpareColors.border),
      SizedBox(height: gapAfterDivider),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '일급',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: HairSpareColors.textSecondary,
            ),
          ),
          Text(
            _formatPay(job.amount),
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: HairSpareColors.brandPrimary,
            ),
          ),
        ],
      ),
    ];
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.solid = false,
  });

  final String label;
  final Color color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: solid ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    this.onImage = false,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final icon = IconMapper.icon(
          'heart',
          size: 20,
          color: isFavorite
              ? HairSpareColors.statusUrgent
              : (onImage ? Colors.white : HairSpareColors.textSecondary),
        ) ??
        Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isFavorite
              ? HairSpareColors.statusUrgent
              : (onImage ? Colors.white : HairSpareColors.textSecondary),
        );

    final button = IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
      icon: icon,
    );

    if (!onImage) return button;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: button,
    );
  }
}
