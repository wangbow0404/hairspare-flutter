import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../models/model_application_search_item.dart';
import '../../services/model_match_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/custom_date_picker_dialog.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
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
      final items = await _service.getApplicationPostsByDate(date: dateStr);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '날짜로 찾기'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _selectedDate != null
                          ? DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate!)
                          : '날짜 선택 (전체: 오늘 이후)',
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: AppTheme.spacing2),
                  TextButton(
                    onPressed: _clearDate,
                    child: const Text('전체보기'),
                  ),
                ],
              ],
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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ModelSearchProfileScreen(item: item),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: AppNetworkImage(
                    imageUrl: item.model.primaryImage,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.person_outline,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.model.name.isEmpty ? '모델' : item.model.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '$dateLabel · ${item.startTime}~${item.endTime}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (item.keywords.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacing1),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.keywords.take(3).map((k) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.purple100,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.purple700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
