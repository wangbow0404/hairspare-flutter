import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';

class ShopMySpaceCard extends StatelessWidget {
  const ShopMySpaceCard({
    super.key,
    required this.space,
    required this.isStatusUpdating,
    required this.onToggleAvailability,
    required this.onBookings,
    required this.onEdit,
    required this.onHide,
    required this.onUnhide,
    required this.onDelete,
  });

  final SpaceRental space;
  final bool isStatusUpdating;
  final VoidCallback onToggleAvailability;
  final VoidCallback onBookings;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback onUnhide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasImage = space.imageUrls != null && space.imageUrls!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: space.isHidden ? AppTheme.borderGray : AppTheme.primaryPurple.withValues(alpha: 0.12),
          width: space.isHidden ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopMySpaceCardImage(
            imageUrl: hasImage ? space.imageUrls!.first : null,
            isHidden: space.isHidden,
            status: space.status,
            isPremium: space.isPremium,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            space.shopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          Wrap(
                            spacing: AppTheme.spacing1,
                            runSpacing: AppTheme.spacing1,
                            children: [
                              _ShopMySpaceStatusBadge(status: space.status),
                              if (space.isHidden) const _ShopMySpaceHiddenBadge(),
                              if (space.isPremium)
                                const _ShopMySpacePremiumBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!space.isHidden)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onHide,
                            icon: const Icon(Icons.visibility_off_outlined, size: 20),
                            color: AppTheme.textSecondary,
                            tooltip: '숨기기',
                          ),
                        if (space.isHidden)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onUnhide,
                            icon: const Icon(Icons.visibility_outlined, size: 20),
                            color: AppTheme.primaryPurple,
                            tooltip: '숨김 해제',
                          ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: AppTheme.textSecondary,
                          tooltip: '수정',
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppTheme.urgentRed,
                          tooltip: '삭제',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing3),
                _ShopMySpaceMetaRow(
                  icon: Icons.location_on_outlined,
                  text: space.fullAddress,
                ),
                const SizedBox(height: AppTheme.spacing1),
                _ShopMySpaceMetaRow(
                  icon: Icons.map_outlined,
                  text: RegionHelper.getRegionName(space.regionId),
                ),
                const SizedBox(height: AppTheme.spacing3),
                _ShopMySpacePriceRow(pricePerHour: space.pricePerHour),
                if (space.facilities.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacing3),
                  _ShopMySpaceFacilityChips(facilities: space.facilities),
                ],
                if (space.isHidden) ...[
                  const SizedBox(height: AppTheme.spacing3),
                  const _ShopMySpaceHiddenNotice(),
                ],
                const SizedBox(height: AppTheme.spacing3),
                _ShopMySpaceAvailabilityRow(
                  isAvailable: space.status == SpaceStatus.available,
                  isUpdating: isStatusUpdating,
                  onChanged: (_) => onToggleAvailability(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderGray),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing3),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onBookings,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('예약 관리'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  side: BorderSide(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopMySpaceCardImage extends StatelessWidget {
  const _ShopMySpaceCardImage({
    required this.imageUrl,
    required this.isHidden,
    required this.status,
    required this.isPremium,
  });

  final String? imageUrl;
  final bool isHidden;
  final SpaceStatus status;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (imageUrl != null)
          Image.network(
            imageUrl!,
            width: double.infinity,
            height: 168,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ShopMySpaceImagePlaceholder(),
          )
        else
          const _ShopMySpaceImagePlaceholder(),
        if (isHidden)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: Text(
                '숨김 중',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          top: AppTheme.spacing3,
          left: AppTheme.spacing3,
          child: _ShopMySpaceStatusBadge(status: status, onImage: true),
        ),
        if (isPremium)
          const Positioned(
            top: AppTheme.spacing3,
            right: AppTheme.spacing3,
            child: _ShopMySpacePremiumBadge(compact: true),
          ),
      ],
    );
  }
}

