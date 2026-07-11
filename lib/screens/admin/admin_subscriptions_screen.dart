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
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M11. 구독·크리에이터 관리
class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  static const _sectionTabs = ['크리에이터', '구독 목록'];

  String _sectionTab = '크리에이터';
  List<dynamic> _creators = [];
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _search = '';
  String _creatorFilter = '';
  String _subscriptionFilter = '';
  String _creatorSort = 'latest';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _creatorFilterTabs = ['전체', '인증됨', '미인증'];
  static const _creatorFilterMap = {
    '전체': '',
    '인증됨': 'verified',
    '미인증': 'unverified',
  };

  static const _subscriptionFilterTabs = ['전체', '활성', '해지'];
  static const _subscriptionFilterMap = {
    '전체': '',
    '활성': 'active',
    '해지': 'inactive',
  };

  static const _sortOptions = {'latest': '최신순', 'subscribers': '구독자순'};

  @override
  void initState() {
    super.initState();
    _load();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _load(showLoading: false);
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

  bool get _isCreatorTab => _sectionTab == '크리에이터';

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      if (_isCreatorTab) {
        final result = await _adminService.getCreators(
          search: _search.isEmpty ? null : _search,
          verified: _creatorFilter.isEmpty ? null : _creatorFilter,
          sort: _creatorSort,
          page: _currentPage,
        );
        if (!mounted) return;
        setState(() {
          _creators = result['creators'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? _creators.length;
          _isLoading = false;
          _hasLoadError = false;
        });
      } else {
        final result = await _adminService.getSubscriptions(
          search: _search.isEmpty ? null : _search,
          status: _subscriptionFilter.isEmpty ? null : _subscriptionFilter,
          page: _currentPage,
        );
        if (!mounted) return;
        setState(() {
          _subscriptions = result['subscriptions'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? _subscriptions.length;
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (showLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isCreatorTab ? '크리에이터' : '구독'} 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
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

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('yyyy년 M월 d일', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _selectedCreatorFilterTab() {
    for (final e in _creatorFilterMap.entries) {
      if (e.value == _creatorFilter) return e.key;
    }
    return '전체';
  }

  String _selectedSubscriptionFilterTab() {
    for (final e in _subscriptionFilterMap.entries) {
      if (e.value == _subscriptionFilter) return e.key;
    }
    return '전체';
  }

  Future<void> _openCreatorDetail(Map<String, dynamic> creator) async {
    final id = creator['id']?.toString();
    if (id == null) return;
    await context.push(AppRoutes.adminCreatorDetail(id), extra: creator);
    if (!mounted) return;
    _load(showLoading: false);
  }

  Future<void> _openSubscriptionDetail(Map<String, dynamic> subscription) async {
    final id = subscription['id']?.toString();
    if (id == null) return;
    await context.push(AppRoutes.adminSubscriptionDetail(id), extra: subscription);
    if (!mounted) return;
    _load(showLoading: false);
  }

  Future<void> _verifyCreator(Map<String, dynamic> creator) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '크리에이터 인증',
      confirmLabel: '인증',
      summary: creator['name']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.verifyCreator(
        creator['id'].toString(),
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('크리에이터 인증 완료')),
      );
      _load(showLoading: false);
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

  Future<void> _showCreatorActions(Map<String, dynamic> creator) async {
    final verified = creator['verified'] == true;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1E1C30),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF9CA3AF)),
              title: Text(
                creator['name']?.toString() ?? '크리에이터',
                style: const TextStyle(
                  color: Color(0xFFF5F3FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '구독자 ${creator['subscriberCount'] ?? 0} · 영상 ${creator['videoCount'] ?? 0}',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF3D3B56)),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Color(0xFF9CA3AF)),
              title: const Text('상세 보기', style: TextStyle(color: Color(0xFFF5F3FF))),
              onTap: () => Navigator.pop(context, 'detail'),
            ),
            if (!verified)
              ListTile(
                leading: Icon(Icons.verified, color: AppTheme.primaryPurple),
                title: Text('인증하기', style: TextStyle(color: AppTheme.primaryPurple)),
                onTap: () => Navigator.pop(context, 'verify'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'detail':
        await _openCreatorDetail(creator);
      case 'verify':
        await _verifyCreator(creator);
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
                  title: '구독·크리에이터',
                  subtitle: '구독 현황 및 크리에이터 인증을 관리합니다.',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchSearchField(
                  controller: _searchController,
                  hint: _isCreatorTab
                      ? '크리에이터 이름으로 검색...'
                      : '구독자·크리에이터로 검색...',
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    setState(() {
                      _search = value;
                      _currentPage = 1;
                    });
                    _searchDebounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        if (!mounted) return;
                        _load();
                      },
                    );
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _sectionTabs,
                  selectedTab: _sectionTab,
                  onTabChanged: (tab) {
                    setState(() {
                      _sectionTab = tab;
                      _currentPage = 1;
                      _search = '';
                      _searchController.clear();
                    });
                    _load();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.stackTight),
                if (_isCreatorTab)
                  AdminStitchFilterChips(
                    tabs: _creatorFilterTabs,
                    selectedTab: _selectedCreatorFilterTab(),
                    onTabChanged: (tab) {
                      setState(() {
                        _creatorFilter = _creatorFilterMap[tab] ?? '';
                        _currentPage = 1;
                      });
                      _load();
                    },
                  )
                else
                  AdminStitchFilterChips(
                    tabs: _subscriptionFilterTabs,
                    selectedTab: _selectedSubscriptionFilterTab(),
                    onTabChanged: (tab) {
                      setState(() {
                        _subscriptionFilter = _subscriptionFilterMap[tab] ?? '';
                        _currentPage = 1;
                      });
                      _load();
                    },
                  ),
                if (_isCreatorTab) ...[
                  const SizedBox(height: AdminStitchTheme.stackTight),
                  AdminStitchFilterDropdownBox(
                    label: '정렬',
                    value: _creatorSort,
                    options: _sortOptions,
                    onChanged: (v) {
                      setState(() {
                        _creatorSort = v;
                        _currentPage = 1;
                      });
                      _load();
                    },
                  ),
                ],
                const SizedBox(height: AdminStitchTheme.sectionGap),
                if (!_isLoading)
                  Text(
                    '총 $_total${_isCreatorTab ? '명' : '건'}',
                    style: AdminStitchTheme.bodyMd.copyWith(
                      color: AdminStitchTheme.textSecondary,
                    ),
                  ),
                const SizedBox(height: AdminStitchTheme.stackTight),
              ],
            ),
          ),
        ),
        if (_isLoading && (_isCreatorTab ? _creators.isEmpty : _subscriptions.isEmpty))
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
                  const Text('목록을 불러오지 못했습니다'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _load(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          )
        else if (_isCreatorTab && _creators.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_outlined, size: 64, color: AdminStitchTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty || _creatorFilter.isNotEmpty
                        ? '조건에 맞는 크리에이터가 없습니다'
                        : '등록된 크리에이터가 없습니다',
                  ),
                ],
              ),
            ),
          )
        else if (!_isCreatorTab && _subscriptions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.subscriptions_outlined, size: 64, color: AdminStitchTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty || _subscriptionFilter.isNotEmpty
                        ? '조건에 맞는 구독이 없습니다'
                        : '구독 내역이 없습니다',
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AdminStitchTheme.pageMargin,
              0,
              AdminStitchTheme.pageMargin,
              AdminStitchTheme.pageMargin,
            ),
            sliver: SliverList.separated(
              itemCount: _isCreatorTab ? _creators.length : _subscriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _isCreatorTab
                  ? _buildCreatorCard(_creators[index] as Map<String, dynamic>)
                  : _buildSubscriptionCard(
                      _subscriptions[index] as Map<String, dynamic>,
                    ),
            ),
          ),
        if (_totalPages > 1)
          SliverToBoxAdapter(child: _buildPagination()),
      ],
    );
  }

  Widget _buildCreatorCard(Map<String, dynamic> creator) {
    final verified = creator['verified'] == true;
    return AdminStitchUserCard(
      name: creator['name']?.toString() ?? '-',
      email:
          '구독자 ${creator['subscriberCount'] ?? 0} · 영상 ${creator['videoCount'] ?? 0} · 좋아요 ${creator['likeCount'] ?? 0}',
      roleLabel: verified ? '인증됨' : '미인증',
      roleColor: verified ? AppTheme.green600 : AdminStitchTheme.textSecondary,
      joinedLabel: '등록 ${_formatDate(creator['createdAt']?.toString())}',
      isActive: true,
      avatarUrl: creator['avatarUrl']?.toString(),
      initials: (creator['name']?.toString() ?? '?').characters.first,
      onTap: () => _openCreatorDetail(creator),
      onMore: () => _showCreatorActions(creator),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final isActive = subscription['isActive'] == true;
    final amount = subscription['amount'];
    final amountLabel = amount is num && amount > 0
        ? NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount)
        : '무료 구독';

    return AdminStitchSimpleListCard(
      title: '${subscription['userName']} → ${subscription['creatorName']}',
      subtitle:
          '$amountLabel · 시작 ${_formatDate(subscription['startedAt']?.toString())}',
      icon: Icons.subscriptions_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.green50 : AdminStitchTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isActive ? '활성' : '해지',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.green600 : AdminStitchTheme.textSecondary,
          ),
        ),
      ),
      onTap: () => _openSubscriptionDetail(subscription),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _load();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_currentPage / $_totalPages', style: AdminStitchTheme.bodyMd),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _load();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
