import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/schedule_work_session.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/schedule_cancel_flow.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../view_models/work_check_view_model.dart';
import 'work_check_education_card.dart';

/// 스페어 근무체크 스크롤 본문 (히어로, 달력, 카드, 체크 버튼, 안내).
class WorkCheckScrollContent extends StatelessWidget {
  const WorkCheckScrollContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkCheckViewModel>();
    final titleInfo = vm.getWorkCheckTitle(vm.consecutiveDays);
    final displayDays = vm.consecutiveDays % 10;
    final daysInMonth = vm.getDaysInMonth(vm.currentMonth);

    return Column(
      children: [
        // Hero Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing8,
            horizontal: AppTheme.spacing4,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
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
                        color: AppTheme.primaryPurple500.withValues(alpha: 0.2),
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
                              '현재 연속 근무',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              '$displayDays일',
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

        // 근무 보상 섹션 - 에너지 게이지
        Container(
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
                '노쇼 없이 10일 연속 근무하면 에너지 1개를 받아요!',
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
                              '$displayDays / 10일',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        // 에너지 게이지
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
                                  // 틱 마크 (9개 구분선 - 10등분)
                                  ...List.generate(9, (index) {
                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: index < 8 ? 0 : 0,
                                        ),
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
                            // 채워진 진행률 (그라데이션)
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
                                          AppTheme.primaryBlue,
                                          AppTheme.primaryPurple500,
                                        ],
                                      ),
                                      borderRadius: AppTheme.borderRadius(
                                        AppTheme.radiusFull,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // 원형 배지 (번개 아이콘)
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
                                        AppTheme.primaryBlue,
                                        AppTheme.primaryPurple500,
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
        ),

        // 근무 현황 - 달력
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
                '근무 현황',
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
                                    ? AppTheme.primaryBlue
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
                          color: isToday
                              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                              : AppTheme.backgroundWhite,
                          border: Border.all(
                            color: isToday
                                ? AppTheme.primaryBlue
                                : hasAnyEvent
                                ? AppTheme.primaryBlue
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
                                            ? AppTheme.primaryBlue
                                            : isSunday
                                            ? AppTheme.urgentRed
                                            : isSaturday
                                            ? AppTheme.primaryBlue
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
                                          color: AppTheme.primaryPurple500,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            if (hasEducation)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: hasWork ? 2 : AppTheme.spacing1,
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: 12,
                                  color: AppTheme.primaryPurple,
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
                          color: AppTheme.primaryPurple500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing1),
                      Text(
                        '근무 예정',
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
                        '근무 완료',
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
                      Icon(
                        Icons.school,
                        size: 16,
                        color: AppTheme.primaryPurple,
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
                            s.status == 'proposed' ||
                            s.status == 'completed'),
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
                                  if (isProposed) {
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
                              color: isSelected && !isScheduleChecked
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                                  : AppTheme.backgroundWhite,
                              border: Border.all(
                                color: isSelected && !isScheduleChecked
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderGray,
                                width: isSelected && !isScheduleChecked ? 2 : 1,
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
                                            '${schedule.job?.shopName ?? '매장'} 근무',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.textTertiary,
                                                ),
                                          ),
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
                                                '체크인: ${DateFormat('yyyy-MM-dd HH:mm').format(schedule.checkInTime!)}',
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
                                          isProposed
                                              ? '제안 대기'
                                              : '근무 예정',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isProposed
                                                    ? AppTheme.primaryPurple
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
                    .map(
                      (enrollment) => WorkCheckEducationCard(
                        enrollment: enrollment,
                      ),
                    ),
              ],
            ),
          ),

        // 근무체크 버튼
        if (vm.hasScheduledWork(vm.selectedDate))
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
            children: [
              // 승인 대기 상태
              if (vm.pendingApprovals.containsKey(
                DateFormat('yyyy-MM-dd').format(vm.selectedDate),
              ))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow50,
                    border: Border.all(color: AppTheme.yellow600, width: 1),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: Text(
                    '${vm.pendingApprovals[DateFormat('yyyy-MM-dd').format(vm.selectedDate)]}에서 승인 대기 중입니다...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.yellow800,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (vm.selectedScheduleId == null ||
                          vm.isChecked(vm.selectedDate) ||
                          vm.pendingApprovals.containsKey(
                            DateFormat('yyyy-MM-dd').format(vm.selectedDate),
                          ))
                      ? null
                      : vm.handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.borderGray300,
                    disabledForegroundColor: AppTheme.textSecondary,
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '근무체크하기',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      IconMapper.icon(
                            'chevronright',
                            size: 20,
                            color: Colors.white,
                          ) ??
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.white,
                          ),
                    ],
                  ),
                ),
              ),
              if (vm.selectedScheduleId != null &&
                  !vm.isChecked(vm.selectedDate))
                Builder(
                  builder: (ctx) {
                    final selected = vm.schedules.where(
                      (s) => s.id == vm.selectedScheduleId,
                    );
                    if (selected.isEmpty ||
                        selected.first.status != 'scheduled') {
                      return const SizedBox.shrink();
                    }
                    final schedule = selected.first;
                    return Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spacing3),
                      child: TextButton(
                        onPressed: () async {
                          await ScheduleCancelFlow.requestCancel(
                            context: ctx,
                            schedule: schedule,
                            actor: CancellationActor.spare,
                            onSuccess: () => vm.loadData(),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.urgentRed,
                        ),
                        child: const Text(
                          '일정 취소',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        // 근무 보너스 팁
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

        // 근무체크 안내사항
        Container(
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
                '근무체크 안내사항',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              _workCheckInfoItem(
                context,
                '근무체크는 승인받은 근무 일정에만 가능합니다. 당일 근무를 마치고 체크해주세요.',
              ),
              const SizedBox(height: AppTheme.spacing3),
              _workCheckInfoItem(
                context,
                '노쇼 없이 10일 연속 근무하면 에너지 1개를 받을 수 있습니다.',
              ),
              const SizedBox(height: AppTheme.spacing3),
              _workCheckInfoItem(context, '연속 근무가 끊기면 에너지 게이지는 초기화됩니다.'),
              const SizedBox(height: AppTheme.spacing3),
              _workCheckInfoItem(context, '연속 근무는 달이 넘어가도 이어집니다.'),
            ],
          ),
        ),

        // 하단 여백 (하단 네비게이션 바)
        SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
      ],
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
          color: AppTheme.primaryBlue,
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
