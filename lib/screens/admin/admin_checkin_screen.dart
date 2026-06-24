import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_screen_scaffold.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';
import '../../widgets/admin/admin_action_dialog.dart';

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
  String _dateFilter = 'today'; // today, week, all
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadSchedules(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSchedules({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _adminService.getSchedules(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
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
              content: Text('체크인 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenScaffold(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminPageHeader(
            title: '체크인 관리',
            subtitle: '오늘 체크인 및 전체 스케줄 내역을 조회할 수 있습니다',
          ),
          const SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '사용자, 미용실명으로 검색...',
            filterDropdown: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _dateFilter.isEmpty ? 'today' : _dateFilter,
                  hint: const Text('기간'),
                  items: const [
                    DropdownMenuItem(value: 'today', child: Text('오늘')),
                    DropdownMenuItem(value: 'week', child: Text('이번 주')),
                    DropdownMenuItem(value: 'all', child: Text('전체')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _dateFilter = value ?? 'today';
                      _currentPage = 1;
                      _loadSchedules();
                    });
                  },
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AdminTableCard(
              child: _isLoading && _schedules.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _schedules.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 64,
                                  color: AppTheme.textTertiary,
                                ),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '체크인 내역이 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing2),
                                Text(
                                  '스페어의 체크인 내역이 여기에 표시됩니다',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: constraints.maxWidth < 900 ? 900 : constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: Column(
                                  children: [
                                    const AdminTableHeader(
                                      headers: ['스케줄', '스페어', '미용실', '공고', '체크인 일시', '상태', '개입'],
                                      flexValues: [1, 1, 1, 2, 1, 1, 1],
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                      itemCount: _schedules.length,
                                      itemBuilder: (context, index) {
                                        final schedule = _schedules[index];
                                        final checkInTime = schedule['checkInTime'] ?? schedule['checkIn'];
                                        final state = schedule['state'] ?? schedule['status'] ?? '';
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacing4,
                                            vertical: AppTheme.spacing3,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppTheme.adminPurple100.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  schedule['id']?.toString() ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  schedule['spare']?['name'] ??
                                                      schedule['spare']?['email'] ??
                                                      schedule['energyWallet']?['user']?['email'] ??
                                                      '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  schedule['shop']?['name'] ??
                                                      schedule['job']?['shop']?['name'] ??
                                                      '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  schedule['job']?['title'] ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _formatDate(checkInTime?.toString()),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: AppTheme.spacing2,
                                                    vertical: AppTheme.spacing1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStateColor(state).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                                  ),
                                                  child: Text(
                                                    _getStateLabel(state),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: _getStateColor(state),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: PopupMenuButton<String>(
                                                  onSelected: (action) => _intervene(schedule, action),
                                                  itemBuilder: (_) => const [
                                                    PopupMenuItem(value: 'complete', child: Text('강제 완료')),
                                                    PopupMenuItem(value: 'cancel', child: Text('강제 취소')),
                                                    PopupMenuItem(value: 'noshow', child: Text('노쇼 처리')),
                                                  ],
                                                  child: const Icon(Icons.more_vert, size: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          },
                        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toString().toLowerCase()) {
      case 'checked_in':
      case 'completed':
      case 'done':
        return AppTheme.primaryGreen;
      case 'pending':
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
      case 'noshow':
        return AppTheme.urgentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStateLabel(String state) {
    switch (state.toString().toLowerCase()) {
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
    final labels = {'complete': '강제 완료', 'cancel': '강제 취소', 'noshow': '노쇼 처리'};
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
          await _adminService.markNoShow(id, reason: reason, party: 'spare');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${labels[action]} 완료 (감사 로그 기록)')));
      _loadSchedules();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }
}
