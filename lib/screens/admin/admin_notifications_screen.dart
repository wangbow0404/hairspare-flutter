import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M16. 알림 발송·템플릿
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final AdminService _adminService = AdminService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _audience = 'all';
  List<dynamic> _templates = [];
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final r = await _adminService.getNotificationData();
      if (mounted) {
        setState(() {
          _templates = r['templates'] ?? [];
          _history = r['history'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;
    final reason = await AdminActionDialog.show(
      context,
      title: '알림 발송 확인',
      confirmLabel: '발송',
      summary: '대상: $_audience · ${_titleController.text.trim()}',
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.broadcastNotification(
        audience: _audience,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('알림이 발송되었습니다')));
      _titleController.clear();
      _bodyController.clear();
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try { return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal()); } catch (_) { return v; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '알림 발송', subtitle: '전체/역할별 푸시 발송 및 템플릿 관리'),
        const SizedBox(height: AppTheme.spacing6),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          AdminTableCard(
            padding: const EdgeInsets.all(AppTheme.spacing6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('발송', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTheme.spacing3),
                DropdownButtonFormField<String>(
                  initialValue: _audience,
                  decoration: const InputDecoration(labelText: '대상', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('전체')),
                    DropdownMenuItem(value: 'shop', child: Text('미용실')),
                    DropdownMenuItem(value: 'spare', child: Text('스페어')),
                    DropdownMenuItem(value: 'model', child: Text('모델')),
                  ],
                  onChanged: (v) => setState(() => _audience = v ?? 'all'),
                ),
                const SizedBox(height: AppTheme.spacing3),
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder())),
                const SizedBox(height: AppTheme.spacing3),
                TextField(controller: _bodyController, decoration: const InputDecoration(labelText: '본문', border: OutlineInputBorder()), maxLines: 3),
                const SizedBox(height: AppTheme.spacing4),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(onPressed: _send, child: const Text('발송')),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          AdminTableCard(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('템플릿', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._templates.map((t) {
                  final map = t as Map<String, dynamic>;
                  return ListTile(
                    title: Text(map['name']?.toString() ?? ''),
                    subtitle: Text('${map['title']} — ${map['body']}'),
                    onTap: () {
                      _titleController.text = map['title']?.toString() ?? '';
                      _bodyController.text = map['body']?.toString() ?? '';
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          AdminTableCard(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('발송 이력', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._history.map((h) {
                  final map = h as Map<String, dynamic>;
                  return ListTile(
                    title: Text(map['title']?.toString() ?? ''),
                    subtitle: Text('${map['audience']} · ${map['recipientCount']}명 · ${_formatDate(map['sentAt']?.toString())}'),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
