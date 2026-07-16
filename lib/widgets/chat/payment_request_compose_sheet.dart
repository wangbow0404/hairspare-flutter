import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';

const _purposeOptions = ['모델페이', '시술·재료비', '기타'];

/// 모델↔디자이너 채팅에서 결제 요청을 작성하는 바텀시트.
/// "결제 요청"은 곧 "나에게 지불해주세요"라는 뜻이라 결제자는 항상 상대방이다.
/// 성공 시 true를 반환한다(호출부에서 메시지 목록을 바로 재조회하도록).
Future<bool?> showPaymentRequestComposeSheet(
  BuildContext context, {
  required String chatId,
  required String otherUserName,
  required String otherUserId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.backgroundWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _PaymentRequestComposeSheet(
      chatId: chatId,
      otherUserName: otherUserName,
      otherUserId: otherUserId,
    ),
  );
}

class _PaymentRequestComposeSheet extends StatefulWidget {
  const _PaymentRequestComposeSheet({
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  final String chatId;
  final String otherUserName;
  final String otherUserId;

  @override
  State<_PaymentRequestComposeSheet> createState() =>
      _PaymentRequestComposeSheetState();
}

class _PaymentRequestComposeSheetState
    extends State<_PaymentRequestComposeSheet> {
  final _amountController = TextEditingController();
  final _customPurposeController = TextEditingController();
  String _purpose = _purposeOptions.first;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _customPurposeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 올바르게 입력해주세요')),
      );
      return;
    }
    final purpose =
        _purpose == '기타' ? _customPurposeController.text.trim() : _purpose;

    setState(() => _submitting = true);
    try {
      await sl<PaymentRequestService>().createPaymentRequest(
        chatId: widget.chatId,
        amount: amount,
        purpose: purpose.isEmpty ? null : purpose,
        payerId: widget.otherUserId,
      );
      if (mounted) Navigator.pop(context, true);
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '결제 요청',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.otherUserName} 님에게 합의한 금액의 결제를 요청해요.',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: '금액 (원)',
              filled: true,
              fillColor: AppTheme.backgroundGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '용도',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _purposeOptions.map((option) {
              final selected = _purpose == option;
              return ChoiceChip(
                label: Text(option),
                selected: selected,
                onSelected: (_) => setState(() => _purpose = option),
                selectedColor: AppTheme.stitchPrimary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected
                      ? AppTheme.stitchPrimary
                      : AppTheme.textSecondary,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color:
                      selected ? AppTheme.stitchPrimary : AppTheme.borderGray,
                ),
              );
            }).toList(),
          ),
          if (_purpose == '기타') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customPurposeController,
              decoration: InputDecoration(
                hintText: '용도를 입력해주세요',
                filled: true,
                fillColor: AppTheme.backgroundGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stitchPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '결제 요청 보내기',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
