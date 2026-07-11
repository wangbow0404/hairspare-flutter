import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 공고 지원 현황 화면
class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  List<dynamic> _applications = [];
  bool _isLoading = true;
  String _statusFilter = '';
  DateTimeRange? _dateRange;
  int _currentPage = 1;
  int _totalPages = 1;

  static const _statusTabs = ['전체', '대기중', '승인됨', '거절됨', '취소됨'];
  static const _statusMap = {
    '전체': '',
    '대기중': 'pending',
    '승인됨': 'approved',
    '거절됨': 'rejected',
    '취소됨': 'cancelled_contact_violation',
  };

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadApplications({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final result = await _adminService.getApplications(
        status: _statusFilter.isEmpty ? null : _statusFilter,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
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
          _applications = result['applications'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '지원 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _selectedStatusTab() {
    for (final e in _statusMap.entries) {
      if (e.value == _statusFilter) return e.key;
    }
    return '전체';
  }

  String _dateRangeLabel() {
    if (_dateRange == null) return '날짜 · 전체';
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
    _loadApplications();
  }

  void _clearDateRange() {
    setState(() {
      _dateRange = null;
      _currentPage = 1;
    });
    _loadApplications();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      return DateFormat(
        'yyyy.MM.dd HH:mm',
        'ko_KR',
      ).format(DateTime.parse(dateString).toLocal());
    } catch (_) {
      return dateString;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AdminStitchTheme.emerald;
      case 'pending':
        return AppTheme.orange600;
      case 'rejected':
        return AdminStitchTheme.statusError;
      case 'cancelled_contact_violation':
        return AdminStitchTheme.textSecondary;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled_contact_violation':
        return Icons.warning_amber_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _cancelApplication(Map<String, dynamic> app) async {
    final spareName = app['spare']?['name']?.toString() ?? '-';
    final jobTitle = app['job']?['title']?.toString() ?? '-';
    final reason = await AdminActionDialog.show(
      context,
      title: '지원 강제 취소',
      confirmLabel: '취소 처리',
      summary: '$spareName · $jobTitle',
      isDanger: true,
    );
    if (reason == null || !mounted) return;

    try {
      await _adminService.cancelApplication(
        app['id'].toString(),
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지원이 강제 취소 처리되었습니다')));
      _loadApplications(showLoading: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '강제 취소 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
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
            title: '지원 현황',
            subtitle: '스페어의 공고 지원 내역을 조회하고 관리합니다',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '스페어·미용실·공고명으로 검색...',
            onChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() => _currentPage = 1);
              _searchDebounceTimer = Timer(
                const Duration(milliseconds: 300),
                () {
                  if (!mounted) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _loadApplications();
                  });
                },
              );
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _statusTabs,
            selectedTab: _selectedStatusTab(),
            onTabChanged: (tab) {
              setState(() {
                _statusFilter = _statusMap[tab] ?? '';
                _currentPage = 1;
              });
              _loadApplications();
            },
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
                const SizedBox(width: AdminStitchTheme.stackTight),
                IconButton(
                  onPressed: _clearDateRange,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: '날짜 필터 지우기',
                  visualDensity: VisualDensity.compact,
                  color: AdminStitchTheme.textSecondary,
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
    if (_isLoading && _applications.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_applications.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '지원 내역이 없습니다',
        emptyIcon: Icons.assignment_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _applications.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, index) =>
            _buildCard(_applications[index] as Map<String, dynamic>),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> app) {
    final status = app['status']?.toString() ?? '';
    final statusLabel = app['statusLabel']?.toString() ?? status;
    final statusColor = _statusColor(status);
    final spareName = app['spare']?['name']?.toString() ?? '-';
    final spareEmail = app['spare']?['email']?.toString() ?? '';
    final shopName = app['shop']?['name']?.toString() ?? '-';
    final jobTitle = app['job']?['title']?.toString() ?? '-';
    final amount = app['job']?['amount'];
    final startTime = app['job']?['startTime']?.toString();
    final createdAt = app['createdAt']?.toString();

    return AdminStitchSimpleListCard(
      title: spareName,
      subtitle: '$shopName · $jobTitle · ${_formatDate(startTime)}',
      icon: _statusIcon(status),
      iconColor: statusColor,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (status == 'pending') ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, size: 20),
              color: AdminStitchTheme.statusError,
              tooltip: '강제 취소',
              onPressed: () => _cancelApplication(app),
            ),
          ],
        ],
      ),
      onTap: () {
        final id = app['id']?.toString();
        if (id == null) return;
        context.push(AppRoutes.adminApplicationDetail(id), extra: app);
      },
    );
  }
}
