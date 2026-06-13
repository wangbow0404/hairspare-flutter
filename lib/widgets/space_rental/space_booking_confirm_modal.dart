import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';

/// 공간 예약 확인 — 글래스모피즘 모달. `true` = 예약 확정.
Future<bool> showSpaceBookingConfirmModal(
  BuildContext context, {
  required String shopName,
  required DateTime startTime,
  required DateTime endTime,
  required int totalPrice,
}) {
  return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (dialogContext) => SpaceBookingConfirmModal(
          shopName: shopName,
          startTime: startTime,
          endTime: endTime,
          totalPrice: totalPrice,
        ),
      ).then((v) => v ?? false);
}

class SpaceBookingConfirmModal extends StatelessWidget {
  const SpaceBookingConfirmModal({
    super.key,
    required this.shopName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
  });

  final String shopName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy년 M월 d일', 'ko_KR');
    final timeFmt = DateFormat('HH:mm', 'ko_KR');
    final priceFmt = NumberFormat('#,###');
    final dateLine = dateFmt.format(startTime);
    final timeLine =
        '${timeFmt.format(startTime)} – ${timeFmt.format(endTime)}';

    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(false),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: _BookingGlassPanel(
                shopName: shopName,
                dateLine: dateLine,
                timeLine: timeLine,
                priceLine: '${priceFmt.format(totalPrice)}원',
                onCancel: () => Navigator.of(context).pop(false),
                onConfirm: () => Navigator.of(context).pop(true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingGlassPanel extends StatelessWidget {
  const _BookingGlassPanel({
    required this.shopName,
    required this.dateLine,
    required this.timeLine,
    required this.priceLine,
    required this.onCancel,
    required this.onConfirm,
  });

  final String shopName;
  final String dateLine;
  final String timeLine;
  final String priceLine;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.82),
                Colors.white.withValues(alpha: 0.64),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: _BookingModalTitle()),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: onCancel,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: AppTheme.textTertiary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const _BookingHeroIcon(),
              const SizedBox(height: 14),
              _BookingDetailRow(
                icon: Icons.storefront_outlined,
                label: '미용실',
                value: shopName,
              ),
              const SizedBox(height: 10),
              _BookingDetailRow(
                icon: Icons.calendar_today_outlined,
                label: '날짜',
                value: dateLine,
              ),
              const SizedBox(height: 10),
              _BookingDetailRow(
                icon: Icons.schedule_outlined,
                label: '시간',
                value: timeLine,
              ),
              const SizedBox(height: 12),
              _BookingPriceHighlight(priceLine: priceLine),
              const SizedBox(height: 10),
              Text(
                '지금 선결제되며, 샵 승인 후 예약이 확정됩니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _BookingConfirmButton(onPressed: onConfirm),
              const SizedBox(height: 8),
              _BookingCancelButton(onPressed: onCancel),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingModalTitle extends StatelessWidget {
  const _BookingModalTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      '공간 예약',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: -0.3,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _BookingHeroIcon extends StatelessWidget {
  const _BookingHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFE0E7FF).withValues(alpha: 0.95),
            const Color(0xFFF5F3FF).withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        '🪑',
        style: TextStyle(fontSize: 36, height: 1),
      ),
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  const _BookingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingPriceHighlight extends StatelessWidget {
  const _BookingPriceHighlight({required this.priceLine});

  final String priceLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEDE9FE).withValues(alpha: 0.7),
            const Color(0xFFE0E7FF).withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFDDD6FE).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 결제 예정',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6D28D9),
            ),
          ),
          Text(
            priceLine,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.3,
              color: const Color(0xFF5B21B6),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingConfirmButton extends StatelessWidget {
  const _BookingConfirmButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '예약하기',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCancelButton extends StatelessWidget {
  const _BookingCancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        '취소',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
