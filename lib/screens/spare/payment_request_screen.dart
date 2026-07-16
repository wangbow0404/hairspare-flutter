import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/route_extras.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

final _amountFormat = NumberFormat('#,###');

/// 채팅 결제요청 전용 결제 화면.
/// PG 연동 전까지는 "결제 완료 처리" 버튼이 즉시 Payment.status를 paid로
/// 바꾼다(실제 이체 없음) — 나중에 PG가 붙으면 [_pay] 내부만 교체하면 된다.
class PaymentRequestScreen extends StatefulWidget {
  const PaymentRequestScreen({super.key, required this.extra});

  final PaymentRequestPayExtra extra;

  @override
  State<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends State<PaymentRequestScreen> {
  bool _processing = false;

  Future<void> _pay() async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      await sl<PaymentRequestService>().payPayment(widget.extra.paymentId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final ex = ErrorHandler.handleException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ex)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = widget.extra;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '결제하기'),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing5),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${extra.counterpartyName} 님에게 결제',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '${_amountFormat.format(extra.amount)}원',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (extra.purpose != null && extra.purpose!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      extra.purpose!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _processing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stitchPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '결제 완료 처리',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
