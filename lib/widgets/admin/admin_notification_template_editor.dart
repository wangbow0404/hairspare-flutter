import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';

/// 전체 공지 템플릿 생성·수정 시트.
class AdminNotificationTemplateEditor extends StatefulWidget {
  const AdminNotificationTemplateEditor({
    super.key,
    this.template,
    required this.onSave,
    this.onDelete,
  });

  final Map<String, dynamic>? template;
  final Future<void> Function({
    required String name,
    required String title,
    required String body,
  }) onSave;
  final Future<void> Function()? onDelete;

  static Future<bool?> show(
    BuildContext context, {
    Map<String, dynamic>? template,
    required Future<void> Function({
      required String name,
      required String title,
      required String body,
    }) onSave,
    Future<void> Function()? onDelete,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: AdminNotificationTemplateEditor(
          template: template,
          onSave: onSave,
          onDelete: onDelete,
        ),
      ),
    );
  }

  bool get isEditing => template != null;

  @override
  State<AdminNotificationTemplateEditor> createState() =>
      _AdminNotificationTemplateEditorState();
}

class _AdminNotificationTemplateEditorState
    extends State<AdminNotificationTemplateEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final tpl = widget.template;
    _nameController = TextEditingController(text: tpl?['name']?.toString() ?? '');
    _titleController =
        TextEditingController(text: tpl?['title']?.toString() ?? '');
    _bodyController = TextEditingController(text: tpl?['body']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (name.isEmpty || title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('템플릿 이름·제목·본문을 모두 입력해주세요')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(name: name, title: title, body: body);
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('템플릿 삭제'),
        content: const Text('이 템플릿을 삭제할까요?'),
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

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete!();
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isSaving || _isDeleting;

    return Container(
      decoration: const BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
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
            widget.isEditing ? '템플릿 수정' : '템플릿 추가',
            style: AdminStitchTheme.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            '역할별 전체 공지 발송에 사용할 메시지를 저장합니다.',
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          _field(label: '템플릿 이름', controller: _nameController, hint: '예: 점검 안내'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          _field(label: '알림 제목', controller: _titleController, hint: '발송 시 표시될 제목'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          _field(
            label: '알림 본문',
            controller: _bodyController,
            hint: '발송 시 표시될 본문',
            maxLines: 5,
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Row(
            children: [
              if (widget.isEditing && widget.onDelete != null) ...[
                TextButton(
                  onPressed: busy ? null : _delete,
                  child: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '삭제',
                          style: TextStyle(color: AppTheme.urgentRed),
                        ),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: busy ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AdminStitchTheme.primary,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AdminStitchTheme.onPrimary,
                        ),
                      )
                    : Text(widget.isEditing ? '저장' : '추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminStitchTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AdminStitchTheme.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
            filled: true,
            fillColor: AdminStitchTheme.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
              borderSide: const BorderSide(color: AdminStitchTheme.primary),
            ),
            contentPadding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          ),
        ),
      ],
    );
  }
}
