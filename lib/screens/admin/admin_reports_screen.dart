import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M12. 신고/제재 케이스 화면 (Stitch 케이스 카드)
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _reports = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _statusFilter = 'open';
  String _searchQuery = '';
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _statusTabs = ['전체', '긴급', '검토중'];
  static const _statusMap = {
    '전체': 'all',
    '긴급': 'high',
    '검토중': 'in_review',
  };

  @override
  void initState() {
    super.initState();
    _loadReports();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadReports(showLoading: false);
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

  Future<void> _loadReports({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      String? status;
      String? priority;
      if (_statusFilter == 'high') {
        priority = 'high';
      } else if (_statusFilter == 'in_review') {
        status = 'in_review';
      } else if (_statusFilter != 'all') {
        status = _statusFilter;
      }

      final result = await _adminService.getReports(
        status: status,
        category: null,
      );
      var reports = (result['reports'] as List?) ?? [];

      if (priority == 'high') {
        reports = reports
            .where((r) => (r as Map)['priority']?.toString() == 'high')
            .toList();
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        reports = reports.where((r) {
          final map = r as Map;
          final haystack = [
            map['id'],
            map['reporterName'],
            map['reportedName'],
            map['summary'],
            map['categoryLabel'],
          ].join(' ').toLowerCase();
          return haystack.contains(q);
        }).toList();
      }

      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '신고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '전체';
  }

  Color _priorityStripeColor(String priority) {
    switch (priority) {
      case 'high':
        return AdminStitchTheme.statusError;
      case 'medium':
        return AdminStitchTheme.secondary;
      default:
        return AdminStitchTheme.surfaceDim;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return '긴급';
      case 'medium':
        return '보통';
      case 'low':
        return '낮음';
      default:
        return priority;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return '접수';
      case 'in_review':
        return '검토중';
      case 'resolved':
        return '처리완료';
      default:
        return status;
    }
  }

  Future<void> _resolveReport(Map<String, dynamic> report, String action) async {
    final actionLabels = {
      'dismiss': '기각',
      'warn': '경고',
      'suspend': '정지',
      'ban': '영구정지',
    };
    final label = actionLabels[action] ?? action;

    final reason = await AdminActionDialog.show(
      context,
      title: '신고 $label',
      confirmLabel: label,
      summary: '피신고: ${report['reportedName']} (${report['categoryLabel']})',
      isDanger: action == 'ban' || action == 'suspend',
    );
    if (reason == null || !mounted) return;

    try {
      await _adminService.resolveReport(
        report['id'].toString(),
        action: action,
        reason: reason,
        durationDays: action == 'suspend' ? 7 : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신고가 $label 처리되었습니다')),
      );
      _loadReports(showLoading: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminStitchPageHeader(
                  title: '신고·제재',
                  subtitle: '케이스를 검토하고 제재를 실행합니다.',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchSearchField(
                  controller: _searchController,
                  hint: '케이스 ID 또는 사용자 검색...',
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    setState(() => _searchQuery = value.trim());
                    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _loadReports(showLoading: false);
                      });
                    });
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _statusTabs,
                  selectedTab: _selectedStatusTab(),
                  onTabChanged: (tab) {
                    setState(() => _statusFilter = _statusMap[tab] ?? 'all');
                    _loadReports();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
              ],
            ),
          ),
        ),
        if (_isLoading && _reports.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_hasLoadError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _loadReports(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ),
          )
        else if (_reports.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.report_outlined, size: 64, color: AdminStitchTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('해당 조건의 신고가 없습니다'),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AdminStitchTheme.pageMargin,
              0,
              AdminStitchTheme.pageMargin,
              AdminStitchListScreenShell.listPadding(context).bottom,
            ),
            sliver: SliverList.separated(
              itemCount: _reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: AdminStitchTheme.sectionGap),
              itemBuilder: (context, index) => _buildReportCard(_reports[index] as Map<String, dynamic>),
            ),
          ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? '';
    final priority = report['priority']?.toString() ?? 'low';
    final isOpen = status == 'open' || status == 'in_review';
    final caseId = report['caseId']?.toString() ??
        '#CAS-${report['id']?.toString().padLeft(4, '0') ?? '0000'}';

    return AdminStitchReportCaseCard(
      caseId: caseId,
      title: report['categoryLabel']?.toString() ??
          report['summary']?.toString() ??
          '신고 케이스',
      targetName: report['reportedName']?.toString() ?? '-',
      reporterName: report['reporterName']?.toString() ?? '-',
      priorityLabel: _priorityLabel(priority),
      priorityColor: _priorityStripeColor(priority),
      statusLabel: _statusLabel(status),
      isHighPriority: priority == 'high',
      isUnderReview: status == 'in_review',
      showActions: isOpen,
      onTap: () => context.push(
        AppRoutes.adminReportDetail(report['id'].toString()),
        extra: report,
      ),
      onDismiss: isOpen ? () => _resolveReport(report, 'dismiss') : null,
      onReview: () => context.push(
        AppRoutes.adminReportDetail(report['id'].toString()),
        extra: report,
      ),
    );
  }
}
