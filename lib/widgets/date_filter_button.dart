import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_date_picker.dart';

/// 날짜 필터 버튼 (공간대여, 공고, 교육 목록 공통)
class DateFilterButton extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onClear;

  const DateFilterButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = selectedDate != null
        ? '${selectedDate!.month}월 ${selectedDate!.day}일'
        : '날짜';
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final date = await showAppDatePicker(
          context,
          initialDate: selectedDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border.all(
            color: selectedDate != null
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.borderGray,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: selectedDate != null
                  ? AppTheme.primaryBlue
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacing2),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selectedDate != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
            if (selectedDate != null) ...[
              const SizedBox(width: AppTheme.spacing2),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
