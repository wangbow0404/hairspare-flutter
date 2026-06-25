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
  bool _isLoading = true;
  int _currentPage = 1;
  String _dateFilter = 'today';
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _dateTabs = ['오늘', '이번주', '전체'];
  static const _dateMap = {
    '오늘': 'today',
    '이번주': 'week',
    '전체': 'all',
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
        dateFilter: _dateFilter,
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _schedules = result['schedules'] ?? [];
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
    return '오늘';
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR').format(date);
    } catch (_) {
      return dateString;
    }
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

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'checked_in':
      case 'completed':
      case 'done':
        return AdminStitchTheme.emerald;
      case 'pending':
      case 'scheduled':
        return AppTheme.orange600;
      case 'cancelled':
      case 'noshow':
        return AdminStitchTheme.statusError;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  String _getStateLabel(String state) {
    switch (state.toLowerCase()) {
      case 'checked_in':
      case 'completed':
      case 'done':
        return '체크인 완료';
      case 'pending':
      case 'scheduled':
        return '예정';
      case 'cancelled':
      case 'noshow':
        return '취소/노쇼';
      default:
        return state.isNotEmpty ? state : '-';
    }
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
            subtitle: '오늘 체크인 및 전체 스케줄 내역을 조회할 수 있습니다',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '사용자, 미용실명으로 검색...',
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
            selectedTab: _selectedDateTab(),
            onTabChanged: (tab) {
              setState(() {
                _dateFilter = _dateMap[tab] ?? 'today';
                _currentPage = 1;
              });
              _loadSchedules();
            },
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
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '체크인 내역이 없습니다',
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
          final checkInTime =
              schedule['checkInTime'] ?? schedule['checkIn'];
          final state =
              schedule['state']?.toString() ??
              schedule['status']?.toString() ??
              '';
          final stateColor = _getStateColor(state);
          final jobTitle = schedule['job']?['title']?.toString() ?? '-';

          return AdminStitchSimpleListCard(
            title: _spareName(schedule),
            subtitle:
                '${_shopName(schedule)} · $jobTitle · ${_formatDate(checkInTime?.toString())}',
            icon: Icons.calendar_today_outlined,
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
                    _getStateLabel(state),
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
