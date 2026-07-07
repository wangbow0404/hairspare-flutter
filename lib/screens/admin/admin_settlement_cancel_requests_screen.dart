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

/// 샵이 이미 정산 완료한 근무의 취소를 요청한 건을 검토하는 화면.
class AdminSettlementCancelRequestsScreen extends StatefulWidget {
  const AdminSettlementCancelRequestsScreen({super.key});

  @override
  State<AdminSettlementCancelRequestsScreen> createState() =>
      _AdminSettlementCancelRequestsScreenState();
}

class _AdminSettlementCancelRequestsScreenState
    extends State<AdminSettlementCancelRequestsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _requests = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _statusFilter = 'pending';
  Timer? _updateTimer;

  static const _statusTabs = ['대기중', '승인됨', '반려됨'];
  static const _statusMap = {
    '대기중': 'pending',
    '승인됨': 'approved',
    '반려됨': 'rejected',
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
      final result = await _adminService.getSettlementCancelRequests(
        status: _statusFilter,
      );
      if (mounted) {
        setState(() {
          _requests = result;
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

  Future<void> _approve(Map<String, dynamic> req) async {
    final note = await AdminActionDialog.show(
      context,
      title: '정산취소 요청 승인',
      confirmLabel: '승인',
      summary:
          '${req['shopName'] ?? '샵'} → ${req['spareName'] ?? '스페어'}\n사유: ${req['reason'] ?? ''}',
      reasonLabel: '관리자 메모 (선택)',
    );
    if (note == null || !mounted) return;
    try {
      await _adminService.approveSettlementCancelRequest(
        req['id'].toString(),
        adminNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('승인 처리했습니다. 스케줄이 취소되었습니다.')),
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

  Future<void> _reject(Map<String, dynamic> req) async {
    final note = await AdminActionDialog.show(
      context,
      title: '정산취소 요청 반려',
      confirmLabel: '반려',
      summary:
          '${req['shopName'] ?? '샵'} → ${req['spareName'] ?? '스페어'}\n사유: ${req['reason'] ?? ''}',
      reasonLabel: '반려 사유',
      isDanger: true,
    );
    if (note == null || !mounted) return;
    try {
      await _adminService.rejectSettlementCancelRequest(
        req['id'].toString(),
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
                  title: '정산취소 요청',
                  subtitle: '샵이 이미 정산한 근무의 취소를 요청한 건을 검토합니다.',
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
        if (_isLoading && _requests.isEmpty)
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
        else if (_requests.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fact_check_outlined,
                      size: 64, color: AdminStitchTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('해당 조건의 요청이 없습니다'),
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
              itemCount: _requests.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AdminStitchTheme.sectionGap),
              itemBuilder: (context, index) =>
                  _buildCard(_requests[index] as Map<String, dynamic>),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> req) {
    final isPending = req['status'] == 'pending';
    final createdAt = DateTime.tryParse(req['createdAt']?.toString() ?? '');
    final createdLabel = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toLocal())
        : '';

    return AdminStitchSimpleListCard(
      icon: Icons.receipt_long_outlined,
      iconColor: isPending ? AdminStitchTheme.secondary : AdminStitchTheme.textSecondary,
      title: req['jobTitle']?.toString() ?? '공고 정보 없음',
      subtitle: '${req['shopName'] ?? '샵'} → ${req['spareName'] ?? '스페어'}'
          ' · ${req['scheduleDate'] ?? ''}\n'
          '사유: ${req['reason'] ?? ''}\n'
          '요청일: $createdLabel',
      trailing: isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _reject(req),
                  child: const Text('반려'),
                ),
                FilledButton(
                  onPressed: () => _approve(req),
                  child: const Text('승인'),
                ),
              ],
            )
          : Text(
              req['status'] == 'approved' ? '승인됨' : '반려됨',
              style: TextStyle(
                color: req['status'] == 'approved'
                    ? AppTheme.green600
                    : AppTheme.urgentRed,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
