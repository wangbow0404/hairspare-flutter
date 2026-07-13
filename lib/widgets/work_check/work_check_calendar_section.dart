import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';

/// 근무/시술 현황 달력 섹션 (월 네비게이션 + 그리드 + 범례).
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

  @override
  Widget build(BuildContext context) {
    final daysInMonth = vm.getDaysInMonth(vm.currentMonth);

    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            audience.calendarSectionTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 달력 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    vm.goToPreviousMonth();
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child:
                        IconMapper.icon(
                          'chevronleft',
                          size: 20,
                          color: AppTheme.textSecondary,
                        ) ??
                        const Icon(
                          Icons.chevron_left,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              ),
              Text(
                '${vm.currentMonth.year}년 ${vm.currentMonth.month}월',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    vm.goToNextMonth();
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child:
                        IconMapper.icon(
                          'chevronright',
                          size: 20,
                          color: AppTheme.textSecondary,
                        ) ??
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 요일 라벨
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(
              (day) {
                final isSunday = day == 'Sun';
                final isSaturday = day == 'Sat';
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSunday
                                ? AppTheme.urgentRed
                                : isSaturday
                                ? AppTheme.stitchPrimaryContainer
                                : AppTheme.textGray700,
                          ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: AppTheme.spacing2),
          // 달력 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.82, // 달력 셀 크기 확대 + BOTTOM 오버플로우 방지
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final date = daysInMonth[index];
              final isCurrentMonth = date.month == vm.currentMonth.month;
              final isToday =
                  DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
              final hasWork = isCurrentMonth && vm.hasScheduledWork(date);
              final hasEducation =
                  isCurrentMonth && vm.hasEducationOnDate(date);
              final hasAnyEvent = hasWork || hasEducation;
              final isWorkChecked = isCurrentMonth && vm.isChecked(date);
              final isSelectedDate =
                  DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(vm.selectedDate);
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final hasNewSchedule =
                  hasWork &&
                  !vm.viewedDates.contains(dateStr) &&
                  !isWorkChecked;

              // 요일 확인 (일요일 = 0, 토요일 = 6)
              final weekday =
                  date.weekday % 7; // 일요일 = 0, 월요일 = 1, ..., 토요일 = 6
              final isSunday = weekday == 0;
              final isSaturday = weekday == 6;

              if (!isCurrentMonth) {
                return const SizedBox.shrink();
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    vm.selectDate(date, hasWork: hasAnyEvent);
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isWorkChecked
                          ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                          : isToday
                          ? AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1)
                          : AppTheme.backgroundWhite,
                      border: Border.all(
                        color: isWorkChecked
                            ? AppTheme.primaryBlue
                            : isToday
                            ? AppTheme.stitchPrimaryContainer
                            : hasAnyEvent
                            ? AppTheme.stitchPrimaryContainer
                            : AppTheme.borderGray,
                        width: isSelectedDate && hasAnyEvent ? 2 : 1,
                      ),
                      borderRadius: AppTheme.borderRadius(
                        AppTheme.radiusLg,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${date.day}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isToday
                                        ? AppTheme.stitchPrimaryContainer
                                        : isSunday
                                        ? AppTheme.urgentRed
                                        : isSaturday
                                        ? AppTheme.stitchPrimaryContainer
                                        : AppTheme.textGray700,
                                  ),
                            ),
                            if (hasNewSchedule)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.urgentRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        if (hasWork)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppTheme.spacing1,
                            ),
                            child: isWorkChecked
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        IconMapper.icon(
                                          'check',
                                          size: 6,
                                          color: Colors.white,
                                        ) ??
                                        const Icon(
                                          Icons.check,
                                          size: 6,
                                          color: Colors.white,
                                        ),
                                  )
                                : Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.stitchPrimaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                        if (hasEducation)
                          Padding(
                            padding: EdgeInsets.only(
                              top: hasWork ? 2 : AppTheme.spacing1,
                            ),
                            child: const Icon(
                              Icons.school,
                              size: 12,
                              color: AppTheme.stitchPrimaryContainer,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 범례
          Row(
            children: [
              const SizedBox(width: AppTheme.spacing4),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.stitchPrimaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    audience.scheduledLegend,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacing4),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child:
                        IconMapper.icon(
                          'check',
                          size: 10,
                          color: Colors.white,
                        ) ??
                        const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    audience.completedLegend,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacing4),
              if (!isModelMode)
                Row(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 16,
                      color: AppTheme.stitchPrimaryContainer,
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    Text(
                      '교육',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
