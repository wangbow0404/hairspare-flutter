import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 출근 시각이 지났는데 체크인이 없는 스페어를 노쇼로 신고하는 다이얼로그 — 사유 입력 필수.
class ShopNoShowReportDialog extends StatefulWidget {
  const ShopNoShowReportDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ShopNoShowReportDialog(),
    );
  }

  @override
  State<ShopNoShowReportDialog> createState() =>
      _ShopNoShowReportDialogState();
}

class _ShopNoShowReportDialogState extends State<ShopNoShowReportDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('노쇼 신고'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '신고 접수 즉시 이 스케줄은 취소되어 바로 재모집할 수 있어요.\n'
            '관리자 확인 후 노쇼로 확정됩니다.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacing3),
          TextField(
            controller: _reasonController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '예: 출근 시간이 한참 지났는데 연락도 안 되고 오지 않았어요',
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
          child: const Text('노쇼 신고하기'),
        ),
      ],
    );
  }
}
