import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';

/// 공간 예약 관리 — 상태 필터 pill (전체 · 승인 대기 · 확정 · 이용 중 · 완료).
class ShopSpaceBookingsFilterBar extends StatelessWidget {
  const ShopSpaceBookingsFilterBar({
    super.key,
    required this.selected,
    required this.totalCount,
    required this.pendingCount,
    required this.confirmedCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.onChanged,
    required this.statusLabel,
  });

  final BookingStatus? selected;
  final int totalCount;
  final int pendingCount;
  final int confirmedCount;
  final int inProgressCount;
  final int completedCount;
  final ValueChanged<BookingStatus?> onChanged;
  final String Function(BookingStatus status) statusLabel;

  static const List<BookingStatus> visibleStatuses = [
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.inProgress,
    BookingStatus.completed,
  ];

  int _countFor(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => pendingCount,
      BookingStatus.confirmed => confirmedCount,
      BookingStatus.inProgress => inProgressCount,
      BookingStatus.completed => completedCount,
      BookingStatus.cancelled => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing5,
        AppTheme.spacing3,
        AppTheme.spacing5,
        AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterPill(
              label: '전체 ($totalCount)',
              isSelected: selected == null,
              onTap: () => onChanged(null),
            ),
            for (final status in visibleStatuses) ...[
              const SizedBox(width: AppTheme.spacing2),
              _FilterPill(
                label: '${statusLabel(status)} (${_countFor(status)})',
                isSelected: selected == status,
                onTap: () => onChanged(status),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.stitchPrimary : AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: isSelected ? AppTheme.stitchPrimary : AppTheme.borderGray,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing2,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.stitchTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
