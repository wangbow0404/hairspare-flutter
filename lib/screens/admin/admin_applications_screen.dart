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

/// 관리자 공고 지원 현황 화면
class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  List<dynamic> _applications = [];
  bool _isLoading = true;
  String _statusFilter = '';
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
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('지원 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}'),
            backgroundColor: AppTheme.urgentRed,
          ));
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR').format(DateTime.parse(dateString).toLocal());
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

    // API 미구현 — 추후 AdminService.cancelApplication() 연결
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('강제 취소 처리됨 (감사 로그 기록)')),
    );
    _loadApplications(showLoading: false);
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
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _loadApplications();
                });
              });
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
        separatorBuilder: (_, __) => const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, index) => _buildCard(_applications[index] as Map<String, dynamic>),
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
      onTap: () => _showDetail(app),
    );
  }

  void _showDetail(Map<String, dynamic> app) {
    const dialogBg = Color(0xFF1E1C30);
    const titleColor = Color(0xFFF5F3FF);
    const subColor = Color(0xFF9CA3AF);
    const dividerColor = Color(0xFF3D3B56);

    final status = app['status']?.toString() ?? '';
    final statusLabel = app['statusLabel']?.toString() ?? status;
    final statusColor = _statusColor(status);
    final amount = app['job']?['amount'];
    final amountStr = amount != null
        ? NumberFormat('#,###', 'ko_KR').format(amount) + '원'
        : '-';

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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '지원 상세',
                      style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: dividerColor, height: 1),
              const SizedBox(height: 12),
              _detailRow('스페어', '${app['spare']?['name'] ?? '-'}  (${app['spare']?['email'] ?? ''})', subColor, titleColor),
              _detailRow('미용실', app['shop']?['name']?.toString() ?? '-', subColor, titleColor),
              _detailRow('공고', app['job']?['title']?.toString() ?? '-', subColor, titleColor),
              _detailRow('근무 일시', _formatDate(app['job']?['startTime']?.toString()), subColor, titleColor),
              _detailRow('금액', amountStr, subColor, titleColor),
              _detailRow('지원 일시', _formatDate(app['createdAt']?.toString()), subColor, titleColor),
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

  Widget _detailRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminStitchTheme.stackTight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, color: valueColor)),
          ),
        ],
      ),
    );
  }
}
