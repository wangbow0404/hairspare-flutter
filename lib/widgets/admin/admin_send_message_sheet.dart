import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import 'admin_action_dialog.dart';

/// 관리자 알림 발송 대상 (백엔드 `audience` 키와 동기화).
abstract final class AdminMessageAudience {
  AdminMessageAudience._();

  static const Map<String, String> options = {
    'all': '전체',
    'spare': '스페어',
    'designer': '디자이너',
    'model': '모델',
    'shop': '샵 사장님',
  };

  static const List<String> orderedKeys = [
    'all',
    'spare',
    'designer',
    'model',
    'shop',
  ];

  static String labelFor(String key) => options[key] ?? key;
}

/// 회원 상세 등에서 1명에게 알림(푸시)을 보낼 때 쓰는 바텀 시트.
class AdminSendMessageSheet extends StatefulWidget {
  const AdminSendMessageSheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  static Future<bool?> show(
    BuildContext context, {
    required String userId,
    required String userName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: AdminSendMessageSheet(userId: userId, userName: userName),
      ),
    );
  }

  @override
  State<AdminSendMessageSheet> createState() => _AdminSendMessageSheetState();
}

class _AdminSendMessageSheetState extends State<AdminSendMessageSheet> {
  final AdminService _adminService = AdminService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
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
      summary: '${widget.userName}에게 알림을 보냅니다.\n$title',
    );
    if (reason == null || !mounted) return;

    setState(() => _isSending = true);
    try {
      await _adminService.sendNotificationToUser(
        userId: widget.userId,
        title: title,
        body: body,
        reason: reason,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지가 발송되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          Text(
            '${widget.userName}에게 메시지',
            style: AdminStitchTheme.sectionHeader,
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '제목',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: '본문',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          FilledButton(
            onPressed: _isSending ? null : _send,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('발송'),
          ),
        ],
      ),
    );
  }
}
