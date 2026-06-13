import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';

class ShopSpaceBookingsHero extends StatelessWidget {
  const ShopSpaceBookingsHero({
    super.key,
    required this.pendingCount,
    required this.totalCount,
  });

  final int pendingCount;
  final int totalCount;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 $totalCount건',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pendingCount > 0
                ? '승인 대기 $pendingCount건 — 승인하면 예약이 확정됩니다.'
                : '승인 대기 중인 예약이 없습니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopSpaceBookingFilterBar extends StatelessWidget {
  const ShopSpaceBookingFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.statusLabel,
  });

  final BookingStatus? selected;
  final ValueChanged<BookingStatus?> onChanged;
  final String Function(BookingStatus status) statusLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Row(
        children: [
          _FilterChip(
            label: '전체',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          ...BookingStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacing2),
              child: _FilterChip(
                label: statusLabel(status),
                selected: selected == status,
                onTap: () => onChanged(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryPurpleLight,
      checkmarkColor: AppTheme.primaryPurple,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppTheme.primaryPurpleDark : AppTheme.textSecondary,
      ),
      side: BorderSide(
        color: selected
            ? AppTheme.primaryPurple.withValues(alpha: 0.4)
            : AppTheme.borderGray,
      ),
    );
  }
}

class ShopSpaceBookingCard extends StatelessWidget {
  const ShopSpaceBookingCard({
    super.key,
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.onApprove,
    required this.onReject,
  });

  final SpaceBooking booking;
  final String Function(BookingStatus status) statusLabel;
  final Color Function(BookingStatus status) statusColor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final spaceTitle =
        booking.spaceRental?.shopName ?? booking.spaceRental?.address ?? '공간';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: booking.status == BookingStatus.pending
              ? AppTheme.primaryPurple.withValues(alpha: 0.25)
              : AppTheme.borderGray,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryPurpleLight,
                  child: Text(
                    booking.spareName.isNotEmpty
                        ? booking.spareName.characters.first
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.spareName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spaceTitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _BookingStatusBadge(
                  label: statusLabel(booking.status),
                  color: statusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing4),
            _BookingMetaRow(
              icon: Icons.event_outlined,
              text: DateFormat('M월 d일 (E)', 'ko_KR').format(booking.startTime),
            ),
            const SizedBox(height: AppTheme.spacing1),
            _BookingMetaRow(
              icon: Icons.schedule_outlined,
              text:
                  '${DateFormat('HH:mm').format(booking.startTime)} ~ ${DateFormat('HH:mm').format(booking.endTime)}'
                  ' · ${booking.durationInHours.toStringAsFixed(1)}시간',
            ),
            const SizedBox(height: AppTheme.spacing3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Text(
                '총 ${NumberFormat('#,###').format(booking.totalPrice)}원',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPurpleDark,
                ),
              ),
            ),
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: AppTheme.spacing4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.urgentRed,
                        side: const BorderSide(color: AppTheme.urgentRed),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                      ),
                      child: const Text('거절'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                      ),
                      child: const Text('승인'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  const _BookingStatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2 + 2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookingMetaRow extends StatelessWidget {
  const _BookingMetaRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: AppTheme.spacing1),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
