import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/schedule_work_session.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';
import 'work_check_action_bar.dart';
import 'work_check_calendar_section.dart';
import 'work_check_hero_banner.dart';
import 'work_check_info_sections.dart';
import 'work_check_reward_sections.dart';
import 'work_check_selected_date_section.dart';

/// 스페어 근무체크 / 모델 시술 일정 스크롤 본문.
class WorkCheckScrollContent extends StatelessWidget {
  const WorkCheckScrollContent({
    super.key,
    this.isModelMode = false,
    this.selectedDateSectionKey,
  });

  final bool isModelMode;

  /// 선택된 날짜 근무 카드 섹션에 부착할 key (탭 시 스크롤 위치 추적용).
  final Key? selectedDateSectionKey;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkCheckViewModel>();
    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
    final titleInfo = isModelMode
        ? vm.getModelScheduleTitle()
        : vm.getWorkCheckTitle(vm.consecutiveDays);
    final displayDays = vm.consecutiveDays % 10;
    final upcomingCount = vm.upcomingScheduleCount;

    final now = DateTime.now();
    final uncheckedSchedules = vm.schedules
        .where(
          (s) =>
              s.status == 'scheduled' &&
              s.checkInTime == null &&
              ScheduleWorkSession.phase(s, now) == ScheduleWorkPhase.afterEnd,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        // Hero Banner
        WorkCheckHeroBanner(
          isModelMode: isModelMode,
          titleInfo: titleInfo,
          audience: audience,
          displayDays: displayDays,
        ),

        if (uncheckedSchedules.isNotEmpty)
          WorkCheckUncheckedBanner(
            audience: audience,
            count: uncheckedSchedules.length,
            onTap: () => vm.focusSchedule(uncheckedSchedules.first),
          ),

        if (isModelMode)
          WorkCheckModelScheduleSummary(upcomingCount: upcomingCount),

        // 근무/시술 현황 - 달력
        WorkCheckCalendarSection(
          vm: vm,
          audience: audience,
          isModelMode: isModelMode,
        ),

        // 선택된 날짜 근무·교육 정보 카드
        if (vm.hasScheduledWork(vm.selectedDate) ||
            vm.hasEducationOnDate(vm.selectedDate))
          WorkCheckSelectedDateSection(
            key: selectedDateSectionKey,
            vm: vm,
            isModelMode: isModelMode,
            audience: audience,
          ),

        WorkCheckActionBar(isModelMode: isModelMode),

        if (isModelMode) WorkCheckModelTipSection(audience: audience),

        WorkCheckScheduleInfoSection(
          title: audience.infoSectionTitle,
          lines: audience.infoBulletLines,
        ),

        // 하단 여백 (하단 네비게이션 바)
        SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
      ],
    );
  }
}
