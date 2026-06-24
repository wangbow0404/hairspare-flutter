import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';
import '../common/app_network_image.dart';

/// 공간관리 — 컴팩트 리스트 카드 (80×80 썸네일 + 메타 + 노출 토글).
class StitchListSpaceCard extends StatelessWidget {
  const StitchListSpaceCard({
    super.key,
    required this.space,
    required this.pendingBookingCount,
    required this.isVisibilityUpdating,
    required this.onToggleVisibility,
    required this.onBookings,
    required this.onEdit,
    required this.onHide,
    required this.onUnhide,
    required this.onDelete,
  });

  final SpaceRental space;
  final int pendingBookingCount;
  final bool isVisibilityUpdating;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onBookings;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback onUnhide;
  final VoidCallback onDelete;

  bool get _isVisible => !space.isHidden;

  String? get _imageUrl {
    final urls = space.imageUrls;
    if (urls == null || urls.isEmpty) return null;
    final first = urls.first.trim();
    return first.isEmpty ? null : first;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isVisible ? 1 : 0.75,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray),
        ),
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SpaceThumbnail(
                  imageUrl: _imageUrl,
                  dimmed: !_isVisible,
                ),
                const SizedBox(width: AppTheme.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              space.shopName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.stitchTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _SpaceCardMenu(
                            isHidden: space.isHidden,
                            onEdit: onEdit,
                            onHide: onHide,
                            onUnhide: onUnhide,
                            onDelete: onDelete,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Wrap(
                        spacing: AppTheme.spacing2,
                        runSpacing: AppTheme.spacing1,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _TierBadge(isPremium: space.isPremium),
                          _StatusDotLabel(
                            label: _isVisible
                                ? (space.status == SpaceStatus.available
                                    ? '예약 가능'
                                    : '예약 중지')
                                : '숨김 상태',
                            dotColor: _isVisible &&
                                    space.status == SpaceStatus.available
                                ? AppTheme.green600
                                : AppTheme.stitchTextSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Row(
                        children: [
                          const Icon(
                            Icons.chair_outlined,
                            size: 16,
                            color: AppTheme.stitchTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${space.facilities.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.stitchTextSecondary,
                            ),
                          ),
                          if (_isVisible && pendingBookingCount > 0) ...[
                            const SizedBox(width: AppTheme.spacing3),
                            const Icon(
                              Icons.event_note_outlined,
                              size: 16,
                              color: AppTheme.stitchTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$pendingBookingCount건',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.stitchPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
              child: Divider(height: 1, color: AppTheme.borderGray),
            ),
            Row(
              children: [
                Text(
                  _isVisible ? '노출중' : '숨김',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        _isVisible ? FontWeight.w700 : FontWeight.w500,
                    color: _isVisible
                        ? AppTheme.stitchTextPrimary
                        : AppTheme.stitchTextSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                if (isVisibilityUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch.adaptive(
                    value: _isVisible,
                    onChanged: onToggleVisibility,
                    activeTrackColor:
                        AppTheme.stitchPrimary.withValues(alpha: 0.45),
                    activeThumbColor: AppTheme.stitchPrimary,
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _isVisible ? onBookings : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.stitchTextSecondary,
                    side: const BorderSide(color: AppTheme.borderGray),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: const Text(
                    '예약 관리',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceThumbnail extends StatelessWidget {
  const _SpaceThumbnail({
    required this.imageUrl,
    required this.dimmed,
  });

  final String? imageUrl;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: SizedBox(
        width: 80,
        height: 80,
        child: AppNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 160,
          fallbackIcon: Icons.storefront_outlined,
        ),
      ),
    );

    if (dimmed) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: image,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: image,
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isPremium
            ? AppTheme.stitchPrimary.withValues(alpha: 0.1)
            : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPremium ? '프리미엄' : '일반',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isPremium
              ? AppTheme.stitchPrimary
              : AppTheme.stitchTextSecondary,
        ),
      ),
    );
  }
}

class _StatusDotLabel extends StatelessWidget {
  const _StatusDotLabel({
    required this.label,
    required this.dotColor,
  });

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.stitchTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SpaceCardMenu extends StatelessWidget {
  const _SpaceCardMenu({
    required this.isHidden,
    required this.onEdit,
    required this.onHide,
    required this.onUnhide,
    required this.onDelete,
  });

  final bool isHidden;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback onUnhide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        size: 20,
        color: AppTheme.stitchTextSecondary,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'hide':
            onHide();
          case 'unhide':
            onUnhide();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('수정'),
        ),
        if (isHidden)
          const PopupMenuItem(
            value: 'unhide',
            child: Text('숨김 해제'),
          )
        else
          const PopupMenuItem(
            value: 'hide',
            child: Text('숨기기'),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            '삭제',
            style: TextStyle(color: AppTheme.urgentRed),
          ),
        ),
      ],
    );
  }
}
