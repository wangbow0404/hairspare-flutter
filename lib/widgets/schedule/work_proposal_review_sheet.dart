import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/schedule_work_session.dart';
import 'schedule_conflict_dialog.dart';

/// 근무 제안 확인·수락/거절 바텀 시트.
class WorkProposalReviewSheet extends StatefulWidget {
  const WorkProposalReviewSheet({
    super.key,
    required this.schedule,
    required this.onResolved,
  });

  final Schedule schedule;
  final VoidCallback onResolved;

  static Future<void> show(
    BuildContext context, {
    required Schedule schedule,
    required VoidCallback onResolved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WorkProposalReviewSheet(
        schedule: schedule,
        onResolved: onResolved,
      ),
    );
  }

  @override
  State<WorkProposalReviewSheet> createState() =>
      _WorkProposalReviewSheetState();
}

class _WorkProposalReviewSheetState extends State<WorkProposalReviewSheet> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.schedule.job;
    final title = job?.title ?? '공고 제목 없음';
    final shop = job?.shopName ?? '매장명 없음';
    final amount = NumberFormat('#,###').format(job?.amount ?? 0);
    final date = widget.schedule.date;
    final timeLine = widget.schedule.endTime != null &&
            widget.schedule.endTime!.isNotEmpty
        ? '${widget.schedule.startTime} ~ ${widget.schedule.endTime}'
        : '${widget.schedule.startTime} ~ ${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(widget.schedule))}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '근무 제안',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$shop에서 보낸 근무 제안입니다. 내용을 확인한 뒤 수락 또는 거절해 주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(label: '공고', value: title),
              const SizedBox(height: 10),
              _InfoRow(label: '매장', value: shop),
              const SizedBox(height: 10),
              _InfoRow(label: '일정', value: '$date · $timeLine'),
              const SizedBox(height: 10),
              _InfoRow(label: '금액', value: '$amount원'),
              if (job != null && job.energy > 0) ...[
                const SizedBox(height: 10),
                _InfoRow(label: '예약금(에너지)', value: '${job.energy}개'),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => _reject(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.borderGray),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('거절'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : () => _accept(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('수락'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final service = sl<ScheduleService>();
    var conflicts =
        await service.findAcceptProposalConflicts(widget.schedule.id);
    if (!context.mounted) return;
    if (conflicts.isNotEmpty) {
      final resolved = await ScheduleConflictDialog.show(
        context: context,
        actionLabel: '제안 수락',
        conflicts: conflicts,
        onResolved: () async => widget.onResolved(),
      );
      if (!resolved || !context.mounted) return;
      conflicts =
          await service.findAcceptProposalConflicts(widget.schedule.id);
      if (conflicts.isNotEmpty) return;
    }

    setState(() => _submitting = true);
    final messenger = sl<GlobalMessengerService>();
    try {
      await service.acceptWorkProposal(widget.schedule.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      widget.onResolved();
      messenger.showSuccess('근무 제안을 수락했습니다. 스케줄표에 반영되었습니다.');
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
      messenger.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    setState(() => _submitting = true);
    final messenger = sl<GlobalMessengerService>();
    try {
      await sl<ScheduleService>().rejectWorkProposal(widget.schedule.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      widget.onResolved();
      messenger.showInfo('근무 제안을 거절했습니다.');
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
      messenger.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
