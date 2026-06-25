import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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
        return AdminStitchTheme.emerald;
      case 'reject_verification':
      case 'apply_sanction':
        return AdminStitchTheme.statusError;
      case 'update_config':
        return AdminStitchTheme.primary;
      case 'resolve_case':
        return AppTheme.orange600;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  String _selectedTabLabel() {
    for (final entry in _actionMap.entries) {
      if (entry.value == _actionFilter) return entry.key;
    }
    return '전체';
  }

  void _showDetail(Map<String, dynamic> log) {
    const dialogBg = Color(0xFF1E1C30);
    const titleColor = Color(0xFFF5F3FF);
    const subColor = Color(0xFF9CA3AF);
    const noteColor = Color(0xFF6B7280);
    const dividerColor = Color(0xFF3D3B56);

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '감사 로그 상세',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: dividerColor, height: 1),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _detailRow('일시', _formatDate(log['createdAt']?.toString() ?? ''), subColor, titleColor),
                      _detailRow('관리자', log['adminName']?.toString() ?? '-', subColor, titleColor),
                      _detailRow(
                        '액션',
                        log['actionLabel']?.toString() ?? log['action']?.toString() ?? '-',
                        subColor,
                        titleColor,
                      ),
                      _detailRow('대상', '${log['targetType']} / ${log['targetId']}', subColor, titleColor),
                      _detailRow('사유', log['reason']?.toString() ?? '-', subColor, titleColor),
                      if (log['beforeValue'] != null) ...[
                        const SizedBox(height: AdminStitchTheme.sectionGap),
                        const Text(
                          '변경 전',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: noteColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          const JsonEncoder.withIndent('  ').convert(log['beforeValue']),
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: subColor),
                        ),
                      ],
                      if (log['afterValue'] != null) ...[
                        const SizedBox(height: AdminStitchTheme.sectionGap),
                        const Text(
                          '변경 후',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: noteColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          const JsonEncoder.withIndent('  ').convert(log['afterValue']),
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: subColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: subColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminStitchTheme.stackTight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: labelColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '감사 로그',
            subtitle: '관리자 조치 이력을 추적합니다 (읽기 전용 · 수정 불가)',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '관리자, 사유, 대상 ID 검색...',
            onChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() => _search = value);
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _loadLogs();
                });
              });
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _actionTabs,
            selectedTab: _selectedTabLabel(),
            onTabChanged: (tab) {
              setState(() {
                _actionFilter = _actionMap[tab] ?? 'all';
              });
              _loadLogs();
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _logs.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_hasLoadError) {
      return AdminStitchListStateSliver.error(
        onRetry: () => _loadLogs(),
      );
    }
    if (_logs.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '감사 로그가 없습니다',
        emptyIcon: Icons.history,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _logs.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, index) {
          final log = _logs[index] as Map<String, dynamic>;
          final action = log['action']?.toString() ?? '';
          final actionLabel =
              log['actionLabel']?.toString() ?? action;
          final chipColor = _actionChipColor(action);
          final target =
              '${log['targetType']} / ${log['targetId']}';
          final reason = log['reason']?.toString() ?? '-';

          return AdminStitchSimpleListCard(
            title: actionLabel,
            subtitle:
                '${_formatDate(log['createdAt']?.toString() ?? '')} · ${log['adminName']?.toString() ?? '-'} · $target · $reason',
            icon: Icons.history,
            iconColor: chipColor,
            onTap: () => _showDetail(log),
            trailing: const Icon(
              Icons.chevron_right,
              color: AdminStitchTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }
}
