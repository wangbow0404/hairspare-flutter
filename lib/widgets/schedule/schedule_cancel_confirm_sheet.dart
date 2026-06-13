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
    return GlassModalBottomSheet(
      maxHeightFactor: 0.85,
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
                  Center(
                    child: GlassModalHeroIcon(
                      emoji: '⚠️',
                      size: 64,
                      gradientColors: const [
                        Color(0xFFFEE2E2),
                        Color(0xFFFFF7ED),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '아래 안내를 확인한 뒤 취소를 진행해 주세요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _PolicyBulletCard(actor: widget.actor),
                  if (widget.eligibility.penaltySummary != null) ...[
                    const SizedBox(height: 10),
                    _PenaltySummaryCard(
                      summary: widget.eligibility.penaltySummary!,
                      energyForfeit: widget.eligibility.energyForfeit,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    '취소할 근무',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textGray700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.schedules.map(_CancelTargetRow.new),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    child: CheckboxListTile(
                      value: _consentChecked,
                      onChanged: (v) =>
                          setState(() => _consentChecked = v ?? false),
                      title: Text(
                        ScheduleCancellationPolicy.consentCheckboxLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF6366F1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _consentChecked
                        ? () => Navigator.pop(context, true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.urgentRed,
                      disabledBackgroundColor:
                          AppTheme.borderGray.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(
                          AppTheme.radiusXl,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.schedules.length > 1
                          ? '${widget.schedules.length}건 취소하기'
                          : '취소하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('돌아가기'),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.urgentRedLight.withValues(alpha: 0.28),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppTheme.urgentRed.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                '취소·패널티 안내',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.urgentRed,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...ScheduleCancellationPolicy.policyBulletLines(actor: actor).map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textGray700,
                          height: 1.45,
                        ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textGray700,
                            height: 1.45,
                          ),
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF).withValues(alpha: 0.55),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            energyForfeit > 0 ? '예상 패널티 · ${energyForfeit}E' : '패널티 안내',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4338CA),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray700,
                  height: 1.45,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScheduleConflict.shopLabel(schedule),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateLabel · $timeLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
