import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_screen_scaffold.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M2. 인증 심사 큐 화면
class AdminVerificationsScreen extends StatefulWidget {
  const AdminVerificationsScreen({super.key});

  @override
  State<AdminVerificationsScreen> createState() =>
      _AdminVerificationsScreenState();
}

class _AdminVerificationsScreenState extends State<AdminVerificationsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _items = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _statusFilter = 'pending';
  String _typeFilter = 'all';
  Timer? _updateTimer;

  static const _statusTabs = ['대기', '승인', '반려', '전체'];
  static const _statusMap = {
    '대기': 'pending',
    '승인': 'approved',
    '반려': 'rejected',
    '전체': 'all',
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadItems(showLoading: false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadItems({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final result = await _adminService.getVerifications(
        status: _statusFilter == 'all' ? null : _statusFilter,
        type: _typeFilter == 'all' ? null : _typeFilter,
      );
      if (mounted) {
        setState(() {
          _items = result['verifications'] ?? [];
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
                '인증 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
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
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR')
          .format(DateTime.parse(dateString).toLocal());
    } catch (_) {
      return dateString;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.orange600;
      case 'approved':
        return AppTheme.green600;
      case 'rejected':
        return AppTheme.urgentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return '대기';
      case 'approved':
        return '승인';
      case 'rejected':
        return '반려';
      default:
        return status;
    }
  }

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '대기';
  }

  Future<void> _approve(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인증 승인'),
        content: Text('${item['userName']}님의 ${item['typeLabel']}을(를) 승인하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('승인')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _adminService.approveVerification(
        item['id'].toString(),
        note: '관리자 승인',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증이 승인되었습니다 (감사 로그 기록)')),
      );
      _loadItems(showLoading: false);
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

  Future<void> _reject(Map<String, dynamic> item) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인증 반려'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item['userName']}님의 ${item['typeLabel']}을(를) 반려합니다.'),
            const SizedBox(height: AppTheme.spacing3),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '반려 사유 (필수)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
            child: const Text('반려'),
          ),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || reason.isEmpty || !mounted) return;

    try {
      await _adminService.rejectVerification(
        item['id'].toString(),
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증이 반려되었습니다 (감사 로그 기록)')),
      );
      _loadItems(showLoading: false);
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
    return AdminScreenScaffold(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminPageHeader(
            title: '인증 심사',
            subtitle: '본인인증·사업자등록·포트폴리오 심사 큐',
          ),
          const SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '이름, 이메일 검색...',
            filterTabs: _statusTabs,
            selectedTab: _selectedStatusTab(),
            onTabChanged: (tab) {
              setState(() => _statusFilter = _statusMap[tab] ?? 'pending');
              _loadItems();
            },
            filterDropdown: DropdownButton<String>(
              value: _typeFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('전체 유형')),
                DropdownMenuItem(value: 'identity', child: Text('본인인증')),
                DropdownMenuItem(value: 'business', child: Text('사업자등록')),
                DropdownMenuItem(value: 'portfolio', child: Text('포트폴리오')),
              ],
              onChanged: (value) {
                setState(() => _typeFilter = value ?? 'all');
                _loadItems();
              },
            ),
          ),
        ],
      ),
      body: AdminTableCard(
        child: _isLoading && _items.isEmpty
            ? const AdminTableSkeleton(rowCount: 6, columnCount: 6)
            : _hasLoadError
                ? _buildErrorState()
                : _items.isEmpty
                    ? _buildEmptyState()
                    : _buildTable(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: FilledButton.icon(
        onPressed: () => _loadItems(),
        icon: const Icon(Icons.refresh),
        label: const Text('다시 시도'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 64, color: AppTheme.textTertiary),
          SizedBox(height: AppTheme.spacing4),
          Text('해당 조건의 인증 요청이 없습니다'),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdminTableHeader(
              headers: ['회원', '유형', '역할', '상태', '제출일', '처리'],
              flexValues: [2, 1, 1, 1, 1, 2],
            ),
            SizedBox(
              height: 480,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index] as Map<String, dynamic>;
                  final status = item['status']?.toString() ?? '';
                  final statusColor = _statusColor(status);
                  final isPending = status == 'pending';
                  return InkWell(
                    onTap: () => context.push(
                      AppRoutes.adminVerificationDetail(item['id'].toString()),
                      extra: item,
                    ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['userName']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                item['userEmail']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item['typeLabel']?.toString() ?? '-',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item['userRole']?.toString() ?? '-',
                            style: const TextStyle(fontSize: 12),
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
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            _formatDate(item['submittedAt']?.toString() ?? ''),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: isPending
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FilledButton(
                                      onPressed: () => _approve(item),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.green600,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing3,
                                        ),
                                      ),
                                      child: const Text('승인', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: AppTheme.spacing2),
                                    OutlinedButton(
                                      onPressed: () => _reject(item),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.urgentRed,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing3,
                                        ),
                                      ),
                                      child: const Text('반려', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                )
                              : Text(
                                  item['rejectReason']?.toString() ?? '처리 완료',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
