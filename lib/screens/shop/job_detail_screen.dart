import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/error_handler.dart';
import 'jobs_list_screen.dart';
import 'applicants_screen.dart';

/// Shop 공고 상세 화면
class ShopJobDetailScreen extends StatefulWidget {
  final String jobId;

  const ShopJobDetailScreen({super.key, required this.jobId});

  @override
  State<ShopJobDetailScreen> createState() => _ShopJobDetailScreenState();
}

class _ShopJobDetailScreenState extends State<ShopJobDetailScreen> {
  final JobService _jobService = JobService();
  Job? _job;
  bool _isLoading = true;
  String? _error;
  int _selectedImageIndex = 0;
  bool _isDeleting = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final job = await _jobService.getJobById(widget.jobId);
      setState(() {
        _job = job;
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(appException);
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공고 삭제'),
        content: const Text('정말 이 공고를 삭제하시겠습니까?\n삭제된 공고는 복구할 수 없습니다.'),
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

    setState(() {
      _isDeleting = true;
    });

    try {
      await _jobService.deleteJob(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고가 삭제되었습니다.')),
        );
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _handleClose() async {
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

    setState(() {
      _isClosing = true;
    });

    try {
      // TODO: 공고 마감 API 호출
      // await _jobService.closeJob(widget.jobId);
      await _loadJob();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고가 마감되었습니다.')),
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
    } finally {
      if (mounted) {
        setState(() {
          _isClosing = false;
        });
      }
    }
  }

  Future<void> _handleReopen() async {
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

    setState(() {
      _isClosing = true;
    });

    try {
      // TODO: 공고 재오픈 API 호출
      // await _jobService.reopenJob(widget.jobId);
      await _loadJob();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고가 다시 오픈되었습니다.')),
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
    } finally {
      if (mounted) {
        setState(() {
          _isClosing = false;
        });
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'published':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '진행중',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        );
      case 'closed':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '마감',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      case 'draft':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 16, color: Colors.orange.shade700),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '임시저장',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatAmount(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            '공고 상세',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _job == null) {
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
            '공고 상세',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? '공고를 찾을 수 없습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppTheme.spacing4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('공고 목록으로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final job = _job!;
    final images = job.images ?? [];
    final hasImages = images.isNotEmpty;

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
          '공고 상세',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: IconMapper.icon('edit', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.edit, color: AppTheme.textSecondary),
            onPressed: () {
              // TODO: 공고 수정 화면으로 이동
            },
          ),
          IconButton(
            icon: IconMapper.icon('trash2', size: 24, color: AppTheme.urgentRed) ??
                const Icon(Icons.delete, color: AppTheme.urgentRed),
            onPressed: _isDeleting ? null : _handleDelete,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 이미지 갤러리
          if (hasImages)
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                color: Colors.black,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.backgroundGray,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            return Container(
                              width: _selectedImageIndex == index ? 24 : 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _selectedImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          '${_selectedImageIndex + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 공고 정보 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 및 상태
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      job.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (job.isUrgent)
                                    Container(
                                      margin: EdgeInsets.only(left: AppTheme.spacing2),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing2,
                                        vertical: AppTheme.spacing1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.red50,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '급구',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.urgentRed,
                                        ),
                                      ),
                                    ),
                                  if (job.isPremium)
                                    Container(
                                      margin: EdgeInsets.only(left: AppTheme.spacing2),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing2,
                                        vertical: AppTheme.spacing1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '프리미엄',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: AppTheme.spacing2),
                              _buildStatusBadge(job.status),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacing6),

                    // 기본 정보
                    Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: '${job.date} ${job.time}${job.endTime != null ? ' - ${job.endTime}' : ''}',
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: job.regionId ?? '지역 미지정',
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        _buildInfoRow(
                          icon: Icons.attach_money,
                          label: _formatAmount(job.amount),
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: '예약금(에너지) ${job.energy}개',
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        _buildInfoRow(
                          icon: Icons.people,
                          label: '필요 인원: ${job.requiredCount}명',
                        ),
                      ],
                    ),

                    // 상세 설명
                    if (job.description != null && job.description!.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacing6),
                      Divider(height: 1, color: AppTheme.borderGray),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        '상세 설명',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray700,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        job.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],

                    // 특기사항/요구사항
                    if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacing6),
                      Divider(height: 1, color: AppTheme.borderGray),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        '특기사항/요구사항',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray700,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        job.requirements!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],

                    // 통계 정보
                    SizedBox(height: AppTheme.spacing6),
                    Divider(height: 1, color: AppTheme.borderGray),
                    SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGray,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '0', // TODO: 실제 지원자 수
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing1),
                                Text(
                                  '전체 지원자',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGray,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '0', // TODO: 실제 승인된 지원자 수
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing1),
                                Text(
                                  '승인된 지원자',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 액션 버튼들
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopApplicantsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people, size: 20),
                      label: Text('지원자 관리 (0명)'), // TODO: 실제 지원자 수
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  if (job.status == 'published')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isClosing ? null : _handleClose,
                        icon: Icon(Icons.visibility_off, size: 20),
                        label: Text(_isClosing ? '마감 중...' : '공고 마감하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.backgroundGray,
                          foregroundColor: AppTheme.textGray700,
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                        ),
                      ),
                    ),
                  if (job.status == 'closed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isClosing ? null : _handleReopen,
                        icon: Icon(Icons.visibility, size: 20),
                        label: Text(_isClosing ? '재오픈 중...' : '공고 다시 오픈하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                        ),
                      ),
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
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textGray700,
            ),
          ),
        ),
      ],
    );
  }
}
