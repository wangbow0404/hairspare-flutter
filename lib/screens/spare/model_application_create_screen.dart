import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/model_match_preference.dart';
import '../../services/model_application_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/custom_date_picker_dialog.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 모델 신청 작성 화면 — 가능한 날짜(여러 개)·시간·키워드를 등록.
class ModelApplicationCreateScreen extends StatefulWidget {
  const ModelApplicationCreateScreen({super.key});

  @override
  State<ModelApplicationCreateScreen> createState() =>
      _ModelApplicationCreateScreenState();
}

class _ModelApplicationCreateScreenState
    extends State<ModelApplicationCreateScreen> {
  final ModelApplicationService _service = sl<ModelApplicationService>();
  final TextEditingController _memoController = TextEditingController();

  final List<DateTime> _selectedDates = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _keywords = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat('M월 d일 (E)', 'ko_KR').format(d);

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '선택';
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _addDate() async {
    final now = DateTime.now();
    final picked = await CustomDatePickerDialog.show(
      context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked == null) return;
    final normalized = DateTime(picked.year, picked.month, picked.day);
    if (_selectedDates.any((d) => d.isAtSameMomentAs(normalized))) return;
    setState(() {
      _selectedDates.add(normalized);
      _selectedDates.sort();
    });
  }

  void _removeDate(DateTime date) {
    setState(() => _selectedDates.remove(date));
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _toggleKeyword(String keyword) {
    setState(() {
      if (!_keywords.add(keyword)) _keywords.remove(keyword);
    });
  }

  bool get _canSubmit =>
      _selectedDates.isNotEmpty &&
      _startTime != null &&
      _endTime != null &&
      !_isSubmitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      final dateStrings = _selectedDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toList();
      await _service.createPost(
        dates: dateStrings,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        keywords: _keywords.toList(),
        memo: _memoController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>()
          .showError(ErrorHandler.getUserFriendlyMessage(ex));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '모델 신청'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing6,
        ),
        children: [
          _Section(
            title: '가능한 날짜 (여러 개 선택 가능)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedDates.isNotEmpty)
                  Wrap(
                    spacing: AppTheme.spacing2,
                    runSpacing: AppTheme.spacing2,
                    children: _selectedDates
                        .map(
                          (d) => Chip(
                            label: Text(_formatDate(d)),
                            onDeleted: () => _removeDate(d),
                            backgroundColor: AppTheme.primaryPurpleLight,
                            labelStyle: const TextStyle(
                              color: AppTheme.stitchPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            deleteIconColor: AppTheme.stitchPrimary,
                          ),
                        )
                        .toList(),
                  ),
                if (_selectedDates.isNotEmpty)
                  const SizedBox(height: AppTheme.spacing3),
                OutlinedButton.icon(
                  onPressed: _addDate,
                  icon: const Icon(Icons.add),
                  label: const Text('날짜 추가'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _Section(
            title: '시간',
            child: Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: '시작 시간',
                    value: _formatTime(_startTime),
                    onTap: _pickStartTime,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: _TimeField(
                    label: '종료 시간',
                    value: _formatTime(_endTime),
                    onTap: _pickEndTime,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _Section(
            title: '기장',
            child: _MultiChips(
              options: ModelMatchOptions.hairLengths,
              selected: _keywords,
              onToggle: _toggleKeyword,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _Section(
            title: '선호하는 시술',
            child: _MultiChips(
              options: ModelMatchOptions.treatments,
              selected: _keywords,
              onToggle: _toggleKeyword,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _Section(
            title: '모델 이미지',
            child: _MultiChips(
              options: ModelMatchOptions.imageStyles,
              selected: _keywords,
              onToggle: _toggleKeyword,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Text(
            '키워드를 많이 선택할수록 매칭 확률이 높아져요',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.stitchPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _Section(
            title: '메모 (선택)',
            child: TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '이런 시술이면 더 좋아요 등 자유롭게 적어주세요',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StitchStickyBottomBar(
        primaryLabel: '신청 등록하기',
        onPrimary: _submit,
        isLoading: _isSubmitting,
        enabled: _selectedDates.isNotEmpty &&
            _startTime != null &&
            _endTime != null,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        child,
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing3,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiChips extends StatelessWidget {
  const _MultiChips({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing2,
      children: [
        for (final o in options)
          StitchFilterChip(
            label: o,
            isSelected: selected.contains(o),
            onTap: () => onToggle(o),
          ),
      ],
    );
  }
}
