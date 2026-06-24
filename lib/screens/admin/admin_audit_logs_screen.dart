import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_screen_scaffold.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M18. 감사 로그 화면 (읽기 전용)
class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _logs = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _search = '';
  String _actionFilter = 'all';
  Timer? _searchDebounceTimer;

  static const _actionTabs = [
    '전체',
    '인증 승인',
    '인증 반려',
    '신고 처리',
    '설정 변경',
    '에너지 지급',
  ];

  static const _actionMap = {
    '전체': 'all',
    '인증 승인': 'approve_verification',
    '인증 반려': 'reject_verification',
    '신고 처리': 'resolve_case',
    '설정 변경': 'update_config',
    '에너지 지급': 'grant_energy',
  };

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLogs({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final result = await _adminService.getAuditLogs(
        action: _actionFilter == 'all' ? null : _actionFilter,
        search: _search.isEmpty ? null : _search,
      );
      if (mounted) {
        setState(() {
          _logs = result['logs'] ?? [];
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '감사 로그 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR').format(date);
    } catch (_) {
      return dateString;
    }
  }

  Color _actionChipColor(String action) {
    switch (action) {
      case 'approve_verification':
      case 'grant_energy':
        return AppTheme.green600;
      case 'reject_verification':
      case 'apply_sanction':
        return AppTheme.urgentRed;
      case 'update_config':
        return AppTheme.primaryPurple;
      case 'resolve_case':
        return AppTheme.orange600;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _selectedTabLabel() {
    for (final entry in _actionMap.entries) {
      if (entry.value == _actionFilter) return entry.key;
    }
    return '전체';
  }

  void _showDetail(Map<String, dynamic> log) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('감사 로그 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('일시', _formatDate(log['createdAt']?.toString() ?? '')),
              _detailRow('관리자', log['adminName']?.toString() ?? '-'),
              _detailRow('액션', log['actionLabel']?.toString() ?? log['action']?.toString() ?? '-'),
              _detailRow('대상', '${log['targetType']} / ${log['targetId']}'),
              _detailRow('사유', log['reason']?.toString() ?? '-'),
              if (log['beforeValue'] != null) ...[
                const SizedBox(height: AppTheme.spacing3),
                const Text(
                  '변경 전',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  const JsonEncoder.withIndent('  ').convert(log['beforeValue']),
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
              if (log['afterValue'] != null) ...[
                const SizedBox(height: AppTheme.spacing3),
                const Text(
                  '변경 후',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  const JsonEncoder.withIndent('  ').convert(log['afterValue']),
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenScaffold(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminPageHeader(
            title: '감사 로그',
            subtitle: '관리자 조치 이력을 추적합니다 (읽기 전용 · 수정 불가)',
          ),
          const SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '관리자, 사유, 대상 ID 검색...',
            filterTabs: _actionTabs,
            selectedTab: _selectedTabLabel(),
            onTabChanged: (tab) {
              setState(() {
                _actionFilter = _actionMap[tab] ?? 'all';
              });
              _loadLogs();
            },
            onSearchChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() => _search = value);
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) _loadLogs();
              });
            },
          ),
        ],
      ),
      body: AdminTableCard(
        child: _isLoading && _logs.isEmpty
            ? const AdminTableSkeleton(rowCount: 8, columnCount: 6)
            : _hasLoadError
                ? _buildErrorState()
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : _buildTable(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: AppTheme.urgentRed),
          const SizedBox(height: AppTheme.spacing4),
          const Text('감사 로그를 불러오지 못했습니다'),
          const SizedBox(height: AppTheme.spacing4),
          FilledButton.icon(
            onPressed: () => _loadLogs(),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppTheme.textTertiary),
          SizedBox(height: AppTheme.spacing4),
          Text('감사 로그가 없습니다', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 960),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdminTableHeader(
              headers: ['일시', '관리자', '액션', '대상', '사유', '상세'],
              flexValues: [2, 1, 1, 1, 2, 1],
            ),
            SizedBox(
              height: 480,
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index] as Map<String, dynamic>;
                  final action = log['action']?.toString() ?? '';
                  final chipColor = _actionChipColor(action);
                  return InkWell(
                    onTap: () => _showDetail(log),
                    child: Container(
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
                            flex: 2,
                            child: Text(
                              _formatDate(log['createdAt']?.toString() ?? ''),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              log['adminName']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: chipColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                log['actionLabel']?.toString() ?? action,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: chipColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${log['targetType']}\n${log['targetId']}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              log['reason']?.toString() ?? '-',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: const Icon(Icons.visibility, size: 18),
                              onPressed: () => _showDetail(log),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.adminPurple50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
