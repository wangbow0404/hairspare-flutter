import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../utils/schedule_conflict.dart';
import '../../utils/schedule_work_session.dart';
import '../common/glass_modal.dart';

/// 취소·패널티 안내 확인 후 진행 (2단계).
abstract final class ScheduleCancelConfirmSheet {
  ScheduleCancelConfirmSheet._();

  /// 사용자가 확인 체크 후 취소 진행에 동의하면 `true`.
  static Future<bool> show({
    required BuildContext context,
    required List<Schedule> schedulesToCancel,
    String? title,
    CancellationActor actor = CancellationActor.spare,
    CancellationEligibility? eligibility,
  }) async {
    if (schedulesToCancel.isEmpty) return false;

    final resolvedEligibility = eligibility ??
        ScheduleCancellationPolicy.evaluate(
          schedulesToCancel.first,
          actor: actor,
        );

    final agreed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _ScheduleCancelConfirmBody(
        schedules: schedulesToCancel,
        title: title ?? '근무 취소 확인',
        actor: actor,
        eligibility: resolvedEligibility,
      ),
    );

    return agreed == true;
  }
}

class _ScheduleCancelConfirmBody extends StatefulWidget {
  const _ScheduleCancelConfirmBody({
    required this.schedules,
    required this.title,
    required this.actor,
    required this.eligibility,
  });

  final List<Schedule> schedules;
  final String title;
  final CancellationActor actor;
  final CancellationEligibility eligibility;

  @override
  State<_ScheduleCancelConfirmBody> createState() =>
      _ScheduleCancelConfirmBodyState();
}

class _ScheduleCancelConfirmBodyState extends State<_ScheduleCancelConfirmBody> {
  bool _consentChecked = false;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return GlassModalBottomSheet(
      stitchStyle: true,
      maxHeightFactor: 0.88,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: GlassModalDragHandle(stitchStyle: true),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.orange50,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.orange100),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 22,
                            color: AppTheme.orange600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.stitchTextPrimary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '아래 안내를 확인한 뒤 취소를 진행해 주세요.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.stitchTextSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _PolicyBulletCard(actor: widget.actor),
                    if (widget.eligibility.penaltySummary != null) ...[
                      const SizedBox(height: 10),
                      _PenaltySummaryCard(
                        summary: widget.eligibility.penaltySummary!,
                        energyForfeit: widget.eligibility.energyForfeit,
                      ),
                    ],
                    const SizedBox(height: 12),
                    ...widget.schedules.map(_CancelTargetRow.new),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ConsentCheckboxRow(
                    checked: _consentChecked,
                    onChanged: (v) =>
                        setState(() => _consentChecked = v ?? false),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _consentChecked
                        ? () => Navigator.pop(context, true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.urgentRed,
                      disabledBackgroundColor: AppTheme.borderGray300,
                      disabledForegroundColor: AppTheme.stitchTextSecondary,
                      foregroundColor: Colors.white,
                      elevation: _consentChecked ? 1 : 0,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: Text(
                      widget.schedules.length > 1
                          ? '${widget.schedules.length}건 취소하기'
                          : '취소하기',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.stitchPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '돌아가기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyBulletCard extends StatelessWidget {
  const _PolicyBulletCard({required this.actor});

  final CancellationActor actor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.red50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.red200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppTheme.red600,
              ),
              SizedBox(width: 6),
              Text(
                '취소·패널티 안내',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.red600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...ScheduleCancellationPolicy.policyBulletLines(actor: actor).map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '• $line',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltySummaryCard extends StatelessWidget {
  const _PenaltySummaryCard({
    required this.summary,
    required this.energyForfeit,
  });

  final String summary;
  final int energyForfeit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.orange50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.orange100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.orange600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  energyForfeit > 0
                      ? '예상 패널티 · ${energyForfeit}E'
                      : '패널티 안내',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.orange600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.stitchTextPrimary,
                    height: 1.4,
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

class _CancelTargetRow extends StatelessWidget {
  const _CancelTargetRow(this.schedule);

  final Schedule schedule;

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight,
        border: Border.all(
          color: AppTheme.stitchPrimary.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 18,
              color: AppTheme.stitchPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '취소할 근무',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ScheduleConflict.shopLabel(schedule),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stitchTextPrimary,
                    height: 1.25,
                  ),
                ),
                Text(
                  '$dateLabel · $timeLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.stitchTextSecondary,
                    height: 1.35,
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

class _ConsentCheckboxRow extends StatelessWidget {
  const _ConsentCheckboxRow({
    required this.checked,
    required this.onChanged,
  });

  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? AppTheme.red50 : AppTheme.backgroundGray,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: checked ? AppTheme.red200 : AppTheme.borderGray,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: checked,
                  onChanged: onChanged,
                  activeColor: AppTheme.urgentRed,
                  side: const BorderSide(
                    color: AppTheme.borderGray300,
                    width: 1.5,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ScheduleCancellationPolicy.consentCheckboxLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: checked
                        ? AppTheme.stitchTextPrimary
                        : AppTheme.stitchTextSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
