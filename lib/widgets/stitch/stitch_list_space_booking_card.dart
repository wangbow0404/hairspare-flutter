import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';

/// 공간 예약 관리 — 예약 카드 (프로필 · 일정 · 금액 · 승인/거절).
class StitchListSpaceBookingCard extends StatelessWidget {
  const StitchListSpaceBookingCard({
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
    final isPending = booking.status == BookingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppTheme.stitchPrimary.withValues(alpha: 0.25)
              : AppTheme.borderGray,
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingAvatar(name: booking.spareName),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.spareName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spaceTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.stitchTextSecondary,
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
              color: AppTheme.stitchPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '총 ${NumberFormat('#,###').format(booking.totalPrice)}원',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.stitchPrimary,
              ),
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: AppTheme.spacing4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.urgentRed,
                      side: const BorderSide(color: AppTheme.urgentRed),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '거절',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.stitchPrimaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '승인',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingAvatar extends StatelessWidget {
  const _BookingAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first : '?';

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.stitchPrimary.withValues(alpha: 0.1),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.stitchPrimary,
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
        horizontal: 10,
        vertical: 4,
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
        Icon(icon, size: 16, color: AppTheme.stitchTextSecondary),
        const SizedBox(width: AppTheme.spacing1),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
