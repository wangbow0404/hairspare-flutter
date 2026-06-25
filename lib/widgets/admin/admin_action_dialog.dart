import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

abstract final class _DC {
  static const bg = Color(0xFF1E1C30);
  static const inputBg = Color(0xFF27253E);
  static const border = Color(0xFF3D3B56);
  static const focusBorder = Color(0xFF7C3AED);
  static const title = Color(0xFFF5F3FF);
  static const sub = Color(0xFF9CA3AF);
  static const note = Color(0xFF6B7280);
  static const primary = Color(0xFF580099);
}

/// [AdminActionDialog.show]에 전달하는 추가 입력 필드 설정
class AdminFieldConfig {
  const AdminFieldConfig({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
}

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
  final List<AdminFieldConfig>? extraFields;

  /// 사유 문자열 반환. 취소 시 null.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? summary,
    String reasonLabel = '처리 사유 (필수)',
    bool isDanger = false,
    List<AdminFieldConfig>? extraFields,
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

  /// 단순 확인 다이얼로그 (사유 입력 없음). 확인 시 true, 취소 시 false/null.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _AdminConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDanger: isDanger,
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

  static const _inputDec = InputDecoration(
    hintText: '입력해주세요',
    hintStyle: TextStyle(color: _DC.note),
    filled: true,
    fillColor: _DC.inputBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: _DC.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: _DC.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: _DC.focusBorder, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  /// 라벨 위 + 입력창 아래 패턴 (label is a separate Text above the field)
  static Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _DC.sub, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: _DC.title),
          decoration: _inputDec,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        widget.isDanger ? AppTheme.urgentRed : _DC.primary;

    return Dialog(
      backgroundColor: _DC.bg,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: _DC.title,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.summary != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.summary!,
                style: const TextStyle(color: _DC.sub, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.extraFields != null)
              for (final field in widget.extraFields!) ...[
                _field(
                  label: field.label,
                  controller: field.controller,
                  keyboardType: field.keyboardType,
                  maxLines: field.maxLines,
                ),
                const SizedBox(height: 12),
              ],
            _field(
              label: widget.reasonLabel,
              controller: _reasonController,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              '변경 내역은 감사 로그에 기록됩니다.',
              style: TextStyle(color: _DC.note, fontSize: 11),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('취소', style: TextStyle(color: _DC.sub)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    if (reason.isEmpty) return;
                    Navigator.pop(context, reason);
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: confirmColor),
                  child: Text(widget.confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminConfirmDialog extends StatelessWidget {
  const _AdminConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDanger ? AppTheme.urgentRed : _DC.primary;
    return Dialog(
      backgroundColor: _DC.bg,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _DC.title,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: _DC.sub, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: _DC.sub),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                      backgroundColor: confirmColor),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
