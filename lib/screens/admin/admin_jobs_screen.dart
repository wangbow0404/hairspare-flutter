import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';
import 'admin_job_detail_screen.dart';

/// 관리자 공고 관리 화면 (Next.js와 동일한 스타일)
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

  @override
  void initState() {
    super.initState();
    _loadJobs();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadJobs(showLoading: false);
      }
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
      setState(() {
        _isLoading = true;
      });
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
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
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

  Color _getStatusBadgeColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/jobs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '공고 관리',
            subtitle: '전체 공고를 조회하고 관리할 수 있습니다',
          ),
          SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '공고 제목, 미용실명으로 검색...',
            onSearchChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() {
                _search = value;
                _currentPage = 1;
              });
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) _loadJobs();
              });
            },
            filterDropdown: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _statusFilter.isEmpty ? null : _statusFilter,
                  hint: const Text('전체 상태'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('전체 상태')),
                    const DropdownMenuItem(value: 'published', child: Text('게시중')),
                    const DropdownMenuItem(value: 'closed', child: Text('마감')),
                    const DropdownMenuItem(value: 'completed', child: Text('완료')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value ?? '';
                      _currentPage = 1;
                    });
                    _loadJobs();
                  },
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(width: AppTheme.spacing2),
                DropdownButton<String>(
                  value: _urgentFilter.isEmpty ? null : _urgentFilter,
                  hint: const Text('전체'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('전체')),
                    const DropdownMenuItem(value: 'true', child: Text('급구만')),
                    const DropdownMenuItem(value: 'false', child: Text('일반만')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _urgentFilter = value ?? '';
                      _currentPage = 1;
                    });
                    _loadJobs();
                  },
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 600,
            child: AdminTableCard(
              child: _isLoading && _jobs.isEmpty
                  ? const AdminTableSkeleton(rowCount: 8, columnCount: 7)
                  : _jobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.work_outline, size: 64, color: AppTheme.textTertiary),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '공고가 없습니다',
                                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 900),
                            child: Column(
                              children: [
                                AdminTableHeader(
                                  headers: ['공고 정보', '미용실', '지역', '금액', '지원/스케줄', '상태', '등록일'],
                                  flexValues: [2, 1, 1, 1, 1, 1, 1],
                                ),
                            // 테이블 본문
                            Expanded(
                              child: ListView.builder(
                                itemCount: _jobs.length,
                                itemBuilder: (context, index) {
                                  final job = _jobs[index];
                                  final jobId = job['id']?.toString();
                                  return InkWell(
                                    onTap: jobId != null
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => AdminJobDetailScreen(
                                                  jobId: jobId,
                                                  initialData: job,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing4,
                                      vertical: AppTheme.spacing3,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: AppTheme.adminPurple100.withOpacity(0.5)),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  job['title'] ?? '제목 없음',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (job['isUrgent'] == true) ...[
                                                SizedBox(width: AppTheme.spacing1),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: AppTheme.spacing2,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.urgentRed.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                                  ),
                                                  child: const Text(
                                                    '급구',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.urgentRed,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (job['isPremium'] == true) ...[
                                                SizedBox(width: AppTheme.spacing1),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: AppTheme.spacing2,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryPurple.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                                  ),
                                                  child: Text(
                                                    '프리미엄',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.primaryPurple,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            job['shop']?['name'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            job['region']?['name'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatCurrency((job['amount'] ?? 0) as int),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '지원 ${job['_count']?['applications'] ?? 0} · 스케줄 ${job['_count']?['schedules'] ?? 0}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppTheme.spacing2,
                                              vertical: AppTheme.spacing1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBadgeColor(job['status'] ?? '').withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              _getStatusLabel(job['status'] ?? ''),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusBadgeColor(job['status'] ?? ''),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatDate(job['createdAt'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
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
                            if (_totalPages > 1)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing6,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.adminPurple50.withOpacity(0.3),
                                      AppTheme.adminPink50.withOpacity(0.3),
                                    ],
                                  ),
                                  border: Border(
                                    top: BorderSide(color: AppTheme.adminPurple100, width: 2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 $_total개 중 ${(_currentPage - 1) * 20 + 1}-${(_currentPage * 20).clamp(0, _total)}개 표시',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: _currentPage > 1
                                              ? () {
                                                  setState(() {
                                                    _currentPage--;
                                                  });
                                                  _loadJobs();
                                                }
                                              : null,
                                          child: const Text('이전'),
                                        ),
                                        SizedBox(width: AppTheme.spacing2),
                                        TextButton(
                                          onPressed: _currentPage < _totalPages
                                              ? () {
                                                  setState(() {
                                                    _currentPage++;
                                                  });
                                                  _loadJobs();
                                                }
                                              : null,
                                          child: const Text('다음'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
