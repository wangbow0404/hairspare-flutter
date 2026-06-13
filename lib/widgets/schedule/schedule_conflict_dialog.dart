import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_handler.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../utils/schedule_conflict.dart';
import '../../utils/schedule_work_session.dart';
import '../common/glass_modal.dart';
import 'schedule_cancel_confirm_sheet.dart';

/// 겹치는 근무가 있을 때 취소·스케줄표 이동 안내 (바텀 시트).
abstract final class ScheduleConflictDialog {
  ScheduleConflictDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String actionLabel,
    required List<Schedule> conflicts,
    Future<void> Function()? onResolved,
  }) async {
    if (conflicts.isEmpty) return true;

    final result = await showModalBottomSheet<_ConflictChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _ScheduleConflictSheet(
        actionLabel: actionLabel,
        conflicts: conflicts,
      ),
    );

    if (result == null || result == _ConflictChoice.dismiss) {
      return false;
    }

    if (result == _ConflictChoice.openSchedule) {
      final first = conflicts.first;
      final day = DateTime.tryParse(first.date);
      if (context.mounted) {
        await NavigationHelper.navigateToWorkCheck(
          context,
          initialDay: day != null
              ? DateTime(day.year, day.month, day.day)
              : null,
          scheduleId: first.id,
          jobId: first.jobId,
        );
      }
      return false;
    }

    if (result != _ConflictChoice.cancelConflicts) {
      return false;
    }

    final cancellable = ScheduleCancellationPolicy.cancellableFrom(
      conflicts,
      context: CancellationContext.overlapResolution,
    );
    if (cancellable.isEmpty) {
      sl<GlobalMessengerService>().showError(
        ScheduleCancellationPolicy.blockedOverlapMessage(),
      );
      return false;
    }

    if (!context.mounted) return false;
    final agreed = await ScheduleCancelConfirmSheet.show(
      context: context,
      schedulesToCancel: cancellable,
      title: '겹치는 근무 취소',
    );
    if (!agreed || !context.mounted) return false;

    final messenger = sl<GlobalMessengerService>();
    final service = sl<ScheduleService>();
    try {
      for (final s in cancellable) {
        final eligibility = ScheduleCancellationPolicy.evaluate(
          s,
          context: CancellationContext.overlapResolution,
        );
        if (!eligibility.canCancelInApp) {
          throw ValidationException(
            eligibility.blockedMessage ??
                ScheduleCancellationPolicy.blockedOverlapMessage(),
            code: ScheduleCancellationPolicy.cancelBlockedCode,
          );
        }
        await service.cancelSchedule(
          s.id,
          cancelReason: '시간 겹침으로 $actionLabel 전 취소',
        );
      }
      await onResolved?.call();
      if (context.mounted) {
        messenger.showSuccess(
          '겹치는 근무를 취소했습니다. 다시 $actionLabel 해 주세요.',
        );
      }
      return true;
    } catch (e) {
      messenger.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      return false;
    }
  }
}

enum _ConflictChoice { dismiss, cancelConflicts, openSchedule }

class _ScheduleConflictSheet extends StatelessWidget {
  const _ScheduleConflictSheet({
    required this.actionLabel,
    required this.conflicts,
  });

  final String actionLabel;
  final List<Schedule> conflicts;

