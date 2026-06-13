import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/shop_tier.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/schedule_space_rental.dart';
import '../../utils/schedule_work_session.dart';
import '../../view_models/shop_schedule_view_model.dart';

/// 스케줄 탭 스크롤 본문 (히어로·등급·달력·리스트·정산 CTA·안내).
class ShopScheduleScrollContent extends StatelessWidget {
  const ShopScheduleScrollContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopScheduleViewModel>();
    final titleInfo = vm.getTierTitle();
    final daysInMonth = vm.getDaysInMonth(vm.currentMonth);
    final selectedDateSchedules = vm.getSchedulesForDate(vm.selectedDate);
    final isDateCompleted = vm.isCompleted(vm.selectedDate);
    final settlementBlockedMessage = vm.selectedSchedule != null
        ? vm.settlementBlockedMessageFor(vm.selectedSchedule!)
        : null;
    final selectedIsSpaceRental = vm.selectedSchedule != null &&
        ScheduleSpaceRental.isSpaceRental(vm.selectedSchedule!);

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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '현재 등급',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              vm.tierInfo?.currentTier.name ?? '브론즈',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

        // 등급 혜택 섹션
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
          ),
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '등급 혜택',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                vm.tierInfo?.currentTier.getNextTier() != null
                    ? '완료 스케줄 ${vm.tierInfo!.currentTier.getNextTier()!.minCompletedSchedules}개 또는 따봉 ${vm.tierInfo!.currentTier.getNextTier()!.minThumbsUp}개를 달성하면 다음 등급으로 올라가요!'
                    : '최고 등급입니다!',
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
                          '등급 진행률',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textGray700,
                          ),
                        ),
                        if (vm.tierInfo != null && vm.tierInfo!.currentTier.getNextTier() != null)
                          Text(
                            '${vm.tierInfo!.completedSchedules} / ${vm.tierInfo!.currentTier.getNextTier()!.minCompletedSchedules}개',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    // 등급 진행률 게이지
                    if (vm.tierInfo != null && vm.tierInfo!.currentTier.getNextTier() != null)
                      ClipRRect(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0F3),
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                            ),
                            child: Row(
                              children: [
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
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          if (vm.tierInfo!.progressToNextTier > 0)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: vm.tierInfo!.progressToNextTier * MediaQuery.of(context).size.width * 0.9,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(vm.tierInfo!.currentTier.colorValue),
                                      Color(vm.tierInfo!.currentTier.getNextTier()!.colorValue),
                                    ],
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                              ),
                            ),
                          if (vm.tierInfo!.progressToNextTier > 0)
                            Positioned(
                              left: vm.tierInfo!.progressToNextTier * MediaQuery.of(context).size.width * 0.9 - 32,
                              top: 0,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(vm.tierInfo!.currentTier.colorValue),
                                      Color(vm.tierInfo!.currentTier.getNextTier()!.colorValue),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    vm.tierInfo!.currentTier.getNextTier()!.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      ),
                    const SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: [
                        Text(
                          '현재 등급:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textGray700,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        Text(
                          '${vm.tierInfo?.currentTier.emoji ?? '🥉'} ${vm.tierInfo?.currentTier.name ?? '브론즈'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 스케줄 현황 - 달력
        Container(
          width: double.infinity,
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
            border: Border(
              top: BorderSide(
                color: AppTheme.borderGray,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스케줄 현황',
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
                      onTap: () => vm.goToPreviousMonth(),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing2),
                        child: IconMapper.icon('chevronleft', size: 20, color: AppTheme.textSecondary) ??
                            const Icon(Icons.chevron_left, size: 20, color: AppTheme.textSecondary),
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
                      onTap: () => vm.goToNextMonth(),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing2),
                        child: IconMapper.icon('chevronright', size: 20, color: AppTheme.textSecondary) ??
                            const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              // 요일 라벨
              Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                  final isSunday = day == 'Sun';
                  final isSaturday = day == 'Sat';
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing2),
              // 달력 그리드
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  final date = daysInMonth[index];
                  final isCurrentMonth = date.month == vm.currentMonth.month;
                  final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                      DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final hasWork = isCurrentMonth && vm.hasScheduledWork(date);
                  final isWorkCompleted = isCurrentMonth && vm.isCompleted(date);
                  final isSelectedDate = DateFormat('yyyy-MM-dd').format(date) == 
                      DateFormat('yyyy-MM-dd').format(vm.selectedDate);
                  
                  final weekday = date.weekday % 7;
                  final isSunday = weekday == 0;
                  final isSaturday = weekday == 6;

                  if (!isCurrentMonth) {
                    return const SizedBox.shrink();
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => vm.setSelectedDate(date),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday 
                              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                              : AppTheme.backgroundWhite,
                          border: Border.all(
                            color: isToday
                                ? AppTheme.primaryBlue
                                : hasWork
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderGray,
                            width: isSelectedDate && hasWork ? 2 : 1,
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        padding: const EdgeInsets.all(AppTheme.spacing1),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final side = constraints.maxWidth < constraints.maxHeight
                                ? constraints.maxWidth
                                : constraints.maxHeight;
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isToday
                                          ? AppTheme.primaryBlue
                                          : isSunday
                                              ? AppTheme.urgentRed
                                              : isSaturday
                                                  ? AppTheme.primaryBlue
                                                  : AppTheme.textGray700,
                                    ),
                                  ),
                                  if (hasWork) ...[
                                    SizedBox(height: side * 0.08),
                                    isWorkCompleted
                                        ? Icon(Icons.check_circle, size: side * 0.28, color: AppTheme.primaryBlue)
                                        : Icon(Icons.circle, size: side * 0.2, color: AppTheme.primaryPurple500),
                                  ],
                                ],
                              ),
                            );
                          },
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
                        '스케줄 예정',
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
                        child: IconMapper.icon('check', size: 10, color: Colors.white) ??
                            const Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                      const SizedBox(width: AppTheme.spacing1),
                      Text(
                        '정산 완료',
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

        // 선택된 날짜 스케줄 정보 카드
        if (vm.hasScheduledWork(vm.selectedDate))
          Container(
            width: double.infinity,
            padding: AppTheme.spacingSymmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing4,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderGray,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: vm.schedules
                  .where((s) => s.date == DateFormat('yyyy-MM-dd').format(vm.selectedDate))
                  .map((schedule) {
                final workTimeText = schedule.endTime != null
                    ? '${schedule.startTime}~${schedule.endTime}'
                    : '${schedule.startTime}~';
                final isSpaceRental = ScheduleSpaceRental.isSpaceRental(schedule);
                final isScheduleCompleted = schedule.status == 'completed';
                final scheduleStatusLabel = isSpaceRental
                    ? ScheduleSpaceRental.statusLabel(schedule, DateTime.now())
                    : isScheduleCompleted
                        ? '정산 완료'
                        : switch (ScheduleWorkSession.phase(schedule, DateTime.now())) {
                            ScheduleWorkPhase.beforeStart => '근무 예정',
                            ScheduleWorkPhase.inProgress => '근무 중',
                            ScheduleWorkPhase.afterEnd => '정산 대기',
                          };

                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isScheduleCompleted
                          ? null
                          : () => vm.handleScheduleClick(schedule),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Container(
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        decoration: BoxDecoration(
                          color: vm.selectedSchedule?.id == schedule.id && !isScheduleCompleted
                              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                              : AppTheme.backgroundWhite,
                          border: Border.all(
                            color: vm.selectedSchedule?.id == schedule.id && !isScheduleCompleted
                                ? AppTheme.primaryBlue
                                : AppTheme.borderGray,
                            width: vm.selectedSchedule?.id == schedule.id && !isScheduleCompleted ? 2 : 1,
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isSpaceRental
                                        ? ScheduleSpaceRental.displayTitle(schedule)
                                        : schedule.job?.title ?? '공고 제목 없음',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppTheme.spacing1),
                                  Text(
                                    workTimeText,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppTheme.spacing1),
                                  Text(
                                    isSpaceRental
                                        ? ScheduleSpaceRental.prepaidSummary(schedule)
                                        : '${schedule.spare?.name ?? schedule.spareId} | ${NumberFormat('#,###').format(schedule.job?.amount ?? 0)}원',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isScheduleCompleted)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconMapper.icon('check', size: 20, color: Colors.white) ??
                                    const Icon(Icons.check, size: 20, color: Colors.white),
                              )
                            else
                              Container(
                                padding: AppTheme.spacingSymmetric(
                                  horizontal: AppTheme.spacing3,
                                  vertical: AppTheme.spacing1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.purple100,
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  scheduleStatusLabel,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.purple700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // 정산 버튼 (공간 대여는 선결제·확인용 — 정산 없음)
        Container(
          width: double.infinity,
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
            border: Border(
              top: BorderSide(
                color: AppTheme.borderGray,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              if (selectedIsSpaceRental) ...[
                Text(
                  '공간 대여는 선결제 완료 후 스케줄에서 확인만 합니다.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => NavigationHelper.navigateToMessages(context),
                    child: const Text('채팅방 열기'),
                  ),
                ),
              ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (vm.selectedSchedule == null ||
                          isDateCompleted ||
                          selectedDateSchedules.isEmpty)
                      ? null
                      : () => vm.handleConfirmWork(vm.selectedSchedule!.id),
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
                        '정산하기',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      IconMapper.icon('chevronright', size: 20, color: Colors.white) ??
                          const Icon(Icons.chevron_right, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
              if (settlementBlockedMessage != null &&
                  vm.selectedSchedule != null &&
                  !selectedIsSpaceRental &&
                  !isDateCompleted) ...[
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  settlementBlockedMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.orange600,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 등급 보너스 팁
        Container(
          width: double.infinity,
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
            border: Border(
              top: BorderSide(
                color: AppTheme.borderGray,
                width: 1,
              ),
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
                            '등급 보너스 팁',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing1),
                          Text(
                            '정산을 완료하고 따봉을 보내면 등급이 올라가요!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      const Text('🏆', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Text(
                          vm.tierInfo?.currentTier.getNextTier() != null
                              ? '${vm.tierInfo!.currentTier.getNextTier()!.name} 등급까지 ${vm.tierInfo!.requiredSchedulesForNextTier ?? 0}개 완료 또는 ${vm.tierInfo!.requiredThumbsUpForNextTier ?? 0}개 따봉이 필요해요!'
                              : '최고 등급입니다! 계속 유지해보세요!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

        // 등급 안내사항
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
              top: BorderSide(
                color: AppTheme.borderGray,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '등급 안내사항',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              shopScheduleInfoItem(context, '정산은 근무 종료 시간 이후에만 가능합니다.'),
              const SizedBox(height: AppTheme.spacing3),
              shopScheduleInfoItem(context, '완료 스케줄 수 또는 받은 따봉 수가 기준을 충족하면 등급이 올라갑니다.'),
              const SizedBox(height: AppTheme.spacing3),
              shopScheduleInfoItem(context, '등급이 올라가면 공고 등록 수, 노출 우선순위 등 다양한 혜택을 받을 수 있습니다.'),
              const SizedBox(height: AppTheme.spacing3),
              shopScheduleInfoItem(context, '등급은 실시간으로 업데이트됩니다.'),
            ],
          ),
        ),

        // 하단 여백
        const SizedBox(height: 80),
      ],
    );
  }
}

Widget shopScheduleInfoItem(BuildContext context, String text) {
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
