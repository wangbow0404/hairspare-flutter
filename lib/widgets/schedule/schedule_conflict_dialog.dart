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
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
        if (s.status == 'proposed') {
          await service.rejectWorkProposal(s.id);
        } else {
          await service.cancelSchedule(
            s.id,
            cancelReason: '시간 겹침으로 $actionLabel 전 취소',
          );
        }
      }
      await onResolved?.call();
      if (context.mounted) {
        final hasProposal = cancellable.any((s) => s.status == 'proposed');
        messenger.showSuccess(
          hasProposal
              ? '겹치는 제안을 거절했습니다. 다시 $actionLabel 해 주세요.'
              : '겹치는 근무를 취소했습니다. 다시 $actionLabel 해 주세요.',
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

    return GlassModalBottomSheet(
      stitchStyle: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenH = MediaQuery.sizeOf(context).height;
          final sheetMax = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : screenH * 0.88;
          final scrollMaxHeight = (sheetMax - 220).clamp(120.0, screenH * 0.55);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GlassModalDragHandle(stitchStyle: true),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: scrollMaxHeight),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ConflictHeader(
                        actionLabel: actionLabel,
                        onClose: () => Navigator.pop(
                          context,
                          _ConflictChoice.dismiss,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing6),
                      _StitchConflictNotice(actionLabel: actionLabel),
                      const SizedBox(height: AppTheme.spacing8),
                      const _StitchCancellationPolicySection(),
                      const SizedBox(height: AppTheme.spacing8),
                      const Text(
                        '겹치는 근무',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.stitchTextPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      ...conflicts.map(
                        (s) => _StitchConflictScheduleCard(
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
              _ConflictFooter(
                canCancelAny: canCancelAny,
                cancellableCount: cancellable.length,
                onCancelConflicts: () => Navigator.pop(
                  context,
                  _ConflictChoice.cancelConflicts,
                ),
                onOpenSchedule: () => Navigator.pop(
                  context,
                  _ConflictChoice.openSchedule,
                ),
                onDismiss: () => Navigator.pop(
                  context,
                  _ConflictChoice.dismiss,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConflictHeader extends StatelessWidget {
  const _ConflictHeader({
    required this.actionLabel,
    required this.onClose,
  });

  final String actionLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFF0DBFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.schedule_rounded,
            size: 24,
            color: AppTheme.stitchPrimary,
          ),
        ),
        const SizedBox(width: AppTheme.spacing4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '근무 시간이 겹쳐요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextPrimary,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppTheme.spacing1),
              Text(
                '같은 날 다른 근무와 $actionLabel 시간이 겹칩니다. '
                '겹치는 근무를 확인해주세요.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(
            Icons.close_rounded,
            size: 22,
            color: AppTheme.stitchTextSecondary,
          ),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _StitchConflictNotice extends StatelessWidget {
  const _StitchConflictNotice({required this.actionLabel});

  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final noticeBody = actionLabel == '지원'
        ? '하루에 시간이 겹치는 근무는 등록할 수 없어요. '
            '기존 스케줄을 취소하거나 조정해야 이 공고에 지원할 수 있습니다.'
        : '하루에 시간이 겹치는 근무는 등록할 수 없어요. '
            '기존 스케줄을 취소하거나 조정해야 $actionLabel을(를) 진행할 수 있습니다.';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DBFF),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Text(
        noticeBody,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6800B4),
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StitchCancellationPolicySection extends StatelessWidget {
  const _StitchCancellationPolicySection();

  static const List<String> _policyLines = [
    '근무 시작 48시간 전: 위약금 없이 취소 가능',
    '근무 시작 48시간 이내: 노쇼와 동일하게 처리되어 페널티 부여',
    '제안 대기 중인 근무는 자유롭게 취소 가능',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppTheme.stitchTextSecondary,
            ),
            SizedBox(width: AppTheme.spacing2),
            Text(
              '취소 정책 안내',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing2),
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacing1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _policyLines
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacing1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.stitchTextSecondary,
                            height: 1.4,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.stitchTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _StitchChip extends StatelessWidget {
  const _StitchChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
          height: 1.2,
        ),
      ),
    );
  }
}

class _StitchConflictScheduleCard extends StatelessWidget {
  const _StitchConflictScheduleCard({
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
    var dateLabel = schedule.date;
    final parsed = DateTime.tryParse(schedule.date);
    if (parsed != null) {
      dateLabel = DateFormat('M월 d일 (E)', 'ko_KR').format(
        DateTime(parsed.year, parsed.month, parsed.day),
      );
    }
    final shop = ScheduleConflict.shopLabel(schedule);
    final isProposed = schedule.status == 'proposed';
    final canCancel = eligibility.canCancelInApp;

    final secondLabel = isProposed
        ? (canCancel ? '거절 가능' : '제안 대기')
        : eligibility.eligibilityChipLabel;
    final secondFg = isProposed
        ? (canCancel ? AppTheme.green600 : AppTheme.stitchPrimary)
        : canCancel
        ? AppTheme.green600
        : AppTheme.urgentRed;
    final secondBg = isProposed
        ? (canCancel
            ? AppTheme.green600.withValues(alpha: 0.1)
            : const Color(0xFFF0DBFF))
        : secondFg.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppTheme.spacing1,
            runSpacing: AppTheme.spacing1,
            children: [
              _StitchChip(
                label: '겹침',
                foreground: AppTheme.urgentRed,
                background: AppTheme.urgentRed.withValues(alpha: 0.1),
              ),
              _StitchChip(
                label: secondLabel,
                foreground: secondFg,
                background: secondBg,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            shop,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppTheme.spacing1),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppTheme.stitchTextSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.stitchTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              const Text(
                '·',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppTheme.stitchTextSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.stitchTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConflictFooter extends StatelessWidget {
  const _ConflictFooter({
    required this.canCancelAny,
    required this.cancellableCount,
    required this.onCancelConflicts,
    required this.onOpenSchedule,
    required this.onDismiss,
  });

  final bool canCancelAny;
  final int cancellableCount;
  final VoidCallback onCancelConflicts;
  final VoidCallback onOpenSchedule;
  final VoidCallback onDismiss;

  static const double _footerButtonHeight = 52;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: canCancelAny ? onCancelConflicts : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stitchPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.borderGray300,
                disabledForegroundColor: AppTheme.stitchTextSecondary,
                elevation: 0,
                minimumSize: const Size(double.infinity, _footerButtonHeight),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
              child: Text(
                cancellableCount > 1
                    ? '겹치는 근무 $cancellableCount건 취소 후 계속'
                    : '겹치는 근무 취소 후 계속',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: onOpenSchedule,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.backgroundWhite,
                      foregroundColor: AppTheme.stitchPrimary,
                      side: const BorderSide(color: AppTheme.stitchPrimary),
                      minimumSize: const Size(0, _footerButtonHeight),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text(
                      '스케줄표에서 확인',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.stitchTextSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, _footerButtonHeight),
                    ),
                    child: const Text(
                      '나중에 할게요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
