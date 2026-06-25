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
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M2. 인증 심사 큐 화면 (Stitch 카드 리스트)
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
  String _searchQuery = '';
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _statusTabs = ['대기', '승인', '반려', '전체'];
  static const _statusMap = {
    '대기': 'pending',
    '승인': 'approved',
    '반려': 'rejected',
    '전체': 'all',
  };

  static const _typeTabs = ['전체 유형', '본인인증', '사업자등록', '포트폴리오'];
  static const _typeMap = {
    '전체 유형': 'all',
    '본인인증': 'identity',
    '사업자등록': 'business',
    '포트폴리오': 'portfolio',
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadItems(showLoading: false);
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
      var items = (result['verifications'] as List?) ?? [];

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        items = items.where((item) {
          final map = item as Map;
          final haystack = [
            map['userName'],
            map['userEmail'],
            map['typeLabel'],
            map['id'],
          ].join(' ').toLowerCase();
          return haystack.contains(q);
        }).toList();
      }

      if (mounted) {
        setState(() {
          _items = items;
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
                '인증 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
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

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return '심사 대기';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '반려됨';
      default:
        return status;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'spare':
        return '스페어';
      case 'shop':
        return '미용실';
      case 'seller':
        return '모델·판매자';
      default:
        return role;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'identity':
        return AdminStitchTheme.primary;
      case 'business':
        return const Color(0xFFEA580C);
      case 'portfolio':
        return AdminStitchTheme.secondary;
      default:
        return AdminStitchTheme.surfaceDim;
    }
  }

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '대기';
  }

  String _selectedTypeTab() {
    for (final entry in _typeMap.entries) {
      if (entry.value == _typeFilter) return entry.key;
    }
    return '전체 유형';
  }

  String _requestId(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final suffix = id.replaceAll(RegExp(r'[^0-9]'), '');
    final padded = suffix.padLeft(4, '0');
    return '#VER-$padded';
  }

  Future<void> _approve(Map<String, dynamic> item) async {
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '인증 승인',
      message: '${item['userName']}님의 ${item['typeLabel']}을(를) 승인하시겠습니까?',
      confirmLabel: '승인',
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
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _reject(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '인증 반려',
      confirmLabel: '반려',
      summary: '${item['userName']}님의 ${item['typeLabel']}을(를) 반려합니다.',
      reasonLabel: '반려 사유 (필수)',
      isDanger: true,
    );
    if (reason == null || !mounted) return;

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
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  void _openDetail(Map<String, dynamic> item) {
    context.push(
      AppRoutes.adminVerificationDetail(item['id'].toString()),
      extra: item,
    );
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
                  title: '인증 심사',
                  subtitle: '본인인증·사업자등록·포트폴리오 심사 큐',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchSearchField(
                  controller: _searchController,
                  hint: '이름, 이메일, 요청 ID 검색...',
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    setState(() => _searchQuery = value.trim());
                    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _loadItems(showLoading: false);
                      });
                    });
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _statusTabs,
                  selectedTab: _selectedStatusTab(),
                  onTabChanged: (tab) {
                    setState(() => _statusFilter = _statusMap[tab] ?? 'pending');
                    _loadItems();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.stackTight),
                AdminStitchFilterChips(
                  tabs: _typeTabs,
                  selectedTab: _selectedTypeTab(),
                  onTabChanged: (tab) {
                    setState(() => _typeFilter = _typeMap[tab] ?? 'all');
                    _loadItems();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
              ],
            ),
          ),
        ),
        if (_isLoading && _items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_hasLoadError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _loadItems(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ),
          )
        else if (_items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: AdminStitchTheme.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text('해당 조건의 인증 요청이 없습니다'),
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
              itemCount: _items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AdminStitchTheme.sectionGap),
              itemBuilder: (context, index) =>
                  _buildVerificationCard(_items[index] as Map<String, dynamic>),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? '';
    final type = item['type']?.toString() ?? '';
    final isPending = status == 'pending';

    return AdminStitchVerificationCard(
      requestId: _requestId(item),
      typeLabel: item['typeLabel']?.toString() ?? '-',
      userName: item['userName']?.toString() ?? '-',
      userEmail: item['userEmail']?.toString() ?? '-',
      roleLabel: _roleLabel(item['userRole']?.toString() ?? ''),
      statusLabel: _statusLabel(status),
      submittedAtLabel: _formatDate(item['submittedAt']?.toString() ?? ''),
      typeColor: _typeColor(type),
      isPending: isPending,
      isApproved: status == 'approved',
      onTap: () => _openDetail(item),
      onApprove: isPending ? () => _approve(item) : null,
      onReject: isPending ? () => _reject(item) : null,
    );
  }
}
