import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/space_booking_rules.dart';
import '../../utils/space_hourly_slot_grid.dart';
import '../custom_date_picker_dialog.dart';

/// 공간 예약 — 날짜 선택 + 1시간 칸 그리드 + 선택 요약.
class SpaceRentalTimeSlotPicker extends StatelessWidget {
  const SpaceRentalTimeSlotPicker({
    super.key,
    required this.selectedDate,
    required this.cells,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalPrice,
    required this.onDateChanged,
    required this.onCellTap,
    this.minHours = 1,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? selectedDate;
  final List<HourlySlotCell> cells;
  final HourlySlotCell? rangeStart;
  final HourlySlotCell? rangeEnd;
  final int totalPrice;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<HourlySlotCell> onCellTap;
  final int minHours;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final hasSelection = rangeStart != null && rangeEnd != null;

    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 가능 시간',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          _DatePickerButton(
            selectedDate: selectedDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: onDateChanged,
          ),
          const SizedBox(height: AppTheme.spacing4),
          if (cells.isEmpty)
            const _EmptySlotsMessage()
          else
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: cells.map((cell) {
                return SpaceHourSlotChip(
                  cell: cell,
                  isRangeStart: rangeStart?.startTime == cell.startTime,
                  isRangeEnd: rangeEnd?.startTime == cell.startTime,
                  isInRange: _isInSelectedRange(cell),
                  onTap: () => onCellTap(cell),
                );
              }).toList(),
            ),
          if (hasSelection) ...[
            const SizedBox(height: AppTheme.spacing4),
            _BookingSummaryCard(
              start: rangeStart!,
              end: rangeEnd!,
              totalPrice: totalPrice,
              minHours: minHours,
            ),
          ],
        ],
      ),
    );
  }

  bool _isInSelectedRange(HourlySlotCell cell) {
    if (rangeStart == null || rangeEnd == null) return false;
    final a = rangeStart!.startTime;
    final b = rangeEnd!.startTime;
    final lo = a.isBefore(b) ? a : b;
    final hi = a.isBefore(b) ? b : a;
    return !cell.startTime.isBefore(lo) && !cell.startTime.isAfter(hi);
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await CustomDatePickerDialog.show(
            context,
            initialDate: selectedDate ?? now,
            firstDate: firstDate ?? now,
            lastDate: lastDate ?? now.add(const Duration(days: 30)),
          );
          if (picked != null) onDateChanged(picked);
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            color: const Color(0xFFF8FAFC).withValues(alpha: 0.8),
          ),
          child: Padding(
            padding: AppTheme.spacing(AppTheme.spacing3),
            child: Row(
              children: [
                IconMapper.icon(
                      'calendar',
                      size: 18,
                      color: AppTheme.textSecondary,
                    ) ??
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat(
                            'yyyy년 M월 d일 (E)',
                            'ko_KR',
                          ).format(selectedDate!)
                        : '날짜 선택',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlotsMessage extends StatelessWidget {
  const _EmptySlotsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Text(
          '선택한 날짜에 표시할 시간대가 없습니다.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 1시간 칸 칩 — 상태·범위 선택 스타일.
class SpaceHourSlotChip extends StatelessWidget {
  const SpaceHourSlotChip({
    super.key,
    required this.cell,
    required this.onTap,
    this.isRangeStart = false,
    this.isRangeEnd = false,
    this.isInRange = false,
  });

  final HourlySlotCell cell;
  final VoidCallback onTap;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isInRange;

  @override
  Widget build(BuildContext context) {
    final label =
        '${DateFormat('HH:mm').format(cell.startTime)}–${DateFormat('HH:mm').format(cell.endTime)}';
    final selected = isRangeStart || isRangeEnd || isInRange;
    final styles = _stylesFor(cell.state, selected);

    return IgnorePointer(
      ignoring: !cell.isTappable,
      child: Opacity(
        opacity: cell.isTappable ? 1 : 0.55,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: cell.isTappable ? onTap : null,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: styles.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: styles.border),
                boxShadow: selected && cell.isTappable
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: styles.foreground,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ChipStyle _stylesFor(SlotCellState state, bool selected) {
    if (selected && state == SlotCellState.available) {
      return const _ChipStyle(
        background: Color(0xFF6366F1),
        border: Color(0xFF6366F1),
        foreground: Colors.white,
      );
    }
    switch (state) {
      case SlotCellState.available:
        return const _ChipStyle(
          background: Color(0xFFF8FAFC),
          border: Color(0xFFE2E8F0),
          foreground: AppTheme.textPrimary,
        );
      case SlotCellState.booked:
        return const _ChipStyle(
          background: Color(0xFFF1F5F9),
          border: Color(0xFFE2E8F0),
          foreground: Color(0xFF94A3B8),
        );
      case SlotCellState.past:
      case SlotCellState.unavailable:
        return const _ChipStyle(
          background: Color(0xFFF1F5F9),
          border: Color(0xFFE8EDF2),
          foreground: Color(0xFFCBD5E1),
        );
    }
  }
}

class _ChipStyle {
  const _ChipStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({
    required this.start,
    required this.end,
    required this.totalPrice,
    required this.minHours,
  });

  final HourlySlotCell start;
  final HourlySlotCell end;
  final int totalPrice;
  final int minHours;

  @override
  Widget build(BuildContext context) {
    final timeLine =
        '${DateFormat('HH:mm').format(start.startTime)} – ${DateFormat('HH:mm').format(end.endTime)}';
    final priceFmt = NumberFormat('#,###');
    final selectedHours = SpaceHourlySlotGrid.durationHours(start, end);
    final meetsMin = SpaceBookingRules.meetsMinHours(
      selectedHours: selectedHours,
      minHours: minHours,
    );

    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: meetsMin
              ? [
                  const Color(0xFFEDE9FE).withValues(alpha: 0.65),
                  const Color(0xFFE0E7FF).withValues(alpha: 0.45),
                ]
              : [
                  const Color(0xFFFFF7ED).withValues(alpha: 0.9),
                  const Color(0xFFFFEDD5).withValues(alpha: 0.6),
                ],
        ),
        border: Border.all(
          color: meetsMin
              ? const Color(0xFFDDD6FE).withValues(alpha: 0.7)
              : AppTheme.orange100.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예약 시간',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: meetsMin
                              ? const Color(0xFF6D28D9)
                              : AppTheme.orange600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLine,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  Text(
                    '$selectedHours시간 선택',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '총 금액',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: meetsMin
                              ? const Color(0xFF6D28D9)
                              : AppTheme.orange600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${priceFmt.format(totalPrice)}원',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: meetsMin
                              ? const Color(0xFF5B21B6)
                              : AppTheme.orange600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          if (!meetsMin) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(
              SpaceBookingRules.belowMinHoursMessage(minHours),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.orange600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