  @override
  Widget build(BuildContext context) {
    final cancellable = ScheduleCancellationPolicy.cancellableFrom(
      conflicts,
      context: CancellationContext.overlapResolution,
    );
    final canCancelAny = cancellable.isNotEmpty;
    final allBlocked = !canCancelAny;

    return GlassModalBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GlassModalDragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassModalHeroIcon(
                        emoji: '⏱️',
                        size: 56,
                        gradientColors: [
                          Color(0xFFFFEDD5),
                          Color(0xFFE0E7FF),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '근무 시간이 겹려요',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '같은 날 다른 근무와 $actionLabel 시간이 겹칩니다. '
                              '아래 일정을 정리한 뒤 진행할 수 있어요.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppTheme.textTertiary.withValues(alpha: 0.85),
                        ),
                        onPressed: () => Navigator.pop(
                          context,
                          _ConflictChoice.dismiss,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _OverlapHintBanner(actionLabel: actionLabel),
                  const SizedBox(height: 12),
                  const _CancellationPolicySummaryCard(),
                  if (allBlocked) ...[
                    const SizedBox(height: 12),
                    _BlockedContactBanner(),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    '겹치는 근무',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textGray700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ...conflicts.map(
                    (s) => _ConflictScheduleCard(
                      schedule: s,
                      eligibility: ScheduleCancellationPolicy.evaluate(
                        s,
                        context: CancellationContext.overlapResolution,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canCancelAny)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _ConflictChoice.cancelConflicts,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusXl,
                          ),
                        ),
                      ),
                      child: Text(
                        cancellable.length > 1
                            ? '겹치는 근무 ${cancellable.length}건 취소 후 계속'
                            : '겹치는 근무 취소 후 계속',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.42),
                      borderRadius: AppTheme.borderRadius(
                        AppTheme.radiusLg,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Text(
                      '근무 시작 시각 이후인 일정은 앱에서 취소할 수 없습니다. '
                      '매장에 문의해 주세요.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _ConflictChoice.openSchedule,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: BorderSide(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(
                          AppTheme.radiusXl,
                        ),
                      ),
                    ),
                    child: const Text(
                      '스케줄표에서 확인',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _ConflictChoice.dismiss,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    '나중에 할게요',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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

class _OverlapHintBanner extends StatelessWidget {
  const _OverlapHintBanner({required this.actionLabel});

  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.orange50.withValues(alpha: 0.55),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppTheme.orange600.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '하루에 시간이 겹치는 근무는 등록할 수 없어요. '
              '취소 가능한 기존 근무를 정리하면 $actionLabel을(를) 이어서 진행할 수 있습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.orange600,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationPolicySummaryCard extends StatelessWidget {
  const _CancellationPolicySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ScheduleCancellationPolicy.policyBulletLines(
          actor: CancellationActor.spare,
        )
            .take(3)
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '· $line',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textGray700,
                        height: 1.4,
                      ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BlockedContactBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.urgentRedLight.withValues(alpha: 0.28),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 20,
            color: AppTheme.urgentRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ScheduleCancellationPolicy.blockedOverlapMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.urgentRed.withValues(alpha: 0.95),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictScheduleCard extends StatelessWidget {
  const _ConflictScheduleCard({
    required this.schedule,
    required this.eligibility,
  });

  final Schedule schedule;
  final CancellationEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final window = ScheduleConflict.windowFromSchedule(schedule);
    final timeLabel = window == null
        ? schedule.startTime
        : '${ScheduleWorkSession.formatHm(window.start)}~'
            '${ScheduleWorkSession.formatHm(window.end)}';
    String dateLabel = schedule.date;
    final parsed = DateTime.tryParse(schedule.date);
    if (parsed != null) {
      dateLabel = DateFormat('M월 d일 (E)', 'ko_KR').format(
        DateTime(parsed.year, parsed.month, parsed.day),
      );
    }
    final shop = ScheduleConflict.shopLabel(schedule);
    final statusLabel = schedule.status == 'proposed' ? '제안 대기' : '근무 예정';
    final statusColor = schedule.status == 'proposed'
        ? AppTheme.primaryPurple
        : AppTheme.primaryBlue;
    final canCancel = eligibility.canCancelInApp;
    final cancelChipColor =
        canCancel ? AppTheme.primaryGreen : AppTheme.urgentRed;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canCancel
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.32),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: canCancel
              ? const Color(0xFF6366F1).withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.urgentRed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  '겹침',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: cancelChipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  eligibility.eligibilityChipLabel,
                  style: TextStyle(
                    color: cancelChipColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shop,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                timeLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
