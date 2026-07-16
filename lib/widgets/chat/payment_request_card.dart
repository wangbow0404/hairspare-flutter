import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

final _amountFormat = NumberFormat('#,###');

String _formatAmount(dynamic amount) {
  final n = amount is int ? amount : int.tryParse(amount?.toString() ?? '') ?? 0;
  return '${_amountFormat.format(n)}원';
}

/// `type == 'payment_request'` 메시지 — 결제 요청 카드.
/// [isSuperseded]가 true면(이미 수락/거절/취소된 요청) 버튼 없이 결과만 보여준다.
class PaymentRequestCard extends StatefulWidget {
  const PaymentRequestCard({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isSuperseded,
    required this.onAccept,
    required this.onDecline,
  });

  final Message message;
  final String currentUserId;
  final bool isSuperseded;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  @override
  State<PaymentRequestCard> createState() => _PaymentRequestCardState();
}

class _PaymentRequestCardState extends State<PaymentRequestCard> {
  bool _processing = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.message.payload ?? const {};
    final amount = payload['amount'];
    final purpose = payload['purpose']?.toString();
    final payerId = payload['payerId']?.toString();
    // 결제 요청을 수락/거절하는 건 돈을 내야 하는 사람(payer)이다 —
    // 요청을 보낸 사람(payee)이 자기 요청을 스스로 수락할 수는 없다.
    final isPayer = widget.currentUserId.isNotEmpty &&
        widget.currentUserId == payerId;
    final canRespond = !widget.isSuperseded && isPayer;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.stitchPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.request_quote, size: 16, color: AppTheme.stitchPrimary),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '결제 요청',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          if (purpose != null && purpose.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              purpose,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
          if (canRespond) ...[
            const SizedBox(height: AppTheme.spacing3),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _processing ? null : () => _run(widget.onDecline),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.borderGray),
                    ),
                    child: const Text('거절', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _processing ? null : () => _run(widget.onAccept),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.stitchPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: _processing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('수락', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ] else if (widget.isSuperseded) ...[
            const SizedBox(height: AppTheme.spacing1),
            const Text(
              '처리됨',
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

/// `type == 'payment_status'` 메시지 — 수락/거절/취소/완료 안내 + (해당 시) 결제하기 버튼.
class PaymentStatusBubble extends StatefulWidget {
  const PaymentStatusBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isSuperseded,
    required this.onPay,
  });

  final Message message;
  final String currentUserId;
  final bool isSuperseded;
  final Future<void> Function() onPay;

  @override
  State<PaymentStatusBubble> createState() => _PaymentStatusBubbleState();
}

class _PaymentStatusBubbleState extends State<PaymentStatusBubble> {
  bool _processing = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  ({IconData icon, String label}) _statusStyle(String status) {
    switch (status) {
      case 'accepted':
        return (icon: Icons.check_circle_outline, label: '결제 요청을 수락했습니다');
      case 'declined':
        return (icon: Icons.cancel_outlined, label: '결제 요청을 거절했습니다');
      case 'cancelled':
        return (icon: Icons.cancel_outlined, label: '결제 요청이 취소되었습니다');
      case 'paid':
        return (icon: Icons.paid_outlined, label: '결제가 완료되었습니다');
      default:
        return (icon: Icons.info_outline, label: '결제 상태가 변경되었습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.message.payload ?? const {};
    final status = payload['status']?.toString() ?? '';
    final amount = payload['amount'];
    final payerId = payload['payerId']?.toString();
    final style = _statusStyle(status);
    final canPay = !widget.isSuperseded &&
        status == 'accepted' &&
        widget.currentUserId.isNotEmpty &&
        widget.currentUserId == payerId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(style.icon, size: 14, color: AppTheme.stitchTextSecondary),
              const SizedBox(width: 6),
              Text(
                '${style.label} · ${_formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
            ],
          ),
          if (canPay) ...[
            const SizedBox(height: AppTheme.spacing2),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: _processing ? null : () => _run(widget.onPay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stitchPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('결제하기', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
