import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';

import 'work_check_week_strip.dart';

/// 근무/시술 현황 — 주간 strip + 날짜 검색(과거·미래 날짜로 이동).
class WorkCheckCalendarSection extends StatelessWidget {
  const WorkCheckCalendarSection({
    super.key,
    required this.vm,
    required this.audience,
    required this.isModelMode,
  });

  final WorkCheckViewModel vm;
  final ScheduleSessionAudience audience;
  final bool isModelMode;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    vm.selectDate(
      picked,
      hasWork: vm.hasScheduledWork(picked) || vm.hasEducationOnDate(picked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      decoration: const BoxDecoration(
        color: HairSpareColors.surface,
        border: Border(
          top: BorderSide(color: HairSpareColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audience.calendarSectionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: const Padding(
                    padding: EdgeInsets.all(AppTheme.spacing2),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 22,
                      color: HairSpareColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          WorkCheckWeekStrip(vm: vm),
          if (!isModelMode) ...[
            const SizedBox(height: AppTheme.spacing3),
            const _WeekStripLegend(),
          ],
        ],
      ),
    );
  }
}

class _WeekStripLegend extends StatelessWidget {
  const _WeekStripLegend();

  static const _items = [
    (label: '근무완료', color: HairSpareColors.statusSuccess),
    (label: '근무예정', color: HairSpareColors.brandPrimary),
    (label: '교육', color: HairSpareColors.statusEducation),
    (label: '모델매칭', color: HairSpareColors.statusMatching),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing1),
      child: Wrap(
        spacing: AppTheme.spacing3,
        runSpacing: AppTheme.spacing1,
        children: [
          for (final item in _items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing1),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HairSpareColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
