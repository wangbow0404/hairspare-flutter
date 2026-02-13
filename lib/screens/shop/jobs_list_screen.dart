import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/job_service.dart';
import '../../models/job.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import 'job_detail_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'home_screen.dart';
import 'job_new_screen.dart';

/// Shop 공고 목록 화면
class ShopJobsListScreen extends StatefulWidget {
  const ShopJobsListScreen({super.key});

  @override
  State<ShopJobsListScreen> createState() => _ShopJobsListScreenState();
}

class _ShopJobsListScreenState extends State<ShopJobsListScreen> {
  final JobService _jobService = JobService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  bool _isSearchOpen = false;
  String _statusFilter = 'all'; // 'all' | 'published' | 'closed' | 'draft'
  String _searchQuery = '';
  int _currentPage = 1;
  int _currentNavIndex = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await _jobService.getMyJobs();
      setState(() {
        _jobs = jobs;
        _filterJobs();
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterJobs() {
    List<Job> filtered = List.from(_jobs);

    // 상태 필터
    if (_statusFilter != 'all') {
      filtered = filtered.where((job) => job.status == _statusFilter).toList();
    }

    // 검색 필터
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(query) ||
            job.regionId.toLowerCase().contains(query);
      }).toList();
    }

    // 최신순 정렬
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredJobs = filtered;
      _currentPage = 1; // 필터 변경 시 첫 페이지로
    });
  }

  List<Job> get _paginatedJobs {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredJobs.sublist(
      startIndex,
      endIndex > _filteredJobs.length ? _filteredJobs.length : endIndex,
    );
  }

  int get _totalPages => (_filteredJobs.length / _itemsPerPage).ceil();

  Future<void> _handleDelete(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공고 삭제'),
        content: const Text('정말 이 공고를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _jobService.deleteJob(job.id);
      await _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공고가 삭제되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleClose(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공고 마감'),
        content: const Text('이 공고를 마감하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('마감'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _jobService.updateJobStatus(job.id, 'closed');
      await _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공고가 마감되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('마감 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleReopen(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공고 재오픈'),
        content: const Text('이 공고를 다시 오픈하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('재오픈'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _jobService.updateJobStatus(job.id, 'published');
      await _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공고가 다시 오픈되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('재오픈 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  void _handleJobTap(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopJobDetailScreen(jobId: job.id),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'published':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '진행중',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'closed':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '마감',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'draft':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '임시저장',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatAmount(int amount) {
    return '₩${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sticky 헤더
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.backgroundWhite,
            elevation: 0,
            leading: IconButton(
              icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                  const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '내 공고',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
            ),
            centerTitle: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderGray,
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                left: 0,
                right: AppTheme.spacing4,
                top: AppTheme.spacing3,
                bottom: AppTheme.spacing3,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  if (_isSearchOpen) ...[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _filterJobs();
                        },
                        decoration: InputDecoration(
                          hintText: '공고 검색...',
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryPurple,
                              width: 2,
                            ),
                          ),
                          contentPadding: AppTheme.spacingSymmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isSearchOpen = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                        _filterJobs();
                      },
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearchOpen = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopJobNewScreen(),
                          ),
                        ).then((_) => _loadJobs());
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 공고 등록 버튼
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopJobNewScreen(),
                    ),
                  ).then((_) => _loadJobs());
                },
                icon: const Icon(Icons.add),
                label: const Text('새 공고 등록'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                ),
              ),
            ),
          ),

          // 필터 및 통계
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전체 공고 ${_filteredJobs.length}개',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('전체', 'all'),
                        SizedBox(width: AppTheme.spacing2),
                        _buildFilterChip('진행중', 'published'),
                        SizedBox(width: AppTheme.spacing2),
                        _buildFilterChip('마감', 'closed'),
                        SizedBox(width: AppTheme.spacing2),
                        _buildFilterChip('임시저장', 'draft'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 공고 목록
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredJobs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 64, color: AppTheme.textTertiary),
                    SizedBox(height: AppTheme.spacing4),
                    const Text(
                      '등록한 공고가 없습니다',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopJobNewScreen(),
                          ),
                        ).then((_) => _loadJobs());
                      },
                      child: const Text('공고 올리기'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final job = _paginatedJobs[index];
                    return _buildJobCard(job);
                  },
                  childCount: _paginatedJobs.length,
                ),
              ),
            ),

          // 페이지네이션
          if (!_isLoading && _filteredJobs.isNotEmpty && _totalPages > 1)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    ...List.generate(
                      _totalPages > 5 ? 5 : _totalPages,
                      (index) {
                        int pageNum;
                        if (_totalPages <= 5) {
                          pageNum = index + 1;
                        } else if (_currentPage <= 3) {
                          pageNum = index + 1;
                        } else if (_currentPage >= _totalPages - 2) {
                          pageNum = _totalPages - 4 + index;
                        } else {
                          pageNum = _currentPage - 2 + index;
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing1),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentPage = pageNum;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _currentPage == pageNum
                                    ? AppTheme.primaryPurple
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                border: Border.all(
                                  color: _currentPage == pageNum
                                      ? AppTheme.primaryPurple
                                      : AppTheme.borderGray,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$pageNum',
                                  style: TextStyle(
                                    color: _currentPage == pageNum
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < _totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),

          // 하단 여백
          SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopFavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = value;
        });
        _filterJobs();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'published'
                  ? Colors.green.shade100
                  : value == 'closed'
                      ? Colors.grey.shade100
                      : value == 'draft'
                          ? Colors.amber.shade100
                          : AppTheme.primaryPurple.withOpacity(0.1))
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected
                ? (value == 'published'
                    ? Colors.green.shade300
                    : value == 'closed'
                        ? Colors.grey.shade300
                        : value == 'draft'
                            ? Colors.amber.shade300
                            : AppTheme.primaryPurple)
                : AppTheme.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? (value == 'published'
                    ? Colors.green.shade700
                    : value == 'closed'
                        ? Colors.grey.shade700
                        : value == 'draft'
                            ? Colors.amber.shade700
                            : AppTheme.primaryPurple)
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 (있는 경우)
          if (job.images != null && job.images!.isNotEmpty)
            GestureDetector(
              onTap: () => _handleJobTap(job),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(job.images!.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (job.images!.length > 1)
                    Positioned(
                      top: AppTheme.spacing2,
                      right: AppTheme.spacing2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image, size: 12, color: Colors.white),
                            SizedBox(width: AppTheme.spacing1),
                            Text(
                              '${job.images!.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // 내용
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 제목, 상태, 액션 버튼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleJobTap(job),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    job.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacing2),
                                _buildStatusBadge(job.status),
                                if (job.isUrgent) ...[
                                  SizedBox(width: AppTheme.spacing1),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.urgentRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      '급구',
                                      style: TextStyle(
                                        color: AppTheme.urgentRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (job.isPremium) ...[
                                  SizedBox(width: AppTheme.spacing1),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      '프리미엄',
                                      style: TextStyle(
                                        color: Colors.amber.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing2),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  '${job.date} ${job.time}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacing3),
                                Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: AppTheme.spacing1),
                                Expanded(
                                  child: Text(
                                    job.regionId.replaceAll('-', ' '),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 액션 버튼들
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (job.status == 'published')
                          IconButton(
                            icon: const Icon(Icons.visibility_off, size: 20),
                            onPressed: () => _handleClose(job),
                            tooltip: '마감',
                          ),
                        if (job.status == 'closed')
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            onPressed: () => _handleReopen(job),
                            tooltip: '재오픈',
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            // TODO: 공고 수정 화면으로 이동
                          },
                          tooltip: '수정',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: AppTheme.urgentRed),
                          onPressed: () => _handleDelete(job),
                          tooltip: '삭제',
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing3),

                // 통계 정보
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money, size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  '금액',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              _formatAmount(job.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderGray,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  '지원자',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '0/${job.requiredCount}명',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacing3),

                // 액션 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 지원자 관리 화면으로 이동
                        },
                        icon: const Icon(Icons.people, size: 18),
                        label: const Text('지원자 관리 (0)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    if (job.status == 'published')
                      OutlinedButton(
                        onPressed: () => _handleClose(job),
                        child: const Text('마감하기'),
                      ),
                    if (job.status == 'closed')
                      ElevatedButton(
                        onPressed: () => _handleReopen(job),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('재오픈'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
