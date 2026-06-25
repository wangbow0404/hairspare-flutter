import 'package:flutter/material.dart';

import '../../services/report_service.dart';
import '../../theme/app_theme.dart';

/// 신고 카테고리
const _categories = [
  ('noshow', '노쇼'),
  ('contact', '연락처 유출'),
  ('abuse', '욕설/비방'),
  ('payment', '결제 분쟁'),
  ('other', '기타'),
];

/// 어디서든 호출할 수 있는 신고 바텀시트
///
/// ```dart
/// await showReportSheet(context, reportedUserId: 'usr-2');
/// ```
Future<void> showReportSheet(
  BuildContext context, {
  String? reportedUserId,
  String? referenceId,
  String? referenceType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ReportSheet(
      reportedUserId: reportedUserId,
      referenceId: referenceId,
      referenceType: referenceType,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    this.reportedUserId,
    this.referenceId,
    this.referenceType,
  });

  final String? reportedUserId;
  final String? referenceId;
  final String? referenceType;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _service = ReportService();
  final _controller = TextEditingController();
  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 유형을 선택해주세요')),
      );
      return;
    }
    final summary = _controller.text.trim();
    if (summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 내용을 입력해주세요')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _service.submitReport(
        category: category,
        summary: summary,
        reportedUserId: widget.reportedUserId,
        referenceId: widget.referenceId,
        referenceType: widget.referenceType,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고 제출 실패: $e'), backgroundColor: AppTheme.urgentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Expanded(
                child: Text(
                  '신고하기',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '신고 유형을 선택하고 내용을 입력해주세요.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // 카테고리 칩
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map(((String, String) cat) {
              final selected = _selectedCategory == cat.$1;
              return FilterChip(
                label: Text(cat.$2),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = cat.$1),
                backgroundColor: Colors.grey[800],
                selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.3),
                checkmarkColor: AppTheme.primaryPurple,
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primaryPurple : Colors.white70,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: selected ? AppTheme.primaryPurple : Colors.transparent,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // 신고 내용 입력
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '신고 내용을 자세히 적어주세요...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // 제출 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('신고 제출', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
