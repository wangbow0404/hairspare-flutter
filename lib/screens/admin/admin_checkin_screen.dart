import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 체크인 관리 화면
class AdminCheckinScreen extends StatefulWidget {
  const AdminCheckinScreen({super.key});

  @override
  State<AdminCheckinScreen> createState() => _AdminCheckinScreenState();
}

class _AdminCheckinScreenState extends State<AdminCheckinScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _schedules = [];
  Map<String, dynamic> _counts = {};
  bool _isLoading = true;
  int _currentPage = 1;
  String _dateFilter = 'week';
  String _stateFilter = '';
  DateTimeRange? _dateRange;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _dateTabs = ['오늘', '이번주', '전체'];
  static const _dateMap = {
    '오늘': 'today',
    '이번주': 'week',
    '전체': 'all',
  };

  static const _statusTabs = [
    '전체',
    '조치 필요',
    '예정',
    '정산 대기',
    '완료',
    '취소',
  ];
  static const _statusMap = {
    '전체': '',
    '조치 필요': 'needs_attention',
    '예정': 'scheduled',
    '정산 대기': 'settlement_pending',
    '완료': 'completed',
    '취소': 'cancelled',
  };

  static const _countKeys = {
    '전체': 'all',
    '조치 필요': 'needs_attention',
    '예정': 'scheduled',
    '정산 대기': 'settlement_pending',
    '완료': 'completed',
    '취소': 'cancelled',
  };

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadSchedules(showLoading: false);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSchedules({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await _adminService.getSchedules(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        dateFilter: _dateRange == null ? _dateFilter : null,
        state: _stateFilter.isEmpty ? null : _stateFilter,
        dateFrom: _dateRange == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_dateRange!.start),
        dateTo: _dateRange == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_dateRange!.end),
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _schedules = result['schedules'] ?? [];
          _counts = (result['counts'] as Map?)?.cast<String, dynamic>() ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '체크인 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _selectedDateTab() {
    for (final entry in _dateMap.entries) {
      if (entry.value == _dateFilter) return entry.key;
    }
    return '이번주';
  }

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _stateFilter) return entry.key;
    }
    return '전체';
  }

  List<String> get _statusTabsWithCounts {
    return _statusTabs.map((tab) {
      final key = _countKeys[tab];
      if (key == null || _counts.isEmpty) return tab;
      final count = _counts[key];
      if (count == null || count == 0) return tab;
      return '$tab ($count)';
    }).toList();
  }

  String get _selectedStatusTabWithCount {
    final base = _selectedStatusTab();
    for (final tab in _statusTabsWithCounts) {
      if (tab == base || tab.startsWith('$base (')) return tab;
    }
    return base;
  }

  String _dateRangeLabel() {
    if (_dateRange == null) return '근무일 · 전체';
    final fmt = DateFormat('M.d', 'ko_KR');
    return '${fmt.format(_dateRange!.start)} ~ ${fmt.format(_dateRange!.end)}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
      locale: const Locale('ko', 'KR'),
    );
    if (picked == null) return;
    setState(() {
      _dateRange = picked;
      _currentPage = 1;
    });
    _loadSchedules();
  }

  void _clearDateRange() {
    setState(() {
      _dateRange = null;
      _currentPage = 1;
    });
    _loadSchedules();
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR').format(date);
    } catch (_) {
      return dateString;
    }
  }

  String _formatWorkTime(Map<String, dynamic> schedule) {
    final date = schedule['date']?.toString();
    final time = schedule['startTime']?.toString();
    if (date == null || date.isEmpty) return '-';
    if (time == null || time.isEmpty) return date;
    return '$date $time';
  }

  String _subtitle(Map<String, dynamic> schedule) {
    final shop = _shopName(schedule);
    final jobTitle = schedule['job']?['title']?.toString() ?? '-';
    final checkInTime = schedule['checkInTime'] ?? schedule['checkIn'];
    final timeLabel = checkInTime != null
        ? '체크인 ${_formatDateTime(checkInTime.toString())}'
        : '근무 ${_formatWorkTime(schedule)}';
    return '$shop · $jobTitle · $timeLabel';
  }

  String _spareName(Map<String, dynamic> schedule) {
    return schedule['spare']?['name']?.toString() ??
        schedule['spare']?['email']?.toString() ??
        schedule['energyWallet']?['user']?['email']?.toString() ??
        '-';
  }

  String _shopName(Map<String, dynamic> schedule) {
    return schedule['shop']?['name']?.toString() ??
        schedule['job']?['shop']?['name']?.toString() ??
        '-';
  }

  Color _getStateColor(String state, {bool needsAttention = false}) {
    if (needsAttention) return AdminStitchTheme.statusError;
    switch (state.toLowerCase()) {
      case 'checked_in':
      case 'settlement_pending':
        return AppTheme.orange600;
      case 'completed':
      case 'done':
        return AdminStitchTheme.emerald;
      case 'pending':
      case 'scheduled':
        return AdminStitchTheme.primary;
      case 'cancelled':
      case 'noshow':
        return AdminStitchTheme.statusError;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  String _getStateLabel(Map<String, dynamic> schedule) {
    if (schedule['needsAttention'] == true) return '조치 필요';
    final label = schedule['stateLabel']?.toString();
    if (label != null && label.isNotEmpty) return label;
    final state = schedule['state']?.toString() ?? schedule['status']?.toString() ?? '';
    switch (state.toLowerCase()) {
      case 'checked_in':
      case 'settlement_pending':
        return '정산 대기';
      case 'completed':
      case 'done':
        return '완료';
      case 'pending':
      case 'scheduled':
        return '예정';
      case 'cancelled':
        return '취소';
      case 'noshow':
        return '노쇼';
      default:
        return state.isNotEmpty ? state : '-';
    }
  }

  String _emptyMessage() {
    if (_stateFilter == 'needs_attention') {
      return '조치가 필요한 스케줄이 없습니다';
    }
    if (_stateFilter == 'settlement_pending') {
      return '정산 대기 중인 스케줄이 없습니다';
    }
    if (_dateFilter == 'today' && _dateRange == null) {
      return '오늘 예정된 근무 스케줄이 없습니다';
    }
    return '체크인 내역이 없습니다';
  }

  void _onStatusTabChanged(String tab) {
    final base = tab.split(' (').first;
    setState(() {
      _stateFilter = _statusMap[base] ?? '';
      _currentPage = 1;
    });
    _loadSchedules();
  }

  Future<void> _intervene(Map<String, dynamic> schedule, String action) async {
    final labels = {
      'complete': '강제 완료',
      'cancel': '강제 취소',
      'noshow': '노쇼 처리',
    };
    final reason = await AdminActionDialog.show(
      context,
      title: labels[action] ?? '스케줄 개입',
      confirmLabel: '실행',
      summary: schedule['job']?['title']?.toString(),
      isDanger: action != 'complete',
    );
    if (reason == null || !mounted) return;
    final id = schedule['id'].toString();
    try {
      switch (action) {
        case 'complete':
          await _adminService.forceCompleteSchedule(id, reason: reason);
        case 'cancel':
          await _adminService.forceCancelSchedule(id, reason: reason);
        case 'noshow':
          await _adminService.markNoShow(
            id,
            reason: reason,
            party: 'spare',
          );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${labels[action]} 완료 (감사 로그 기록)')),
      );
      _loadSchedules();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(
              ErrorHandler.handleException(e),
            ),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '체크인 관리',
            subtitle: '근무 스케줄 진행 상태를 확인하고 필요 시 개입할 수 있습니다',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '스페어·미용실·공고명으로 검색...',
            onChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() => _currentPage = 1);
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _loadSchedules();
                });
              });
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _dateTabs,
            selectedTab: _dateRange == null ? _selectedDateTab() : '전체',
            onTabChanged: (tab) {
              setState(() {
                _dateRange = null;
                _dateFilter = _dateMap[tab] ?? 'week';
                _currentPage = 1;
              });
              _loadSchedules();
            },
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchFilterChips(
            tabs: _statusTabsWithCounts,
            selectedTab: _selectedStatusTabWithCount,
            onTabChanged: _onStatusTabChanged,
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Row(
            children: [
              Material(
                color: _dateRange != null
                    ? AdminStitchTheme.primary
                    : AdminStitchTheme.surfaceCard,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: _dateRange != null
                          ? null
                          : Border.all(color: AdminStitchTheme.borderDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: _dateRange != null
                              ? AdminStitchTheme.onPrimary
                              : AdminStitchTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _dateRangeLabel(),
                          style: AdminStitchTheme.labelSm.copyWith(
                            color: _dateRange != null
                                ? AdminStitchTheme.onPrimary
                                : AdminStitchTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_dateRange != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearDateRange,
                  child: Text(
                    '초기화',
                    style: AdminStitchTheme.labelSm.copyWith(
                      color: AdminStitchTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _schedules.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_schedules.isEmpty) {
      return AdminStitchListStateSliver.empty(
        emptyMessage: _emptyMessage(),
        emptyIcon: Icons.calendar_today_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _schedules.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, index) {
          final schedule = _schedules[index] as Map<String, dynamic>;
          final state = schedule['state']?.toString() ??
              schedule['status']?.toString() ??
              '';
          final needsAttention = schedule['needsAttention'] == true;
          final stateColor = _getStateColor(
            state,
            needsAttention: needsAttention,
          );

          return AdminStitchSimpleListCard(
            title: _spareName(schedule),
            subtitle: _subtitle(schedule),
            icon: needsAttention
                ? Icons.warning_amber_rounded
                : Icons.calendar_today_outlined,
            iconColor: stateColor,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStateLabel(schedule),
                    style: AdminStitchTheme.labelSm.copyWith(
                      fontSize: 10,
                      color: stateColor,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _intervene(schedule, action),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'complete',
                      child: Text('강제 완료'),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Text('강제 취소'),
                    ),
                    PopupMenuItem(
                      value: 'noshow',
                      child: Text('노쇼 처리'),
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AdminStitchTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
