import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../view_models/work_check_view_model.dart';

/// PDF a안 — 7일 주간 날짜 strip (선택일 #161616).
class WorkCheckWeekStrip extends StatelessWidget {
  const WorkCheckWeekStrip({
    super.key,
    required this.vm,
  });

  final WorkCheckViewModel vm;

  List<DateTime> _weekDays(DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekDays(vm.selectedDate);
    const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacing2),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _sameDay(day, vm.selectedDate);
          final hasWork = vm.hasScheduledWork(day) || vm.hasEducationOnDate(day);
          final dotColor = _dotColor(day);

          return GestureDetector(
            onTap: () => vm.selectDate(
              day,
              hasWork: hasWork,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? HairSpareColors.activeStructural
                    : HairSpareColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: isSelected
                      ? HairSpareColors.activeStructural
                      : HairSpareColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayLabels[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : HairSpareColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : HairSpareColors.textPrimary,
                    ),
                  ),
                  if (dotColor != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 날짜별 상태 점 색 — 근무완료(초록) > 근무예정(베리) > 교육(주황) > 모델매칭(파랑) 우선순위.
  Color? _dotColor(DateTime day) {
    if (vm.hasScheduledWork(day) && vm.isChecked(day)) {
      return HairSpareColors.statusSuccess;
    }
    if (vm.hasScheduledWork(day)) {
      return HairSpareColors.brandPrimary;
    }
    if (vm.hasEducationOnDate(day)) {
      return HairSpareColors.statusEducation;
    }
    if (vm.hasModelMatchOnDate(day)) {
      return HairSpareColors.statusMatching;
    }
    return null;
  }
}
