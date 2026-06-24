import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 관리자 mutation 확인 모달 — 사유 입력 필수 (Stitch §0.3 패턴 3)
class AdminActionDialog extends StatefulWidget {
  const AdminActionDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.summary,
    this.reasonLabel = '처리 사유 (필수)',
    this.isDanger = false,
    this.extraFields,
  });

  final String title;
  final String confirmLabel;
  final String? summary;
  final String reasonLabel;
  final bool isDanger;
  final List<Widget>? extraFields;

  /// 사유 문자열 반환. 취소 시 null.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? summary,
    String reasonLabel = '처리 사유 (필수)',
    bool isDanger = false,
    List<Widget>? extraFields,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => AdminActionDialog(
        title: title,
        confirmLabel: confirmLabel,
        summary: summary,
        reasonLabel: reasonLabel,
        isDanger: isDanger,
        extraFields: extraFields,
      ),
    );
  }

  @override
  State<AdminActionDialog> createState() => _AdminActionDialogState();
}

class _AdminActionDialogState extends State<AdminActionDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.summary != null) ...[
              Text(
                widget.summary!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
            ],
            if (widget.extraFields != null) ...widget.extraFields!,
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: widget.reasonLabel,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacing2),
            const Text(
              '변경 내역은 감사 로그에 기록됩니다.',
              style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) return;
            Navigator.pop(context, reason);
          },
          style: widget.isDanger
              ? FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
