import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/model_home_data.dart';
import '../../theme/app_theme.dart';

/// 모델 예약금(부분유료) 결제 바텀시트.
///
/// 결제가 완료되면 `true`를 반환한다. (목 데이터 — 실제 결제 연동 없음)
Future<bool?> showModelDepositCheckoutSheet(
  BuildContext context,
  ModelHomeUpcomingSchedule schedule,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModelDepositCheckoutSheet(schedule: schedule),
  );
}

class _ModelDepositCheckoutSheet extends StatefulWidget {
  const _ModelDepositCheckoutSheet({required this.schedule});

  final ModelHomeUpcomingSchedule schedule;

  @override
  State<_ModelDepositCheckoutSheet> createState() =>
      _ModelDepositCheckoutSheetState();
}

class _ModelDepositCheckoutSheetState
    extends State<_ModelDepositCheckoutSheet> {
  bool _isProcessing = false;

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    // 목 결제 처리 — 실제 PaymentService 연동은 백엔드 연동 후.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.schedule;
    final amount = NumberFormat('#,###').format(s.depositAmount);
    final date = DateFormat('M월 d일 (E) HH:mm', 'ko').format(s.dateTime);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing6,
          AppTheme.spacing4,
          AppTheme.spacing6,
          AppTheme.spacing6,
        ),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing5),
            const Text(
              '예약금 결제',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            _SummaryCard(
              shopName: s.shopName,
              treatment: s.treatment,
              date: date,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '예약금',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
                Text(
                  '$amount원',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.stitchTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppTheme.spacing4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.stitchPrimary,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        '예약금은 노쇼 방지를 위한 금액으로, 시술 완료 후 정산됩니다. '
                        '무료 시술에는 예약금이 없어요.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.stitchTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),
            ElevatedButton(
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stitchPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '$amount원 결제하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.shopName,
    required this.treatment,
    required this.date,
  });

  final String shopName;
  final String treatment;
  final String date;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shopName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$treatment · $date',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
