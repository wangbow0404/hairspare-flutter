import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
import '../../services/favorite_service.dart';
import '../../services/verification_service.dart';
import '../../services/energy_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../spare/verification_screen.dart';

/// Next.js와 동일한 공고 상세 화면
class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final JobService _jobService = JobService();
  final FavoriteService _favoriteService = FavoriteService();
  final VerificationService _verificationService = VerificationService();
  final EnergyService _energyService = EnergyService();
  Job? _job;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;
  bool _showConfirmModal = false;
  bool _isLocked = false;
  bool _showVerificationModal = false;
  bool _identityVerified = false;
  int _energyBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadJob();
    _checkVerificationStatus();
    _checkFavoriteStatus();
    _loadEnergyBalance();
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final status = await _verificationService.getVerificationStatus();
      setState(() {
        _identityVerified = status['identityVerified'] as bool? ?? false;
      });
    } catch (e) {
      // 에러 발생 시 false로 설정
      setState(() {
        _identityVerified = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await _favoriteService.isFavorite(widget.jobId);
      setState(() {
        _isFavorite = isFav;
      });
    } catch (e) {
      // 에러 발생 시 false로 설정
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _loadEnergyBalance() async {
    try {
      final wallet = await _energyService.getWallet();
      setState(() {
        _energyBalance = wallet['balance'] ?? 0;
      });
    } catch (e) {
      // 에러 발생 시 0으로 설정
      setState(() {
        _energyBalance = 0;
      });
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await _favoriteService.removeFavorite(widget.jobId);
        setState(() {
          _isFavorite = false;
        });
      } else {
        await _favoriteService.addFavorite(widget.jobId);
        setState(() {
          _isFavorite = true;
        });
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  void _handleApply() {
    // 본인인증 상태 확인
    if (!_identityVerified) {
      setState(() {
        _showVerificationModal = true;
      });
      return;
    }

    // 에너지 체크
    if (_job == null) return;
    if (_energyBalance < _job!.energy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('에너지가 부족합니다')),
      );
      return;
    }

    setState(() {
      _showConfirmModal = true;
    });
  }

  Future<void> _handleConfirm() async {
    if (_job == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 지원 API 호출
      await _jobService.applyToJob(widget.jobId);

      setState(() {
        _isLocked = true;
        _energyBalance -= _job!.energy;
        _showConfirmModal = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지원이 완료되었습니다. 미용실의 승인을 기다려주세요.'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCountdownText(int? countdown) {
    if (countdown == null || countdown <= 0) return '마감됨';
    final hours = countdown ~/ 3600;
    final minutes = (countdown % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    }
    return '${minutes}분';
  }

  String _getDeadlineTime(int? countdown) {
    if (countdown == null) return '';
    final deadline = DateTime.now().add(Duration(seconds: countdown));
    final hours = deadline.hour.toString().padLeft(2, '0');
    final minutes = deadline.minute.toString().padLeft(2, '0');
    return '오늘 $hours:$minutes';
  }

  String _getRegionName(String regionId) {
    return RegionHelper.getRegionName(regionId);
  }

  String _getRegionAddress(String regionId) {
    // TODO: 실제 지역 데이터에서 가져오기
    const addressMap = {
      'seoul-gangnam': '서울시 강남구 역삼동 123-45',
      'seoul-seocho': '서울시 서초구 서초동 456-78',
      'seoul-mapo': '서울시 마포구 홍대입구역 789-12',
      'seoul-songpa': '서울시 송파구 잠실동 345-67',
      'seoul-yongsan': '서울시 용산구 이태원동 234-56',
      'seoul-jongno': '서울시 종로구 명동 567-89',
    };
    return addressMap[regionId] ?? '서울시 강남구';
  }

  String _getRegionSubway(String regionId) {
    // TODO: 실제 지역 데이터에서 가져오기
    const subwayMap = {
      'seoul-gangnam': '강남역 3번 출구 도보 5분',
      'seoul-seocho': '서초역 2번 출구 도보 3분',
      'seoul-mapo': '홍대입구역 1번 출구 도보 7분',
      'seoul-songpa': '잠실역 4번 출구 도보 10분',
      'seoul-yongsan': '이태원역 1번 출구 도보 5분',
      'seoul-jongno': '명동역 2번 출구 도보 3분',
    };
    return subwayMap[regionId] ?? '지하철역 도보 5분';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _job == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textGray700) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textGray700),
            onPressed: () => NavigationHelper.safePop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? '공고를 찾을 수 없습니다',
                style: TextStyle(color: AppTheme.urgentRed),
              ),
              SizedBox(height: AppTheme.spacing4),
              ElevatedButton(
                onPressed: _loadJob,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final job = _job!;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // 시스템 백 버튼 처리 (필요시 추가 로직)
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: Stack(
          children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Hero Section
                _buildHeroSection(job),

                // Title Section
                _buildTitleSection(job),

                // Quick Info Grid
                _buildQuickInfoGrid(job),

                // 지원 방법 섹션
                _buildHowToApplySection(job),

                // 상세 정보 섹션
                _buildDetailSection(job),

                // 하단 여백
                SizedBox(height: 120), // 하단 네비게이션 바 + 지원하기 버튼 높이
              ],
            ),
          ),

          // Fixed Bottom Button
          _buildBottomButton(job),

          // 모달들
          if (_showVerificationModal) _buildVerificationModal(),
          if (_showConfirmModal) _buildConfirmModal(job),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textGray700) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textGray700),
            onPressed: () => NavigationHelper.safePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryPurple500, AppTheme.primaryPink], // from-purple-500 to-pink-500
                  ),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                child: const Center(
                  child: Text(
                    'H',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                'HAIRSPARE',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: IconMapper.icon('share2', size: 20, color: AppTheme.textGray700) ??
                const Icon(Icons.share, color: AppTheme.textGray700),
            onPressed: () async {
              if (_job != null) {
                try {
                  final regionName = RegionHelper.getRegionName(_job!.regionId);
                  final shareText = '${_job!.title}\n'
                      '${regionName} · ${_job!.date} ${_job!.time}\n'
                      '시급: ${NumberFormat('#,###').format(_job!.amount)}원\n'
                      '에너지: ${_job!.energy}개';
                  
                  await Share.share(
                    shareText,
                    subject: _job!.title,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('공유 실패: ${e.toString()}'),
                        backgroundColor: AppTheme.urgentRed,
                      ),
                    );
                  }
                }
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Job job) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.green200, AppTheme.blue200],
        ),
      ),
      child: Stack(
        children: [
          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 태그들
          Positioned(
            top: AppTheme.spacing4,
            left: AppTheme.spacing4,
            child: Row(
              children: [
                if (job.isUrgent)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2 - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRed,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '🚀 급구',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (job.isUrgent && job.isPremium)
                  SizedBox(width: AppTheme.spacing2),
                if (job.isPremium)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2 - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '프리미엄',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(Job job) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            job.shopName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          // 급구 카운트다운 배너
          if (job.isUrgent && job.countdown != null) ...[
            SizedBox(height: AppTheme.spacing6),
            Container(
              padding: AppTheme.spacing(AppTheme.spacing5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.urgentRed, Color(0xFFDC2626)],
                ),
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏰ 남은 시간',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        _getCountdownText(job.countdown),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '마감 시간',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        _getDeadlineTime(job.countdown),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickInfoGrid(Job job) {
    return Padding(
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing4,
        ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppTheme.spacing3,
        mainAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 1.5,
        children: [
          _buildQuickInfoItem(
            icon: IconMapper.icon('mappin', size: 16, color: AppTheme.primaryBlue) ??
                const Icon(Icons.location_on, size: 16, color: AppTheme.primaryBlue),
            label: '근무 지역',
            value: _getRegionName(job.regionId),
          ),
          _buildQuickInfoItem(
            icon: IconMapper.icon('clock', size: 16, color: AppTheme.primaryPurple) ??
                const Icon(Icons.access_time, size: 16, color: AppTheme.primaryPurple),
            label: '근무 시간',
            value: '${job.date} ${job.time}',
          ),
          _buildQuickInfoItem(
            icon: IconMapper.icon('users', size: 16, color: AppTheme.primaryGreen) ??
                const Icon(Icons.people, size: 16, color: AppTheme.primaryGreen),
            label: '모집 인원',
            value: '${job.requiredCount}명',
          ),
          _buildQuickInfoItem(
            icon: IconMapper.icon('zap', size: 16, color: AppTheme.yellow400) ??
                const Icon(Icons.bolt, size: 16, color: AppTheme.yellow400),
            label: '예약금',
            value: '${job.energy} 에너지',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: AppTheme.spacing2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToApplySection(Job job) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Text(
            '지원 방법',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            '간단한 3단계로 지원이 완료됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacing8),
          _buildStepItem(
            step: 1,
            title: '공고 확인하기',
            description: '근무 지역, 시간, 급여 등 상세 정보를 꼼꼼히 확인하세요.',
          ),
          SizedBox(height: AppTheme.spacing6),
          _buildStepItem(
            step: 2,
            title: '지원하기 버튼 클릭',
            description: '예약금(에너지) ${job.energy}개가 잠금되며, 출근 완료 시 반환됩니다.',
          ),
          SizedBox(height: AppTheme.spacing6),
          _buildStepItem(
            step: 3,
            title: '매장 확인 및 출근',
            description: '매장에서 지원을 확인하면 출근 시간에 맞춰 근무하시면 됩니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int step,
    required String title,
    required String description,
  }) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
        border: Border.all(color: AppTheme.borderGray.withOpacity(0.5)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.spacing2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(Job job) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          // 급여 정보
          Container(
            padding: AppTheme.spacing(AppTheme.spacing6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)], // from-green-50 to-emerald-50
              ),
              borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
              border: Border.all(color: AppTheme.green100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '급여',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.green700,
                  ),
                ),
                SizedBox(height: AppTheme.spacing2),
                Text(
                  '${NumberFormat('#,###').format(job.amount)}원',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.green700,
                  ),
                ),
                SizedBox(height: AppTheme.spacing1),
                Text(
                  '당일 지급',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: AppTheme.green700.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          // 근무 조건
          Container(
            padding: AppTheme.spacing(AppTheme.spacing6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '근무 조건',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                _buildConditionItem('근무 날짜: ${job.date}'),
                SizedBox(height: AppTheme.spacing3),
                _buildConditionItem('근무 시간: ${job.time}'),
                SizedBox(height: AppTheme.spacing3),
                _buildConditionItem('위치: ${_getRegionName(job.regionId)}'),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          // 예약금 안내
          Container(
            padding: AppTheme.spacing(AppTheme.spacing6),
            decoration: BoxDecoration(
              color: AppTheme.yellow50, // bg-yellow-50
              borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
              border: Border.all(
                color: AppTheme.yellow200, // border-yellow-200
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예약금(에너지) 안내',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF78350F), // yellow-900
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      _buildEnergyInfoItem('지원 시 예약금(에너지) ${job.energy}개가 잠금됩니다.'),
                      SizedBox(height: AppTheme.spacing2),
                      _buildEnergyInfoItem('정상 출근 완료 시 예약금이 반환됩니다.'),
                      SizedBox(height: AppTheme.spacing2),
                      _buildEnergyInfoItem('노쇼(무단결근) 시 예약금이 차감됩니다.'),
                      SizedBox(height: AppTheme.spacing2),
                      _buildEnergyInfoItem('부득이한 사유로 취소 시 24시간 전 연락 필수'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          // 매장 정보
          Container(
            padding: AppTheme.spacing(AppTheme.spacing6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '매장 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                _buildShopInfoItem('매장명', job.isPremium ? '${job.shopName} (프리미엄)' : job.shopName),
                SizedBox(height: AppTheme.spacing4),
                _buildShopInfoItem('주소', _getRegionAddress(job.regionId)),
                SizedBox(height: AppTheme.spacing1),
                Text(
                  _getRegionSubway(job.regionId),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                _buildShopInfoItem('연락처', '010-1234-5678'),
                SizedBox(height: AppTheme.spacing4),
                _buildShopInfoItem('특징', ''),
                SizedBox(height: AppTheme.spacing2),
                Wrap(
                  spacing: AppTheme.spacing2,
                  runSpacing: AppTheme.spacing2,
                  children: [
                    if (job.isPremium)
                      _buildTag('프리미엄 매장', AppTheme.purple100, AppTheme.purple700),
                    _buildTag('최신 시설', AppTheme.blue200.withOpacity(0.3), AppTheme.primaryBlue),
                    _buildTag('${_getRegionName(job.regionId)} 인근', AppTheme.green100, AppTheme.green700),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconMapper.icon('checkcircle2', size: 20, color: AppTheme.primaryPurple) ??
            const Icon(Icons.check_circle, size: 20, color: AppTheme.primaryPurple),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppTheme.textGray700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyInfoItem(String text, [Color? textColor]) {
    return Text(
      '• $text',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 14,
        color: textColor ?? const Color(0xFF92400E), // yellow-800
        height: 1.5,
      ),
    );
  }

  Widget _buildShopInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        if (value.isNotEmpty) ...[
          SizedBox(height: AppTheme.spacing1),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBottomButton(Job job) {
    return Positioned(
      bottom: 80, // 하단 네비게이션 바 위 (bottom-20)
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderGray,
              width: 1,
            ),
          ),
          boxShadow: AppTheme.shadowLg,
        ),
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: SafeArea(
          top: false,
          child: _isLocked
              ? Container(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // blue-50
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE), // blue-200
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '예약금(에너지) 잠금됨',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A), // blue-800
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '근무 완료 + 정산 완료 시 예약금이 반환됩니다.\n노쇼 시 예약금은 미용실에 귀속됩니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF1E40AF), // blue-700
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF9333EA), Color(0xFF7E22CE)], // from-purple-600 to-purple-700
                        ),
                        borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: Container(
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        alignment: Alignment.center,
                        child: Text(
                          '지원하기',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildVerificationModal() {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showVerificationModal = false;
          });
        },
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: IconMapper.icon('x', size: 20, color: AppTheme.textSecondary) ??
                          const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          _showVerificationModal = false;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: IconMapper.icon('shield', size: 32, color: AppTheme.primaryGreen) ??
                        const Icon(Icons.shield, size: 32, color: AppTheme.primaryGreen),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '본인인증',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '휴대폰 본인인증을 진행해주세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                    ),
                    child: Text(
                      '본인인증 진행 후에 지원이 가능합니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textGray700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showVerificationModal = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerificationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        '본인인증하러가기',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmModal(Job job) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showConfirmModal = false;
          });
        },
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: IconMapper.icon('zap', size: 32, color: AppTheme.primaryPurple) ??
                        const Icon(Icons.bolt, size: 32, color: AppTheme.primaryPurple),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '지원 확인',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '정말 지원하시겠습니까?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                    ),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textGray700,
                            ),
                            children: [
                              const TextSpan(text: '예약금(에너지) '),
                              TextSpan(
                                text: '${job.energy}개',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                              const TextSpan(text: '가 잠금됩니다'),
                            ],
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing2),
                        Text(
                          '출근 완료 시 반환됩니다',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showConfirmModal = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.backgroundGray,
                        foregroundColor: AppTheme.textGray700,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textGray700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
