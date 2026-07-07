import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/schedule.dart';
import '../../theme/app_theme.dart';

/// 정산 확인 바텀시트 — 정산과 응원을 각각 독립 버튼으로 제공.
class ShopScheduleThumbsUpModal extends StatefulWidget {
  const ShopScheduleThumbsUpModal({
    super.key,
    required this.schedule,
    required this.onConfirm,
    required this.onCancel,
    this.onCancelSchedule,
  });

  final Schedule schedule;
  final ValueChanged<bool> onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<String>? onCancelSchedule;

  @override
  State<ShopScheduleThumbsUpModal> createState() =>
      _ShopScheduleThumbsUpModalState();
}

class _ShopScheduleThumbsUpModalState extends State<ShopScheduleThumbsUpModal> {
  bool _isSubmitting = false;

  int get _amount => widget.schedule.job?.amount ?? 0;

  String get _spareName => widget.schedule.spare?.name ?? '스페어';

  String get _jobTitle => widget.schedule.job?.title ?? '근무';

  String get _scheduleLabel {
    final date = DateTime.tryParse(widget.schedule.date);
    final dateText = date != null
        ? DateFormat('M월 d일 (E)', 'ko_KR').format(date)
        : widget.schedule.date;
    final end = widget.schedule.endTime;
    final timeText = end != null && end.isNotEmpty
        ? '${widget.schedule.startTime} ~ $end'
        : widget.schedule.startTime;
    return '$dateText · $timeText';
  }

  Future<void> _submit(bool giveThumbsUp) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    widget.onConfirm(giveThumbsUp);
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      child: GestureDetector(
        onTap: _isSubmitting ? null : widget.onCancel,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacing6,
                    AppTheme.spacing3,
                    AppTheme.spacing6,
                    AppTheme.spacing4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SettlementSheetHandle(),
                      const SizedBox(height: AppTheme.spacing4),
                      _SettlementSheetHeader(
                        onClose: _isSubmitting ? null : widget.onCancel,
                      ),
                      const SizedBox(height: AppTheme.spacing5),
                      _SettlementSpareSummary(
                        spareName: _spareName,
                        jobTitle: _jobTitle,
                        scheduleLabel: _scheduleLabel,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      _SettlementAmountCard(amount: _amount),
                      const SizedBox(height: AppTheme.spacing5),
                      Text(
                        '스페어 평가 (선택)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray700,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(
                        '응원은 보내지 않아도 정산할 수 있어요.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      _SettlementThumbsUpButton(
                        isSubmitting: _isSubmitting,
                        onPressed: () => _submit(true),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      _SettlementPrimaryButton(
                        isSubmitting: _isSubmitting,
                        onPressed: () => _submit(false),
                      ),
                      if (widget.onCancelSchedule != null) ...[
                        const SizedBox(height: AppTheme.spacing3),
                        _SettlementCancelScheduleButton(
                          isSubmitting: _isSubmitting,
                          onPressed: () {
                            widget.onCancelSchedule!(widget.schedule.id);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettlementSheetHandle extends StatelessWidget {
  const _SettlementSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.borderGray,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SettlementSheetHeader extends StatelessWidget {
  const _SettlementSheetHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '근무 확인 및 정산',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '근무를 확인한 뒤 정산을 진행해 주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: onClose,
          icon: const Icon(
            Icons.close_rounded,
            size: 22,
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _SettlementSpareSummary extends StatelessWidget {
  const _SettlementSpareSummary({
    required this.spareName,
    required this.jobTitle,
    required this.scheduleLabel,
  });

  final String spareName;
  final String jobTitle;
  final String scheduleLabel;

  @override
  Widget build(BuildContext context) {
    final initial = spareName.isNotEmpty ? spareName.characters.first : '?';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryPurpleLight,
            child: Text(
              initial,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spareName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jobTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scheduleLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
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

class _SettlementAmountCard extends StatelessWidget {
  const _SettlementAmountCard({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing5,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurpleLight,
            Color(0xFFEDE9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '정산 예정 금액',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${NumberFormat('#,###').format(amount)}원',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementThumbsUpButton extends StatelessWidget {
  const _SettlementThumbsUpButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryPurple,
          side: BorderSide(
            color: AppTheme.primaryPurple.withValues(alpha: 0.35),
            width: 1.5,
          ),
          backgroundColor: AppTheme.primaryPurpleLight.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👍', style: TextStyle(fontSize: 22)),
            const SizedBox(width: AppTheme.spacing2),
            Text(
              '응원 보내기',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPurpleDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementPrimaryButton extends StatelessWidget {
  const _SettlementPrimaryButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Text(
          isSubmitting ? '처리 중...' : '정산하기',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SettlementCancelScheduleButton extends StatelessWidget {
  const _SettlementCancelScheduleButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isSubmitting ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        foregroundColor: AppTheme.urgentRed,
      ),
      child: const Text(
        '스케줄 취소',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
