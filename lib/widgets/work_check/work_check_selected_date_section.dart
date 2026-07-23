import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/schedule.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/region_helper.dart';
import '../../utils/schedule_work_session.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';
import 'work_check_education_card.dart';

/// 선택된 날짜의 근무·교육 정보 카드 목록.
class WorkCheckSelectedDateSection extends StatelessWidget {
  const WorkCheckSelectedDateSection({
    super.key,
    required this.vm,
    required this.isModelMode,
    required this.audience,
  });

  final WorkCheckViewModel vm;
  final bool isModelMode;
  final ScheduleSessionAudience audience;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            .map((schedule) => _SelectedScheduleCard(
                  schedule: schedule,
                  vm: vm,
                  isModelMode: isModelMode,
                  audience: audience,
                )),
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
    );
  }
}

class _SelectedScheduleCard extends StatelessWidget {
  const _SelectedScheduleCard({
    required this.schedule,
    required this.vm,
    required this.isModelMode,
    required this.audience,
  });

  final Schedule schedule;
  final WorkCheckViewModel vm;
  final bool isModelMode;
  final ScheduleSessionAudience audience;

  Future<void> _openChat(BuildContext context, Schedule schedule) async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;
    try {
      final chatId = await sl<ChatService>().ensureChatForJobApplication(
        jobId: schedule.jobId,
        jobTitle: schedule.job?.title ?? '공고',
        shopName: schedule.job?.shopName ?? '매장',
        spareId: user.id,
        spareName: user.name ?? user.username,
      );
      if (context.mounted) NavigationHelper.navigateToChat(context, chatId);
    } catch (e) {
      if (!context.mounted) return;
      final ex = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ex)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workTimeText =
        schedule.endTime != null &&
            schedule.endTime!.trim().isNotEmpty
        ? '${schedule.startTime}~${schedule.endTime}'
        : '${schedule.startTime}~${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(schedule))}';
    final isProposed = schedule.status == 'proposed';
    final isSelected = vm.selectedScheduleId == schedule.id;
    final isScheduleChecked = schedule.status == 'completed';
    final hasCheckedIn = schedule.checkInTime != null;
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
                  ? HairSpareColors.brandPrimary.withValues(alpha: 0.1)
                  : AppTheme.backgroundWhite,
              border: Border.all(
                color: isScheduleChecked
                    ? AppTheme.primaryBlue
                    : isSelected && !isScheduleChecked
                    ? HairSpareColors.brandPrimary
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
                          if (hasCheckedIn) ...[
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
                          const SizedBox(
                            height: AppTheme.spacing3,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      NavigationHelper
                                          .navigateToJobDetail(
                                    context,
                                    schedule.jobId,
                                  ),
                                  icon: const Icon(
                                    Icons.description_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('공고 상세'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color:
                                          AppTheme.borderGray,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: AppTheme.spacing2,
                              ),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openChat(
                                    context,
                                    schedule,
                                  ),
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                  ),
                                  label: const Text('채팅하기'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color:
                                          AppTheme.borderGray,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                    else if (hasCheckedIn)
                      Container(
                        padding: AppTheme.spacingSymmetric(
                          horizontal: AppTheme.spacing3,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue
                              .withValues(alpha: 0.12),
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          '체크인 완료',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryBlue,
                              ),
                        ),
                      )
                    else
                      Container(
                        padding: AppTheme.spacingSymmetric(
                          horizontal: AppTheme.spacing3,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: HairSpareColors.brandPrimarySoft,
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
                                    ? HairSpareColors.brandPrimary
                                    : HairSpareColors.brandPrimary,
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
  }
}
