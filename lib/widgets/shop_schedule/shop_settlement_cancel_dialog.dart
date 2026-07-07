import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 정산 완료된 근무를 취소해달라고 관리자에게 요청하는 다이얼로그 — 사유 입력 필수.
class ShopSettlementCancelDialog extends StatefulWidget {
  const ShopSettlementCancelDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ShopSettlementCancelDialog(),
    );
  }

  @override
  State<ShopSettlementCancelDialog> createState() =>
      _ShopSettlementCancelDialogState();
}

class _ShopSettlementCancelDialogState
    extends State<ShopSettlementCancelDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정산취소 요청'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '실제로 근무하지 않은 것 같은 경우 등, 취소가 필요한 사유를 적어주세요.\n'
            '관리자가 확인한 뒤 처리됩니다.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacing3),
          TextField(
            controller: _reasonController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '예: 스페어가 실제로 출근하지 않았어요',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) return;
            Navigator.pop(context, reason);
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
          child: const Text('취소 요청 보내기'),
        ),
      ],
    );
  }
}
