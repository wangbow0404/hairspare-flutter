import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_send_message_sheet.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M16. 알림 발송·템플릿
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
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
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      return;
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림이 발송되었습니다')),
      );
      _titleController.clear();
      _bodyController.clear();
      _load();
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
    }
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try {
      return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '알림 발송',
            subtitle: '스페어·디자이너·모델·샵에게 역할별 또는 개별 메시지를 보낼 수 있습니다',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AdminStitchListStateSliver.loading();
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          AdminStitchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('발송', style: AdminStitchTheme.sectionHeader),
                const SizedBox(height: AdminStitchTheme.stackTight),
                DropdownButtonFormField<String>(
                  initialValue: _audience,
                  decoration: const InputDecoration(
                    labelText: '대상',
                    border: OutlineInputBorder(),
                  ),
                  items: AdminMessageAudience.options.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _audience = v ?? 'all'),
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
                  maxLines: 3,
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _send,
                    child: const Text('발송'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Text(
            '개별 발송은 회원 관리 → 회원 상세에서 「메시지 보내기」를 이용하세요.',
            style: AdminStitchTheme.labelSm.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Text('템플릿', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.stackTight),
          ..._templates.map((t) {
            final map = t as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminStitchTheme.sectionGap),
              child: AdminStitchSimpleListCard(
                title: map['name']?.toString() ?? '',
                subtitle: '${map['title']} — ${map['body']}',
                icon: Icons.description_outlined,
                onTap: () {
                  _titleController.text = map['title']?.toString() ?? '';
                  _bodyController.text = map['body']?.toString() ?? '';
                },
              ),
            );
          }),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Text('발송 이력', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.stackTight),
          ..._history.map((h) {
            final map = h as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminStitchTheme.sectionGap),
              child: AdminStitchSimpleListCard(
                title: map['title']?.toString() ?? '',
                subtitle:
                    '${map['audience']} · ${map['recipientCount']}명 · ${_formatDate(map['sentAt']?.toString())}',
                icon: Icons.history,
              ),
            );
          }),
        ]),
      ),
    );
  }
}
