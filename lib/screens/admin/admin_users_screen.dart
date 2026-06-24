import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
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
  String _roleFilter = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _roleTabs = ['전체', '스페어', '미용실', '디자이너'];
  static const _roleMap = {
    '전체': '',
    '스페어': 'spare',
    '미용실': 'shop',
    '디자이너': 'seller',
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
        role: _roleFilter.isEmpty ? null : _roleFilter,
        search: _search.isEmpty ? null : _search,
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

  String _getRoleLabel(String role) {
    switch (role) {
      case 'spare':
        return '스페어';
      case 'shop':
        return '미용실';
      case 'seller':
        return '디자이너';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'shop':
        return AdminStitchTheme.secondaryContainer;
      case 'spare':
      case 'seller':
      default:
        return AdminStitchTheme.surfaceVariant;
    }
  }

  String _selectedRoleTab() {
    for (final entry in _roleMap.entries) {
      if (entry.value == _roleFilter) return entry.key;
    }
    return '전체';
  }

  bool _isUserActive(Map<String, dynamic> user) {
    final status = user['status']?.toString();
    return status != 'suspended' && status != 'inactive';
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
                      if (mounted) _loadUsers();
                    });
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _roleTabs,
                  selectedTab: _selectedRoleTab(),
                  onTabChanged: (tab) {
                    setState(() {
                      _roleFilter = _roleMap[tab] ?? '';
                      _currentPage = 1;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                if (_total > 0)
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
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AdminStitchTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('회원이 없습니다'),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AdminStitchTheme.pageMargin),
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
    final role = user['role']?.toString() ?? '';
    final isActive = _isUserActive(user);

    return AdminStitchUserCard(
      name: user['name']?.toString() ?? '-',
      email: user['email']?.toString() ?? user['phone']?.toString() ?? '-',
      roleLabel: _getRoleLabel(role),
      roleColor: _getRoleColor(role),
      joinedLabel: '가입 ${_formatDate(user['createdAt']?.toString() ?? '')}',
      isActive: isActive,
      avatarUrl: user['avatarUrl']?.toString(),
      initials: (user['name']?.toString() ?? '?').characters.first,
      onTap: userId != null
          ? () => context.push(AppRoutes.adminUserDetail(userId), extra: user)
          : null,
      onMore: userId != null
          ? () => context.push(AppRoutes.adminUserDetail(userId), extra: user)
          : null,
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
