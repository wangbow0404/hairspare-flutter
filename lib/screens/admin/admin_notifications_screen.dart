import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_notification_template_editor.dart';
import '../../widgets/admin/admin_send_message_sheet.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M16. 알림 발송·템플릿·발송 이력
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  static const _titleMaxLength = 50;
  static const _bodyMaxLength = 1000;

  final AdminService _adminService = AdminService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  int _selectedTabIndex = 0;
  String _audience = 'all';
  List<dynamic> _templates = [];
  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _bodyController.addListener(_onFormChanged);
    _load();
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onFormChanged)
      ..dispose();
    _bodyController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 본문을 입력해주세요')),
      );
      return;
    }

    final audienceLabel = AdminMessageAudience.labelFor(_audience);
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '알림 발송 확인',
      message:
          '대상: $audienceLabel\n${_titleController.text.trim()}\n\n${_bodyController.text.trim()}',
      confirmLabel: '발송하기',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSending = true);
    try {
      await _adminService.broadcastNotification(
        audience: _audience,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        reason: '관리자 공지 발송',
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
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _applyTemplate(Map<String, dynamic> template) {
    _titleController.text = template['title']?.toString() ?? '';
    _bodyController.text = template['body']?.toString() ?? '';
    setState(() => _selectedTabIndex = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${template['name']?.toString() ?? '템플릿'}을(를) 불러왔습니다',
        ),
      ),
    );
  }

  Future<void> _showTemplatePicker() async {
    if (_templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록된 템플릿이 없습니다')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AdminStitchTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminStitchTheme.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
              child: Text('템플릿 불러오기', style: AdminStitchTheme.sectionHeader),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  0,
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.pageMargin,
                ),
                itemCount: _templates.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminStitchTheme.stackTight),
                itemBuilder: (context, index) {
                  final map =
                      Map<String, dynamic>.from(_templates[index] as Map);
                  return AdminStitchSimpleListCard(
                    title: map['name']?.toString() ?? '',
                    subtitle: map['title']?.toString() ?? '',
                    icon: Icons.library_books_outlined,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _applyTemplate(map);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTemplateEditor({Map<String, dynamic>? template}) async {
    final saved = await AdminNotificationTemplateEditor.show(
      context,
      template: template,
      onSave: ({required name, required title, required body}) async {
        if (template == null) {
          await _adminService.createNotificationTemplate(
            name: name,
            title: title,
            body: body,
          );
        } else {
          await _adminService.updateNotificationTemplate(
            templateId: template['id']?.toString() ?? '',
            name: name,
            title: title,
            body: body,
          );
        }
      },
      onDelete: template == null
          ? null
          : () => _adminService.deleteNotificationTemplate(
                template['id']?.toString() ?? '',
              ),
    );
    if (saved == true && mounted) {
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(template == null ? '템플릿이 추가되었습니다' : '템플릿이 저장되었습니다'),
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
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminStitchPageHeader(
            title: '알림 발송',
            subtitle: '역할별 전체 공지를 보냅니다. 개별 연락은 회원 상세의 채팅을 이용하세요.',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSegmentedTabBar(
            tabs: const ['발송', '템플릿', '발송 이력'],
            selectedIndex: _selectedTabIndex,
            onSelected: (index) => setState(() => _selectedTabIndex = index),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
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
          switch (_selectedTabIndex) {
            0 => _buildComposeTab(context),
            1 => _buildTemplatesTab(),
            _ => _buildHistoryTab(),
          },
        ]),
      ),
    );
  }

  Widget _buildComposeTab(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminStitchCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '발송 대상',
                style: AdminStitchTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AdminStitchTheme.stackTight),
              Wrap(
                spacing: AdminStitchTheme.stackTight,
                runSpacing: AdminStitchTheme.stackTight,
                children: [
                  for (final key in AdminMessageAudience.orderedKeys)
                    AdminStitchFilterChip(
                      label: AdminMessageAudience.labelFor(key),
                      selected: _audience == key,
                      onTap: () => setState(() => _audience = key),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: AdminStitchTheme.borderDefault),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    '메시지 내용',
                    style: AdminStitchTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showTemplatePicker,
                    icon: const Icon(Icons.library_add_outlined, size: 18),
                    label: const Text('템플릿 불러오기'),
                    style: TextButton.styleFrom(
                      foregroundColor: AdminStitchTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminStitchTheme.sectionGap),
              _CounterTextField(
                controller: _titleController,
                hint: '제목을 입력하세요 (최대 $_titleMaxLength자)',
                maxLength: _titleMaxLength,
                minLines: 1,
                maxLines: 1,
                fixedHeight: AdminStitchTheme.buttonHeight,
              ),
              const SizedBox(height: AdminStitchTheme.sectionGap),
              _CounterTextField(
                controller: _bodyController,
                hint:
                    '본문 내용을 입력하세요. 변수 사용 시 {이름} 형태로 입력 가능합니다.',
                maxLength: _bodyMaxLength,
                minLines: 6,
                maxLines: 12,
              ),
              const SizedBox(height: AdminStitchTheme.sectionGap),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: isWide ? null : double.infinity,
                  height: AdminStitchTheme.buttonHeight,
                  child: FilledButton(
                    onPressed: _isSending ? null : _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: AdminStitchTheme.primary,
                      foregroundColor: AdminStitchTheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AdminStitchTheme.radiusXl),
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AdminStitchTheme.onPrimary,
                            ),
                          )
                        : Text(
                            '발송하기',
                            style: AdminStitchTheme.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AdminStitchTheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        const AdminStitchInfoNote(
          message:
              '개별 연락은 회원 관리 → 회원 상세에서 「채팅하기」로 1:1 채팅방을 열어 진행할 수 있습니다.',
          boldSpans: ['회원 관리 → 회원 상세'],
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '전체 공지 템플릿',
                style: AdminStitchTheme.sectionHeader,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openTemplateEditor(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('추가'),
              style: FilledButton.styleFrom(
                backgroundColor: AdminStitchTheme.primary,
                foregroundColor: AdminStitchTheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminStitchTheme.stackTight),
        const AdminStitchInfoNote(
          message:
              '템플릿은 역할별 전체 공지 발송용입니다. 회원 1명에게 보낼 메시지는 회원 관리 → 회원 상세의 「채팅하기」를 사용하세요.',
          boldSpans: ['회원 관리 → 회원 상세'],
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        if (_templates.isEmpty)
          const AdminStitchInfoNote(
            message: '등록된 템플릿이 없습니다. 「추가」로 전체 공지용 메시지를 만들어 보세요.',
          )
        else
          for (final t in _templates) ...[
            Builder(
              builder: (context) {
                final map = Map<String, dynamic>.from(t as Map);
                return AdminStitchCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AdminStitchTheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: AdminStitchTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  map['name']?.toString() ?? '',
                                  style: AdminStitchTheme.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  map['title']?.toString() ?? '',
                                  style: AdminStitchTheme.bodyMd.copyWith(
                                    color: AdminStitchTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  map['body']?.toString() ?? '',
                                  style: AdminStitchTheme.bodyMd.copyWith(
                                    color: AdminStitchTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AdminStitchTheme.sectionGap),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _applyTemplate(map),
                            icon: const Icon(Icons.send_outlined, size: 18),
                            label: const Text('발송 탭에 불러오기'),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: '수정',
                            onPressed: () => _openTemplateEditor(template: map),
                            icon: const Icon(Icons.edit_outlined),
                            color: AdminStitchTheme.textSecondary,
                          ),
                          IconButton(
                            tooltip: '삭제',
                            onPressed: () => _confirmDeleteTemplate(map),
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.urgentRed,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AdminStitchTheme.sectionGap),
          ],
      ],
    );
  }

  Future<void> _confirmDeleteTemplate(Map<String, dynamic> template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('템플릿 삭제'),
        content: Text('「${template['name']}」 템플릿을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _adminService.deleteNotificationTemplate(
        template['id']?.toString() ?? '',
      );
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('템플릿이 삭제되었습니다')),
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
    }
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const AdminStitchInfoNote(
        message: '아직 발송 이력이 없습니다.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final h in _history) ...[
          Builder(
            builder: (context) {
              final map = Map<String, dynamic>.from(h as Map);
              final audience = AdminMessageAudience.labelFor(
                map['audience']?.toString() ?? '',
              );
              return AdminStitchSimpleListCard(
                title: map['title']?.toString() ?? '',
                subtitle:
                    '$audience · ${map['recipientCount']}명 · ${_formatDate(map['sentAt']?.toString())}',
                icon: Icons.history,
              );
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ],
    );
  }
}

class _CounterTextField extends StatelessWidget {
  const _CounterTextField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    required this.minLines,
    required this.maxLines,
    this.fixedHeight,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final double? fixedHeight;

  @override
  Widget build(BuildContext context) {
    final count = controller.text.characters.length;

    final field = TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          null,
      style: AdminStitchTheme.bodyMd,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AdminStitchTheme.bodyMd.copyWith(
          color: AdminStitchTheme.textSecondary,
        ),
        filled: true,
        fillColor: AdminStitchTheme.surfaceCard,
        contentPadding: EdgeInsets.fromLTRB(
          AdminStitchTheme.componentPadding,
          AdminStitchTheme.componentPadding,
          AdminStitchTheme.componentPadding,
          maxLines > 1 ? 36 : AdminStitchTheme.componentPadding,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
          borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
          borderSide: const BorderSide(color: AdminStitchTheme.primary),
        ),
      ),
    );

    return Stack(
      children: [
        if (fixedHeight != null)
          SizedBox(height: fixedHeight, child: field)
        else
          field,
        Positioned(
          right: AdminStitchTheme.componentPadding,
          top: fixedHeight != null ? 0 : null,
          bottom: fixedHeight != null ? 0 : 12,
          child: Center(
            child: Text(
              '$count / $maxLength',
              style: AdminStitchTheme.labelSm.copyWith(
                color: AdminStitchTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
