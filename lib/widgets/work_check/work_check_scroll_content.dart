import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/schedule_work_session.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/region_helper.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';
import 'work_check_action_bar.dart';
import 'work_check_education_card.dart';

/// 스페어 근무체크 / 모델 시술 일정 스크롤 본문.
class WorkCheckScrollContent extends StatelessWidget {
  const WorkCheckScrollContent({super.key, this.isModelMode = false});

  final bool isModelMode;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkCheckViewModel>();
    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
    final titleInfo = isModelMode
        ? vm.getModelScheduleTitle()
        : vm.getWorkCheckTitle(vm.consecutiveDays);
    final displayDays = vm.consecutiveDays % 10;
    final daysInMonth = vm.getDaysInMonth(vm.currentMonth);
    final upcomingCount = vm.upcomingScheduleCount;

    return Column(
      children: [
        // Hero Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing8,
            horizontal: AppTheme.spacing4,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7800CE),
                Color(0xFF9333EA),
                Color(0xFFEC4899),
              ],
            ),
          ),
          child: Column(
            children: [
              // 배경 장식
              Stack(
                children: [
                  Positioned(
                    top: AppTheme.spacing4,
                    left: AppTheme.spacing4,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppTheme.spacing8,
                    right: AppTheme.spacing8,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        titleInfo['emoji'] as String,
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      Text(
                        titleInfo['title'] as String,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(
                        titleInfo['subtitle'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Container(
                        padding: AppTheme.spacingSymmetric(
                          horizontal: AppTheme.spacing5,
                          vertical: AppTheme.spacing2 + AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isModelMode
                                  ? titleInfo['pillLabel'] as String
                                  : audience.streakPillLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              isModelMode
                                  ? titleInfo['pillValue'] as String
                                  : '$displayDays일',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        if (isModelMode)
          _ModelScheduleSummarySection(upcomingCount: upcomingCount)
        else
          _WorkRewardSection(displayDays: displayDays),

        // 근무/시술 현황 - 달력
        Container(
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
        ),

        // 선택된 날짜 근무·교육 정보 카드
        if (vm.hasScheduledWork(vm.selectedDate) ||
            vm.hasEducationOnDate(vm.selectedDate))
          Container(
            width: double.infinity,
            padding: AppTheme.spacingSymmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing4,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                top: BorderSide(color: AppTheme.borderGray, width: 1),
              ),
            ),
            child: Column(
              children: [
                ...vm.schedules
                  .where(
                    (s) =>
                        s.date ==
                            DateFormat('yyyy-MM-dd').format(vm.selectedDate) &&
                        (s.status == 'scheduled' ||
                            s.status == 'completed' ||
                            (!isModelMode && s.status == 'proposed')),
                  )
                  .map((schedule) {
                    final workTimeText =
                        schedule.endTime != null &&
                            schedule.endTime!.trim().isNotEmpty
                        ? '${schedule.startTime}~${schedule.endTime}'
                        : '${schedule.startTime}~${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(schedule))}';
                    final isProposed = schedule.status == 'proposed';
                    final isSelected = vm.selectedScheduleId == schedule.id;
                    final isScheduleChecked = schedule.status == 'completed';
                    final scheduleDateStr = schedule.date;
                    final hasNewSchedule =
                        !vm.viewedDates.contains(scheduleDateStr) &&
                        !isScheduleChecked;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isScheduleChecked
                              ? null
                              : () async {
                                  if (!isModelMode && isProposed) {
                                    final resolved =
                                        await NavigationHelper
                                            .navigateToWorkProposalDetail(
                                      context,
                                      schedule,
                                    );
                                    if (resolved == true && context.mounted) {
                                      await vm.loadData();
                                    }
                                    return;
                                  }
                                  vm.selectSchedule(
                                    schedule.id,
                                    scheduleDateStr,
                                  );
                                },
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusLg,
                          ),
                          child: Container(
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: isScheduleChecked
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                                  : isSelected && !isScheduleChecked
                                  ? AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1)
                                  : AppTheme.backgroundWhite,
                              border: Border.all(
                                color: isScheduleChecked
                                    ? AppTheme.primaryBlue
                                    : isSelected && !isScheduleChecked
                                    ? AppTheme.stitchPrimaryContainer
                                    : AppTheme.borderGray,
                                width: isScheduleChecked ||
                                        (isSelected && !isScheduleChecked)
                                    ? 2
                                    : 1,
                              ),
                              borderRadius: AppTheme.borderRadius(
                                AppTheme.radiusLg,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (hasNewSchedule &&
                                                  !isScheduleChecked) ...[
                                                Container(
                                                  padding:
                                                      AppTheme.spacingSymmetric(
                                                        horizontal:
                                                            AppTheme.spacing2,
                                                        vertical:
                                                            AppTheme.spacing1 /
                                                            2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.urgentRed,
                                                    borderRadius:
                                                        AppTheme.borderRadius(
                                                          AppTheme.radiusFull,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '신규',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppTheme.spacing2,
                                                ),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  schedule.job?.shopName ??
                                                      '매장',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppTheme
                                                            .textPrimary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: AppTheme.spacing1,
                                          ),
                                          Text(
                                            workTimeText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 14,
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppTheme.spacing1,
                                          ),
                                          Text(
                                            audience.scheduleCardSubtitle(
                                              schedule.job?.shopName ?? '매장',
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.textTertiary,
                                                ),
                                          ),
                                          if (schedule.job?.regionId != null &&
                                              schedule
                                                  .job!.regionId.isNotEmpty) ...[
                                            const SizedBox(
                                              height: AppTheme.spacing1 / 2,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 13,
                                                  color: AppTheme.textTertiary,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  RegionHelper.getRegionName(
                                                    schedule.job!.regionId,
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontSize: 12,
                                                        color: AppTheme
                                                            .textTertiary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (isScheduleChecked &&
                                              schedule.checkInTime != null) ...[
                                            const SizedBox(
                                              height: AppTheme.spacing3,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                top: AppTheme.spacing3,
                                              ),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: AppTheme.borderGray,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                audience.completedAtLabel(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(schedule.checkInTime!),
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      color:
                                                          AppTheme.textTertiary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isScheduleChecked)
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            IconMapper.icon(
                                              'check',
                                              size: 20,
                                              color: Colors.white,
                                            ) ??
                                            const Icon(
                                              Icons.check,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                      )
                                    else
                                      Container(
                                        padding: AppTheme.spacingSymmetric(
                                          horizontal: AppTheme.spacing3,
                                          vertical: AppTheme.spacing1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.purple100,
                                          borderRadius: AppTheme.borderRadius(
                                            AppTheme.radiusFull,
                                          ),
                                        ),
                                          child: Text(
                                          !isModelMode && isProposed
                                              ? '제안 대기'
                                              : audience.scheduledLegend,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: !isModelMode && isProposed
                                                    ? AppTheme.stitchPrimaryContainer
                                                    : AppTheme.purple700,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ...vm
                    .getEnrollmentsForDate(vm.selectedDate)
                    .where((_) => !isModelMode)
                    .map(
                      (enrollment) => WorkCheckEducationCard(
                        enrollment: enrollment,
                      ),
                    ),
              ],
            ),
          ),

        WorkCheckActionBar(isModelMode: isModelMode),

        if (!isModelMode)
          Container(
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
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundGradientStart,
                  AppTheme.backgroundGradientMiddle,
                  AppTheme.backgroundGradientEnd,
                ],
              ),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppTheme.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '근무 보너스 팁',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing1),
                          Text(
                            '매일 출석하면 최대 에너지 3개를 받을 수 있어요!',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textGray700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing3),
                Container(
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Text(
                          vm.consecutiveDays >= 30
                              ? '$vm.consecutiveDays일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!'
                              : vm.consecutiveDays >= 20
                              ? '$vm.consecutiveDays일을 연속 출근하면 에너지 2개! 최대 2만원을 아낄 수 있어요!'
                              : vm.consecutiveDays >= 10
                              ? '$vm.consecutiveDays일을 연속 출근하면 에너지 1개! 최대 1만원을 아낄 수 있어요!'
                              : '30일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 14,
                                color: AppTheme.textGray700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isModelMode)
          Container(
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
            child: Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.backgroundGradientStart,
                    AppTheme.backgroundGradientMiddle,
                    AppTheme.backgroundGradientEnd,
                  ],
                ),
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Text(
                          audience.tipBannerMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textGray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        _ScheduleInfoSection(
          title: audience.infoSectionTitle,
          lines: audience.infoBulletLines,
        ),

        // 하단 여백 (하단 네비게이션 바)
        SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
      ],
    );
  }
}

class _ModelScheduleSummarySection extends StatelessWidget {
  const _ModelScheduleSummarySection({required this.upcomingCount});

  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    const maxDisplay = 5;
    final progress = (upcomingCount / maxDisplay).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppTheme.backgroundWhite),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시술 일정 요약',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '확정·조율 중인 시술 일정을 한눈에 확인하세요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '예정 시술',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGray700,
                      ),
                    ),
                    Text(
                      '$upcomingCount건',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.stitchPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing4),
                ClipRRect(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEF0F3),
                    color: AppTheme.stitchPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  upcomingCount == 0
                      ? '매칭된 시술 일정이 여기에 표시돼요.'
                      : '달력에서 날짜를 선택해 상세 일정을 확인하세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkRewardSection extends StatelessWidget {
  const _WorkRewardSection({required this.displayDays});

  final int displayDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppTheme.backgroundWhite),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '근무 보상',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '노쇼 없이 10회 연속 근무하면 에너지 1개를 받아요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final fillWidth = (displayDays / 10) * barWidth;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '에너지 진행률',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textGray700,
                              ),
                        ),
                        Text(
                          '$displayDays / 10회',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.stitchPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0F3),
                            borderRadius: AppTheme.borderRadius(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: Row(
                            children: [
                              ...List.generate(9, (index) {
                                return Expanded(
                                  child: Container(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 3,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppTheme.borderGray300,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        if (displayDays > 0)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: fillWidth.clamp(0.0, barWidth),
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.stitchPrimaryContainer,
                                      AppTheme.stitchPrimaryContainer,
                                    ],
                                  ),
                                  borderRadius: AppTheme.borderRadius(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (displayDays > 0)
                          Positioned(
                            left: (fillWidth - 32).clamp(
                              0.0,
                              barWidth - 64,
                            ),
                            top: 0,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.stitchPrimaryContainer,
                                    AppTheme.stitchPrimaryContainer,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '⚡',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _workCheckInfoItem(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '•',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 14,
          color: AppTheme.stitchPrimaryContainer,
        ),
      ),
      const SizedBox(width: AppTheme.spacing2),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    ],
  );
}

class _ScheduleInfoSection extends StatelessWidget {
  const _ScheduleInfoSection({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppTheme.spacing6,
        bottom: AppTheme.spacing2,
        left: AppTheme.spacing4,
        right: AppTheme.spacing4,
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
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTheme.spacing3),
            _workCheckInfoItem(context, lines[i]),
          ],
        ],
      ),
    );
  }
}
