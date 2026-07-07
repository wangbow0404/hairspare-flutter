import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../models/model_application_search_item.dart';
import '../../models/model_match_preference.dart';
import '../../services/model_match_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/custom_date_picker_dialog.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import 'model_search_profile_screen.dart';

/// 모델검색 — "날짜로 찾기": 날짜를 고르면 그날 신청 등록된 모델 목록을 보여준다.
class ModelDateSearchScreen extends StatefulWidget {
  const ModelDateSearchScreen({super.key});

  @override
  State<ModelDateSearchScreen> createState() => _ModelDateSearchScreenState();
}

class _ModelDateSearchScreenState extends State<ModelDateSearchScreen> {
  final ModelMatchService _service = sl<ModelMatchService>();

  DateTime? _selectedDate;
  Set<String> _selectedKeywords = {};
  List<ModelApplicationSearchItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dateStr = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      final items = await _service.getApplicationPostsByDate(
        date: dateStr,
        keywords: _selectedKeywords,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final ex = ErrorHandler.handleException(e);
      setState(() {
        _isLoading = false;
        _error = ErrorHandler.getUserFriendlyMessage(ex);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await CustomDatePickerDialog.show(
      context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked == null) return;
    setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
    _load();
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
    _load();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConditionFilterSheet(initial: _selectedKeywords),
    );
    if (result == null) return;
    setState(() => _selectedKeywords = result);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '날짜로 찾기'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _selectedDate != null
                          ? DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate!)
                          : '날짜 선택',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.tune),
                    label: Text(
                      _selectedKeywords.isEmpty
                          ? '조건 선택'
                          : '조건 선택 (${_selectedKeywords.length})',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _selectedKeywords.isEmpty
                          ? AppTheme.textPrimary
                          : AppTheme.stitchPrimary,
                      side: BorderSide(
                        color: _selectedKeywords.isEmpty
                            ? AppTheme.borderGray
                            : AppTheme.stitchPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                0,
                AppTheme.spacing4,
                AppTheme.spacing2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _clearDate,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('전체 날짜 다시 보기'),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? StitchEmptyState(
                        icon: Icons.error_outline,
                        message: _error!,
                        actionLabel: '다시 시도',
                        onAction: _load,
                      )
                    : _items.isEmpty
                        ? const StitchEmptyState(
                            icon: Icons.calendar_month_outlined,
                            message: '해당 날짜에 신청한 모델이 없습니다',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppTheme.spacing4,
                                0,
                                AppTheme.spacing4,
                                AppTheme.spacing6,
                              ),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppTheme.spacing3),
                              itemBuilder: (context, index) =>
                                  _ModelSearchCard(item: _items[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ModelSearchCard extends StatelessWidget {
  const _ModelSearchCard({required this.item});

  final ModelApplicationSearchItem item;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(item.date);
    final dateLabel =
        date != null ? DateFormat('M월 d일 (E)', 'ko_KR').format(date) : item.date;

    return Material(
      color: AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ModelSearchProfileScreen(item: item),
          ),
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                imageUrl: item.model.primaryImage,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person_outline,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: AppTheme.spacing4,
                right: AppTheme.spacing4,
                bottom: AppTheme.spacing4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.model.name.isEmpty ? '모델' : item.model.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$dateLabel · ${item.startTime}~${item.endTime}',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (item.keywords.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacing3),
                      Wrap(
                        spacing: AppTheme.spacing2,
                        runSpacing: AppTheme.spacing2,
                        children: item.keywords.take(3).map((k) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing3,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "날짜로 찾기"에서 날짜와 함께 좁힐 조건(기장·선호시술·이미지 스타일) 선택 시트.
class _ConditionFilterSheet extends StatefulWidget {
  const _ConditionFilterSheet({required this.initial});

  final Set<String> initial;

  @override
  State<_ConditionFilterSheet> createState() => _ConditionFilterSheetState();
}

class _ConditionFilterSheetState extends State<_ConditionFilterSheet> {
  late final Set<String> _selected = Set.of(widget.initial);

  void _toggle(String value) {
    setState(() {
      if (!_selected.add(value)) _selected.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacing4,
          right: AppTheme.spacing4,
          top: AppTheme.spacing3,
          bottom: AppTheme.spacing4 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: AppTheme.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                '어떤 조건의 모델을 찾으세요?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing5),
              _FilterSection(
                title: '기장',
                options: ModelMatchOptions.hairLengths,
                selected: _selected,
                onToggle: _toggle,
              ),
              _FilterSection(
                title: '선호하는 시술',
                options: ModelMatchOptions.treatments,
                selected: _selected,
                onToggle: _toggle,
              ),
              _FilterSection(
                title: '모델 이미지',
                options: ModelMatchOptions.imageStyles,
                selected: _selected,
                onToggle: _toggle,
              ),
              const SizedBox(height: AppTheme.spacing2),
              Row(
                children: [
                  if (_selected.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(_selected.clear),
                      child: const Text('초기화'),
                    ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: AppTheme.spacing2),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimary,
                  ),
                  child: const Text('적용하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Wrap(
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
          ),
        ],
      ),
    );
  }
}
