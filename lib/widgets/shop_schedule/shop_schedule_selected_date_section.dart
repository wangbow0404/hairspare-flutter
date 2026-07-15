import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/schedule.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/region_helper.dart';
import '../../utils/schedule_space_rental.dart';
import '../../utils/schedule_work_session.dart';
import '../../utils/shell_navigation.dart';
import '../../view_models/shop_schedule_view_model.dart';
import 'shop_settlement_cancel_dialog.dart';
import 'shop_no_show_report_dialog.dart';

/// 샵 스케줄 — 선택된 날짜의 근무·공간대여 정보 카드.
class ShopScheduleSelectedDateSection extends StatelessWidget {
  const ShopScheduleSelectedDateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopScheduleViewModel>();
    final dateStr = DateFormat('yyyy-MM-dd').format(vm.selectedDate);
    final daySchedules = vm.schedules
        .where(
          (s) =>
              s.date == dateStr &&
              (s.status == 'scheduled' || s.status == 'completed'),
        )
        .toList();

    if (daySchedules.isEmpty) return const SizedBox.shrink();

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
        children: daySchedules
            .map(
              (schedule) => _ShopSelectedScheduleCard(
                schedule: schedule,
                isSelected: vm.selectedSchedule?.id == schedule.id,
                onSelect: () => vm.handleScheduleClick(schedule),
                onSettlementCancel: () async {
                  final reason = await ShopSettlementCancelDialog.show(context);
                  if (reason == null || reason.isEmpty) return;
                  await vm.requestSettlementCancel(schedule.id, reason);
                },
                onReportNoShow: () async {
                  final reason = await ShopNoShowReportDialog.show(context);
                  if (reason == null || reason.isEmpty) return;
                  await vm.reportNoShow(schedule.id, reason);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ShopSelectedScheduleCard extends StatelessWidget {
  const _ShopSelectedScheduleCard({
    required this.schedule,
    required this.isSelected,
    required this.onSelect,
    required this.onSettlementCancel,
    required this.onReportNoShow,
  });

  final Schedule schedule;
  final bool isSelected;
  final VoidCallback onSelect;
  final Future<void> Function() onSettlementCancel;
  final Future<void> Function() onReportNoShow;

  Future<void> _openChat(BuildContext context) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    try {
      final chatId = await sl<ChatService>().ensureChatForJobApplication(
        jobId: schedule.jobId,
        jobTitle: schedule.job?.title ?? '공고',
        shopName: user.name ?? user.username,
        spareId: schedule.spareId,
        spareName: schedule.spare?.name ?? '스페어',
      );
      if (context.mounted) {
        NavigationHelper.navigateToChat(context, chatId, audience: 'shop');
      }
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
    final isSpaceRental = ScheduleSpaceRental.isSpaceRental(schedule);
    final isScheduleCompleted = schedule.status == 'completed';
    final isScheduleCancelled = schedule.status == 'cancelled';
    final hasCheckedIn = schedule.checkInTime != null;
    final workTimeText = schedule.endTime != null && schedule.endTime!.isNotEmpty
        ? '${schedule.startTime}~${schedule.endTime}'
        : '${schedule.startTime}~${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(schedule))}';
    final spareName = schedule.spare?.name ?? schedule.spareId;
    final jobTitle = schedule.job?.title ?? '공고 제목 없음';
    final amount = NumberFormat('#,###').format(schedule.job?.amount ?? 0);
    final scheduleStatusLabel = isSpaceRental
        ? ScheduleSpaceRental.statusLabel(schedule, DateTime.now())
        : isScheduleCompleted
            ? '정산 완료'
            : isScheduleCancelled
                ? '취소됨'
                : switch (ScheduleWorkSession.phase(schedule, DateTime.now())) {
                    ScheduleWorkPhase.beforeStart => '근무 예정',
                    ScheduleWorkPhase.inProgress => '근무 중',
                    ScheduleWorkPhase.afterEnd => '정산 대기',
                  };
    final isNoShowReportable =
        !isSpaceRental && ScheduleWorkSession.isNoShowReportable(schedule);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isScheduleCancelled
              ? null
              : isScheduleCompleted
                  ? onSettlementCancel
                  : onSelect,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: isScheduleCompleted
                  ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                  : isSelected && !isScheduleCompleted
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : AppTheme.backgroundWhite,
              border: Border.all(
                color: isScheduleCompleted
                    ? AppTheme.primaryBlue
                    : isSelected && !isScheduleCompleted
                        ? AppTheme.primaryBlue
                        : AppTheme.borderGray,
                width: isScheduleCompleted || (isSelected && !isScheduleCompleted)
                    ? 2
                    : 1,
              ),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSpaceRental
                            ? ScheduleSpaceRental.displayTitle(schedule)
                            : spareName,
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
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      if (isSpaceRental) ...[
                        Text(
                          ScheduleSpaceRental.bookerLine(schedule),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing1),
                        Text(
                          ScheduleSpaceRental.prepaidSummary(schedule),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        Text(
                          '$jobTitle | $amount원',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (schedule.job?.regionId != null &&
                            schedule.job!.regionId.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing1 / 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  RegionHelper.getRegionName(schedule.job!.regionId),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      if (hasCheckedIn) ...[
                        const SizedBox(height: AppTheme.spacing3),
                        Container(
                          padding: const EdgeInsets.only(top: AppTheme.spacing3),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppTheme.borderGray, width: 1),
                            ),
                          ),
                          child: Text(
                            '체크인: ${DateFormat('yyyy-MM-dd HH:mm').format(schedule.checkInTime!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacing3),
                      Row(
                        children: [
                          if (!isSpaceRental) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => ShellNavigation.pushShopSpareDetail(
                                  context,
                                  schedule.spareId,
                                  jobId: schedule.jobId,
                                ),
                                icon: const Icon(Icons.person_outline, size: 16),
                                label: const Text('스페어상세'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  side: const BorderSide(color: AppTheme.borderGray),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                          ],
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSpaceRental
                                  ? () => _openSpaceBookingChat(context, schedule)
                                  : () => _openChat(context),
                              icon: const Icon(Icons.chat_bubble_outline, size: 16),
                              label: const Text('채팅하기'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                side: const BorderSide(color: AppTheme.borderGray),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isNoShowReportable) ...[
                        const SizedBox(height: AppTheme.spacing2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: onReportNoShow,
                            child: Text(
                              '노쇼 신고',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.urgentRed,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
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
                else if (hasCheckedIn)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '체크인 완료',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
  }

  static Future<void> _openSpaceBookingChat(
    BuildContext context,
    Schedule schedule,
  ) async {
    final chatService = sl<ChatService>();
    final chatId = await chatService.findChatIdForSpaceSchedule(schedule);
    if (!context.mounted) return;
    if (chatId != null && chatId.isNotEmpty) {
      NavigationHelper.navigateToChat(context, chatId, audience: 'shop');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${ScheduleSpaceRental.bookerName(schedule)}님과의 채팅방을 찾을 수 없습니다. '
          '메시지 목록에서 확인해 주세요.',
        ),
        backgroundColor: AppTheme.urgentRed,
      ),
    );
    NavigationHelper.navigateToMessages(context);
  }
}
