import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 공고 관리 화면
class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String _search = '';
  String _statusFilter = '';
  String _urgentFilter = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  static const _statusTabs = ['전체', '게시중', '마감', '완료'];
  static const _statusMap = {
    '전체': '',
    '게시중': 'published',
    '마감': 'closed',
    '완료': 'completed',
  };

  static const _urgentTabs = ['전체', '급구', '일반'];
  static const _urgentMap = {
    '전체': '',
    '급구': 'true',
    '일반': 'false',
  };

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadJobs(showLoading: false);
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

  Future<void> _loadJobs({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await _adminService.getJobs(
        status: _statusFilter.isEmpty ? null : _statusFilter,
        isUrgent: _urgentFilter.isEmpty ? null : (_urgentFilter == 'true'),
        search: _search.isEmpty ? null : _search,
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _jobs = result['jobs'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'published':
        return '게시중';
      case 'closed':
        return '마감';
      case 'completed':
        return '완료';
      default:
        return status;
    }
  }

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '전체';
  }

  String _selectedUrgentTab() {
    for (final entry in _urgentMap.entries) {
      if (entry.value == _urgentFilter) return entry.key;
    }
    return '전체';
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '공고 관리',
            subtitle: '전체 공고를 조회하고 관리할 수 있습니다',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '공고 제목, 미용실명으로 검색...',
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
                  _loadJobs();
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
              _loadJobs();
            },
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchFilterChips(
            tabs: _urgentTabs,
            selectedTab: _selectedUrgentTab(),
            onTabChanged: (tab) {
              setState(() {
                _urgentFilter = _urgentMap[tab] ?? '';
                _currentPage = 1;
              });
              _loadJobs();
            },
          ),
          if (_total > 0) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            Text(
              '총 $_total개',
              style: AdminStitchTheme.bodyMd.copyWith(
                color: AdminStitchTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jobs.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_jobs.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '공고가 없습니다',
        emptyIcon: Icons.work_outline,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _jobs.length) {
              return _buildPagination();
            }
            final job = _jobs[index] as Map<String, dynamic>;
            final jobId = job['id']?.toString();
            final shopName = job['shop']?['name']?.toString() ?? '-';
            final regionName = job['region']?['name']?.toString() ?? '-';
            final amount = _formatCurrency((job['amount'] ?? 0) as int);
            final statusLabel = _getStatusLabel(job['status']?.toString() ?? '');

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _jobs.length - 1
                    ? AdminStitchTheme.sectionGap
                    : 0,
              ),
              child: AdminStitchSimpleListCard(
                title: job['title']?.toString() ?? '제목 없음',
                subtitle: '$shopName · $regionName · $amount · $statusLabel',
                icon: Icons.work_outline,
                trailing: job['isUrgent'] == true
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
                        ),
                        child: const Text(
                          '급구',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.urgentRed,
                          ),
                        ),
                      )
                    : null,
                onTap: jobId != null
                    ? () => context.push(
                          AppRoutes.adminJobDetail(jobId),
                          extra: job,
                        )
                    : null,
              ),
            );
          },
          childCount: _jobs.length + (_totalPages > 1 ? 1 : 0),
        ),
      ),
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
                    _loadJobs();
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
                    _loadJobs();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
