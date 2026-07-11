import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// 관리자 → 회원 메시지(알림) 발송 시트
class AdminSendMessageSheet extends StatefulWidget {
  const AdminSendMessageSheet({
    super.key,
    required this.recipientLabel,
    this.initialTitle = '',
    this.initialBody = '',
    required this.onSend,
  });

  final String recipientLabel;
  final String initialTitle;
  final String initialBody;
  final Future<void> Function({
    required String title,
    required String body,
    required String reason,
  }) onSend;

  static Future<void> show(
    BuildContext context, {
    required String recipientLabel,
    String initialTitle = '',
    String initialBody = '',
    required Future<void> Function({
      required String title,
      required String body,
      required String reason,
    }) onSend,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminSendMessageSheet(
        recipientLabel: recipientLabel,
        initialTitle: initialTitle,
        initialBody: initialBody,
        onSend: onSend,
      ),
    );
  }

  @override
  State<AdminSendMessageSheet> createState() => _AdminSendMessageSheetState();
}

class _AdminSendMessageSheetState extends State<AdminSendMessageSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 본문을 입력해주세요')),
      );
      return;
    }

    final reason = await AdminActionDialog.show(
      context,
      title: '메시지 발송 확인',
      confirmLabel: '발송',
      summary: '${widget.recipientLabel} · $title',
    );
    if (reason == null || !mounted) return;

    setState(() => _submitting = true);
    try {
      await widget.onSend(title: title, body: body, reason: reason);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AdminStitchTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AdminStitchTheme.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AdminStitchTheme.pageMargin,
              12,
              AdminStitchTheme.pageMargin,
              24,
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
                      color: AdminStitchTheme.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('메시지 보내기', style: AdminStitchTheme.headlineMd),
                const SizedBox(height: 6),
                Text(
                  '수신: ${widget.recipientLabel}',
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '앱 알림함에 표시되며, 회원이 앱에서 확인할 수 있습니다.',
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: '본문',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('발송'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 역할별 브로드캐스트 대상 라벨
abstract final class AdminMessageAudience {
  static const options = {
    'all': '전체',
    'shop': '샵',
    'spare': '스페어',
    'designer': '디자이너',
    'model': '모델',
  };
}
