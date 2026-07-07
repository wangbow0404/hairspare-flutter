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

/// 샵이 신고한 노쇼 건을 검토하는 화면 — 확정 시에만 스페어 노쇼 횟수에 반영된다.
class AdminNoShowReportsScreen extends StatefulWidget {
  const AdminNoShowReportsScreen({super.key});

  @override
  State<AdminNoShowReportsScreen> createState() =>
      _AdminNoShowReportsScreenState();
}

class _AdminNoShowReportsScreenState extends State<AdminNoShowReportsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _reports = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _statusFilter = 'pending';
  Timer? _updateTimer;

  static const _statusTabs = ['대기중', '확정됨', '반려됨'];
  static const _statusMap = {
    '대기중': 'pending',
    '확정됨': 'confirmed',
    '반려됨': 'dismissed',
  };

  @override
  void initState() {
    super.initState();
    _load();
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      _load(showLoading: false);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }
    try {
      final result = await _adminService.getNoShowReports(status: _statusFilter);
      if (mounted) {
        setState(() {
          _reports = result;
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirm(Map<String, dynamic> report) async {
    final note = await AdminActionDialog.show(
      context,
      title: '노쇼 확정',
      confirmLabel: '확정',
      summary:
          '${report['shopName'] ?? '샵'} → ${report['spareName'] ?? '스페어'}\n사유: ${report['reason'] ?? ''}',
      reasonLabel: '관리자 메모 (선택)',
      isDanger: true,
    );
    if (note == null || !mounted) return;
    try {
      await _adminService.confirmNoShowReport(
        report['id'].toString(),
        adminNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('노쇼로 확정했습니다. 스페어 노쇼 횟수에 반영됩니다.')),
      );
      _load(showLoading: false);
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

  Future<void> _dismiss(Map<String, dynamic> report) async {
    final note = await AdminActionDialog.show(
      context,
      title: '노쇼 신고 반려',
      confirmLabel: '반려',
      summary:
          '${report['shopName'] ?? '샵'} → ${report['spareName'] ?? '스페어'}\n사유: ${report['reason'] ?? ''}',
      reasonLabel: '반려 사유',
    );
    if (note == null || !mounted) return;
    try {
      await _adminService.dismissNoShowReport(
        report['id'].toString(),
        adminNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반려 처리했습니다.')),
      );
      _load(showLoading: false);
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

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '대기중';
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
                  title: '노쇼 신고',
                  subtitle: '출근 시각이 지나도 체크인이 없어 샵이 신고한 건을 검토합니다.',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _statusTabs,
                  selectedTab: _selectedStatusTab(),
                  onTabChanged: (tab) {
                    setState(() => _statusFilter = _statusMap[tab] ?? 'pending');
                    _load();
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
                onPressed: () => _load(),
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
                  Icon(Icons.person_off_outlined,
                      size: 64, color: AdminStitchTheme.textSecondary),
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
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AdminStitchTheme.sectionGap),
              itemBuilder: (context, index) =>
                  _buildCard(_reports[index] as Map<String, dynamic>),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> report) {
    final isPending = report['status'] == 'pending';
    final createdAt = DateTime.tryParse(report['createdAt']?.toString() ?? '');
    final createdLabel = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toLocal())
        : '';

    return AdminStitchSimpleListCard(
      icon: Icons.person_off_outlined,
      iconColor: isPending ? AppTheme.urgentRed : AdminStitchTheme.textSecondary,
      title: report['jobTitle']?.toString() ?? '공고 정보 없음',
      subtitle: '${report['shopName'] ?? '샵'} → ${report['spareName'] ?? '스페어'}'
          ' · ${report['scheduleDate'] ?? ''} ${report['scheduleStartTime'] ?? ''}\n'
          '사유: ${report['reason'] ?? ''}\n'
          '신고일: $createdLabel',
      trailing: isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _dismiss(report),
                  child: const Text('반려'),
                ),
                FilledButton(
                  onPressed: () => _confirm(report),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
                  child: const Text('노쇼 확정'),
                ),
              ],
            )
          : Text(
              report['status'] == 'confirmed' ? '확정됨' : '반려됨',
              style: TextStyle(
                color: report['status'] == 'confirmed'
                    ? AppTheme.urgentRed
                    : AppTheme.green600,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
