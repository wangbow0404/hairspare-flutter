import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/admin_member_role.dart';
import '../../utils/admin_member_role_style.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 회원 관리 화면 (Stitch 카드 리스트)
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _users = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _search = '';
  String _memberCategoryFilter = '';
  String _statusFilter = ''; // '' | active | suspended | deleted
  String _sort = 'latest';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _roleTabs = AdminMemberRole.filterTabs;

  // 상태 드롭다운 (value -> 표시명)
  static const _statusOptions = {
    '': '전체',
    'active': '정상',
    'suspended': '정지됨',
    'deleted': '삭제됨',
  };

  // 정렬 드롭다운 (value -> 표시명)
  static const _sortOptions = {
    'latest': '최신가입순',
    'oldest': '오래된가입순',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadUsers(showLoading: false);
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

  Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final result = await _adminService.getUsers(
        memberCategory:
            _memberCategoryFilter.isEmpty ? null : _memberCategoryFilter,
        search: _search.isEmpty ? null : _search,
        accountStatus: _statusFilter.isEmpty ? null : _statusFilter,
        sort: _sort,
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _users = result['users'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? 0;
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
                '회원 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
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
      return DateFormat('yyyy년 M월 d일', 'ko_KR').format(DateTime.parse(dateString));
    } catch (_) {
      return dateString;
    }
  }

  String _selectedRoleTab() => AdminMemberRole.queryToTab(_memberCategoryFilter);

  String _roleLabelForCard(Map<String, dynamic> user) =>
      AdminMemberRole.badgeLabel(user);

  Color _roleColorForCard(Map<String, dynamic> user) =>
      AdminMemberRoleStyle.badgeBackground(user);

  bool _isUserActive(Map<String, dynamic> user) {
    final status =
        user['status']?.toString() ?? user['accountStatus']?.toString();
    return status != 'suspended' && status != 'inactive';
  }

  Future<void> _openUserDetail(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null) return;
    await context.push(AppRoutes.adminUserDetail(userId), extra: user);
    if (!mounted) return;
    _loadUsers(showLoading: false);
  }

  Future<void> _showUserActions(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null) return;

    final isActive = _isUserActive(user);
    const sheetBg = Color(0xFF1E1C30);
    const sheetTitle = Color(0xFFF5F3FF);
    const sheetSub = Color(0xFF9CA3AF);
    const divColor = Color(0xFF3D3B56);

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: sheetBg,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: sheetSub),
              title: Text(
                user['name']?.toString() ?? '회원',
                style: const TextStyle(color: sheetTitle, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                user['email']?.toString() ?? '',
                style: const TextStyle(color: sheetSub, fontSize: 12),
              ),
            ),
            const Divider(height: 1, color: divColor),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: sheetSub),
              title: const Text('상세 보기', style: TextStyle(color: sheetTitle)),
              onTap: () => Navigator.pop(context, 'detail'),
            ),
            if (isActive)
              ListTile(
                leading: Icon(Icons.block, color: AppTheme.urgentRed),
                title: Text(
                  '계정 정지',
                  style: TextStyle(color: AppTheme.urgentRed),
                ),
                onTap: () => Navigator.pop(context, 'suspend'),
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: sheetSub),
                title: const Text('정지 해제', style: TextStyle(color: sheetTitle)),
                onTap: () => Navigator.pop(context, 'unsuspend'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case 'detail':
        await _openUserDetail(user);
      case 'suspend':
        await _suspendUser(user);
      case 'unsuspend':
        await _unsuspendUser(user);
    }
  }

  Future<void> _suspendUser(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null) return;

    final reason = await AdminActionDialog.show(
      context,
      title: '회원 정지',
      confirmLabel: '정지',
      summary: user['name']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;

    try {
      await _adminService.suspendUser(userId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user['name']} 회원이 정지되었습니다')),
      );
      _loadUsers(showLoading: false);
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

  Future<void> _unsuspendUser(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null) return;

    final reason = await AdminActionDialog.show(
      context,
      title: '정지 해제',
      confirmLabel: '해제',
      summary: user['name']?.toString(),
    );
    if (reason == null || !mounted) return;

    try {
      await _adminService.unsuspendUser(userId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user['name']} 회원 정지가 해제되었습니다')),
      );
      _loadUsers(showLoading: false);
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
                  title: '회원 관리',
                  subtitle: '계정·역할·상태를 관리합니다.',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchSearchField(
                  controller: _searchController,
                  hint: '이름, 이메일로 검색...',
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    setState(() {
                      _search = value;
                      _currentPage = 1;
                    });
                    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _loadUsers();
                      });
                    });
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _roleTabs,
                  selectedTab: _selectedRoleTab(),
                  onTabChanged: (tab) {
                    setState(() {
                      _memberCategoryFilter = AdminMemberRole.filterToQuery(tab);
                      _currentPage = 1;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.stackTight),
                Row(
                  children: [
                    Expanded(
                      child: AdminStitchFilterDropdownBox(
                        label: '상태',
                        value: _statusFilter,
                        options: _statusOptions,
                        onChanged: (v) {
                          setState(() {
                            _statusFilter = v;
                            _currentPage = 1;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: AdminStitchTheme.stackTight),
                    Expanded(
                      child: AdminStitchFilterDropdownBox(
                        label: '정렬',
                        value: _sort,
                        options: _sortOptions,
                        onChanged: (v) {
                          setState(() {
                            _sort = v;
                            _currentPage = 1;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                if (!_isLoading)
                  Text(
                    '총 $_total명',
                    style: AdminStitchTheme.bodyMd.copyWith(
                      color: AdminStitchTheme.textSecondary,
                    ),
                  ),
                const SizedBox(height: AdminStitchTheme.stackTight),
              ],
            ),
          ),
        ),
        if (_isLoading && _users.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_hasLoadError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AdminStitchTheme.textSecondary),
                  const SizedBox(height: 12),
                  const Text('회원 목록을 불러오지 못했습니다'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _loadUsers(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          )
        else if (_users.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AdminStitchTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty || _memberCategoryFilter.isNotEmpty
                        ? '검색·필터 조건에 맞는 회원이 없습니다'
                        : '회원이 없습니다',
                  ),
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
              itemCount: _users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildUserCard(_users[index] as Map<String, dynamic>),
            ),
          ),
        if (_totalPages > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
              child: _buildPagination(),
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id']?.toString();
    final isActive = _isUserActive(user);

    return AdminStitchUserCard(
      name: user['name']?.toString() ?? '-',
      email: user['email']?.toString() ?? user['phone']?.toString() ?? '-',
      roleLabel: _roleLabelForCard(user),
      roleColor: _roleColorForCard(user),
      joinedLabel: '가입 ${_formatDate(user['createdAt']?.toString() ?? '')}',
      isActive: isActive,
      avatarUrl: user['avatarUrl']?.toString(),
      initials: (user['name']?.toString() ?? '?').characters.first,
      onTap: userId != null ? () => _openUserDetail(user) : null,
      onMore: userId != null ? () => _showUserActions(user) : null,
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(top: AdminStitchTheme.sectionGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadUsers();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '$_currentPage / $_totalPages',
            style: AdminStitchTheme.bodyMd,
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadUsers();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