class _ShopMySpaceImagePlaceholder extends StatelessWidget {
  const _ShopMySpaceImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 168,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundGradientStart,
            AppTheme.primaryPurpleLight,
          ],
        ),
      ),
      child: const Icon(
        Icons.meeting_room_outlined,
        size: 48,
        color: AppTheme.primaryPurple,
      ),
    );
  }
}

class _ShopMySpaceStatusBadge extends StatelessWidget {
  const _ShopMySpaceStatusBadge({
    required this.status,
    this.onImage = false,
  });

  final SpaceStatus status;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      SpaceStatus.available => ('예약 가능', AppTheme.green600, Colors.white),
      SpaceStatus.booked => ('예약됨', AppTheme.primaryPurple, Colors.white),
      SpaceStatus.unavailable => ('예약 중지', AppTheme.urgentRed, Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2 + 2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: onImage ? bg.withValues(alpha: 0.92) : bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onImage ? fg : bg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ShopMySpaceHiddenBadge extends StatelessWidget {
  const _ShopMySpaceHiddenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: const Text(
        '숨김',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ShopMySpacePremiumBadge extends StatelessWidget {
  const _ShopMySpacePremiumBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppTheme.spacing2 : AppTheme.spacing2 + 2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        compact ? 'PREMIUM' : '프리미엄',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ShopMySpaceMetaRow extends StatelessWidget {
  const _ShopMySpaceMetaRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: AppTheme.spacing1),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopMySpacePriceRow extends StatelessWidget {
  const _ShopMySpacePriceRow({required this.pricePerHour});

  final int pricePerHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurpleLight,
            AppTheme.primaryPurpleLight.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, size: 20, color: AppTheme.primaryPurple),
          const SizedBox(width: AppTheme.spacing2),
          Text(
            '시간당 ${NumberFormat('#,###').format(pricePerHour)}원',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryPurpleDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopMySpaceFacilityChips extends StatelessWidget {
  const _ShopMySpaceFacilityChips({required this.facilities});

  final List<String> facilities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing2,
      children: facilities.take(6).map((facility) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2 + 2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: AppTheme.purple100,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            facility,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.purple700,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ShopMySpaceHiddenNotice extends StatelessWidget {
  const _ShopMySpaceHiddenNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 18,
            color: AppTheme.textSecondary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              '스페어 검색·목록에 노출되지 않습니다. 숨김 해제 시 다시 보입니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopMySpaceAvailabilityRow extends StatelessWidget {
  const _ShopMySpaceAvailabilityRow({
    required this.isAvailable,
    required this.isUpdating,
    required this.onChanged,
  });

  final bool isAvailable;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예약 받기',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  isAvailable ? '스페어가 예약할 수 있어요' : '새 예약을 받지 않아요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isUpdating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: isAvailable,
              onChanged: onChanged,
              activeTrackColor: AppTheme.primaryPurple.withValues(alpha: 0.5),
              activeThumbColor: AppTheme.primaryPurple,
            ),
        ],
      ),
    );
  }
}

class ShopMySpacesHeroBanner extends StatelessWidget {
  const ShopMySpacesHeroBanner({super.key, required this.spaceCount});

  final int spaceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        0,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlueDark,
            AppTheme.primaryPurple,
            AppTheme.primaryPink,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 공간 $spaceCount개',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '숨기기로 노출을 끄거나, 예약 받기로 예약 가능 여부를 조절하세요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

enum ShopMySpacesFilter { all, visible, hidden }

class ShopMySpacesFilterBar extends StatelessWidget {
  const ShopMySpacesFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ShopMySpacesFilter selected;
  final ValueChanged<ShopMySpacesFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Row(
        children: ShopMySpacesFilter.values.map((filter) {
          final isSelected = selected == filter;
          final label = switch (filter) {
            ShopMySpacesFilter.all => '전체',
            ShopMySpacesFilter.visible => '노출중',
            ShopMySpacesFilter.hidden => '숨김',
          };
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing2),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppTheme.primaryPurpleLight,
              checkmarkColor: AppTheme.primaryPurple,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryPurpleDark : AppTheme.textSecondary,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryPurple.withValues(alpha: 0.4)
                    : AppTheme.borderGray,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
