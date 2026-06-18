import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/model_home_data.dart';
import '../../theme/app_theme.dart';
import 'model_deposit_checkout_sheet.dart';

/// 모델 홈 — 다가오는 시술 일정.
///
/// 시술은 **무료 / 부분유료(예약금)** 두 경로로 나뉘며, 부분유료 미결제 건은
/// 카드에서 바로 예약금을 결제할 수 있다.
class ModelHomeUpcomingScheduleSection extends StatefulWidget {
  const ModelHomeUpcomingScheduleSection({
    super.key,
    required this.schedules,
  });

  final List<ModelHomeUpcomingSchedule> schedules;

  @override
  State<ModelHomeUpcomingScheduleSection> createState() =>
      _ModelHomeUpcomingScheduleSectionState();
}

class _ModelHomeUpcomingScheduleSectionState
    extends State<ModelHomeUpcomingScheduleSection> {
  late List<ModelHomeUpcomingSchedule> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = List.of(widget.schedules);
  }

  Future<void> _payDeposit(ModelHomeUpcomingSchedule schedule) async {
    final paid = await showModelDepositCheckoutSheet(context, schedule);
    if (paid != true || !mounted) return;
    setState(() {
      final i = _schedules.indexWhere((s) => s.id == schedule.id);
      if (i != -1) _schedules[i] = _schedules[i].copyWith(depositPaid: true);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예약금 결제가 완료되었어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '다가오는 시술 일정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          if (_schedules.isEmpty)
            const _ScheduleEmpty()
          else
            ..._schedules.map(
              (schedule) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                child: _ScheduleCard(
                  schedule: schedule,
                  onPayDeposit: () => _payDeposit(schedule),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleEmpty extends StatelessWidget {
  const _ScheduleEmpty();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppTheme.spacing5),
        child: Center(
          child: Text(
            '예정된 시술이 없어요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onPayDeposit,
  });

  final ModelHomeUpcomingSchedule schedule;
  final VoidCallback onPayDeposit;

  @override
  Widget build(BuildContext context) {
    final isDeposit = schedule.paymentType == ModelTreatmentPayment.deposit;
    final dateLabel =
        DateFormat('M/d HH:mm').format(schedule.dateTime);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeBand(isDeposit: isDeposit),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.shopName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stitchTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${schedule.treatment} · $dateLabel',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.stitchTextSecondary,
                    ),
                  ),
                  if (isDeposit) ...[
                    const SizedBox(height: AppTheme.spacing3),
                    _DepositRow(
                      schedule: schedule,
                      onPayDeposit: onPayDeposit,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBand extends StatelessWidget {
  const _TypeBand({required this.isDeposit});

  final bool isDeposit;

  @override
  Widget build(BuildContext context) {
    final color =
        isDeposit ? AppTheme.primaryPurpleLight : AppTheme.surfaceContainerLow;
    final fg =
        isDeposit ? AppTheme.stitchPrimary : AppTheme.stitchTextSecondary;
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: Row(
        children: [
          Icon(
            isDeposit ? Icons.payments_outlined : Icons.volunteer_activism,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            isDeposit ? '예약금 시술' : '무료 시술',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositRow extends StatelessWidget {
  const _DepositRow({
    required this.schedule,
    required this.onPayDeposit,
  });

  final ModelHomeUpcomingSchedule schedule;
  final VoidCallback onPayDeposit;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat('#,###').format(schedule.depositAmount);

    if (schedule.depositPaid) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: AppTheme.green600,
          ),
          const SizedBox(width: 6),
          Text(
            '예약금 $amount원 결제 완료',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.green600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            '예약금 $amount원 (미결제)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing2),
        ElevatedButton(
          onPressed: onPayDeposit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.stitchPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
          child: const Text(
            '예약금 결제하기',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
