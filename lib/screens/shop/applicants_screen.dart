import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/application.dart';
import '../../models/job.dart';
import '../../services/application_service.dart';
import '../../services/job_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'spare_detail_screen.dart';

/// Shop 지원자 현황 화면
class ShopApplicantsScreen extends StatefulWidget {
  const ShopApplicantsScreen({super.key});

  @override
  State<ShopApplicantsScreen> createState() => _ShopApplicantsScreenState();
}

class _ShopApplicantsScreenState extends State<ShopApplicantsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final JobService _jobService = JobService();
  
  List<Application> _applications = [];
  List<Job> _jobs = [];
  bool _isLoading = true;
  String _statusFilter = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'
  String? _selectedJobId;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _applicationService.getShopApplications(),
        _jobService.getMyJobs(),
      ]);

      setState(() {
        _applications = results[0] as List<Application>;
        _jobs = results[1] as List<Job>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  List<Application> get _filteredApplications {
    var filtered = List<Application>.from(_applications);
    
    // 공고 필터
    if (_selectedJobId != null) {
      filtered = filtered.where((app) => app.job.id == _selectedJobId).toList();
    }
    
    // 상태 필터
    if (_statusFilter != 'all') {
      filtered = filtered.where((app) => app.status == _statusFilter).toList();
    }
    
    // 최신순 정렬
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  Future<void> _handleApprove(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지원 승인'),
        content: const Text('이 지원자를 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('승인'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _applicationService.approveApplication(applicationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지원자가 승인되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지원 거절'),
        content: const Text('이 지원을 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.urgentRed,
            ),
            child: const Text('거절'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _applicationService.rejectApplication(applicationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지원이 거절되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '지원자 확인',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 필터 섹션
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderGray),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 공고 선택
                      if (_jobs.isNotEmpty) ...[
                        Text(
                          '공고 선택',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing2),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _jobs.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isSelected = _selectedJobId == null;
                                return Padding(
                                  padding: EdgeInsets.only(right: AppTheme.spacing2),
                                  child: FilterChip(
                                    label: const Text('전체'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedJobId = null;
                                      });
                                    },
                                    selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
                                    checkmarkColor: AppTheme.primaryPurple,
                                  ),
                                );
                              }
                              final job = _jobs[index - 1];
                              final isSelected = _selectedJobId == job.id;
                              return Padding(
                                padding: EdgeInsets.only(right: AppTheme.spacing2),
                                child: FilterChip(
                                  label: Text(
                                    job.title,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedJobId = selected ? job.id : null;
                                    });
                                  },
                                  selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
                                  checkmarkColor: AppTheme.primaryPurple,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                      ],
                      // 상태 필터
                      Text(
                        '상태 필터',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Row(
                        children: [
                          _buildStatusFilterChip('전체', 'all'),
                          SizedBox(width: AppTheme.spacing2),
                          _buildStatusFilterChip('대기중', 'pending'),
                          SizedBox(width: AppTheme.spacing2),
                          _buildStatusFilterChip('승인됨', 'approved'),
                          SizedBox(width: AppTheme.spacing2),
                          _buildStatusFilterChip('거절됨', 'rejected'),
                        ],
                      ),
                    ],
                  ),
                ),
                // 지원자 목록
                Expanded(
                  child: _filteredApplications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppTheme.textTertiary,
                              ),
                              SizedBox(height: AppTheme.spacing4),
                              Text(
                                '지원자가 없습니다',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: EdgeInsets.all(AppTheme.spacing4),
                            itemCount: _filteredApplications.length,
                            itemBuilder: (context, index) {
                              final application = _filteredApplications[index];
                              return _buildApplicantCard(application);
                            },
                          ),
                        ),
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

  Widget _buildStatusFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryPurple,
    );
  }

  Widget _buildApplicantCard(Application application) {
    final spare = application.spare;
    final job = application.job;
    
    Color statusColor;
    String statusText;
    switch (application.status) {
      case 'pending':
        statusColor = AppTheme.yellow600;
        statusText = '대기중';
        break;
      case 'approved':
        statusColor = AppTheme.primaryGreen;
        statusText = '승인됨';
        break;
      case 'rejected':
        statusColor = AppTheme.urgentRed;
        statusText = '거절됨';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusText = application.status;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 지원자 정보 및 상태
          Row(
            children: [
              // 프로필 이미지
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopSpareDetailScreen(spareId: spare.id),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    shape: BoxShape.circle,
                  ),
                  child: spare.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            spare.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: AppTheme.textSecondary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppTheme.textSecondary,
                        ),
                ),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spare.name ?? spare.username,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing2,
                            vertical: AppTheme.spacing1,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    Text(
                      DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(application.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacing4),
          
          // 액션 버튼
          if (application.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReject(application.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.urgentRed,
                      side: const BorderSide(color: AppTheme.urgentRed),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(application.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
