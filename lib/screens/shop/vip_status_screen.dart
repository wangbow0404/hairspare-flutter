import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/shop_tier.dart';
import '../../services/schedule_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Shop VIP 현황 화면
class ShopVipStatusScreen extends StatefulWidget {
  const ShopVipStatusScreen({super.key});

  @override
  State<ShopVipStatusScreen> createState() => _ShopVipStatusScreenState();
}

class _ShopVipStatusScreenState extends State<ShopVipStatusScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  
  ShopTierInfo? _tierInfo;
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTierInfo();
  }

  Future<void> _loadTierInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // API에서 등급 정보 가져오기 시도
      final schedules = await _scheduleService.getSchedules(ownerId: 'me');
      final completedSchedules = schedules.where((s) => s.status == 'completed').length;
      // TODO: 실제 따봉 수를 API에서 가져오기
      final thumbsUpReceived = (completedSchedules * 0.8).round();
      
      setState(() {
        _tierInfo = ShopTierInfo(
          currentTier: ShopTierInfo.calculateTier(completedSchedules, thumbsUpReceived),
          completedSchedules: completedSchedules,
          thumbsUpReceived: thumbsUpReceived,
          maxJobPosts: ShopTierInfo.calculateMaxJobPosts(
            ShopTierInfo.calculateTier(completedSchedules, thumbsUpReceived),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      // API 오류 시 mock 데이터로 대체 (503 Service Unavailable 등)
      if (mounted) {
        // 기본값으로 브론즈 등급 설정
        setState(() {
          _tierInfo = ShopTierInfo(
            currentTier: ShopTier.bronze,
            completedSchedules: 0,
            thumbsUpReceived: 0,
            maxJobPosts: 5,
          );
          _isLoading = false;
        });
        // 오류 메시지는 표시하지 않음 (mock 데이터로 대체했으므로)
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
          'VIP 현황',
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
          : _tierInfo == null
              ? const Center(child: Text('등급 정보를 불러올 수 없습니다'))
              : RefreshIndicator(
                  onRefresh: _loadTierInfo,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppTheme.spacing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 현재 등급 카드
                        _buildCurrentTierCard(),
                        
                        SizedBox(height: AppTheme.spacing4),
                        
                        // 통계 카드
                        _buildStatsCard(),
                        
                        SizedBox(height: AppTheme.spacing4),
                        
                        // 등급 진행률 카드
                        if (_tierInfo!.currentTier.getNextTier() != null)
                          _buildProgressCard(),
                        
                        SizedBox(height: AppTheme.spacing4),
                        
                        // 등급 올리는 방법 안내 카드
                        _buildUpgradeGuideCard(),
                        
                        SizedBox(height: AppTheme.spacing4),
                        
                        // 모든 등급 안내 카드
                        _buildAllTiersCard(),
                      ],
                    ),
                  ),
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

  Widget _buildCurrentTierCard() {
    final tier = _tierInfo!.currentTier;
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(tier.colorValue).withOpacity(0.2),
            Color(tier.colorValue).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Color(tier.colorValue).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            tier.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          SizedBox(height: AppTheme.spacing3),
          Text(
            '${tier.name} 등급',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(tier.colorValue),
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            '현재 등급',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통계',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: '완료 스케줄',
                  value: '${_tierInfo!.completedSchedules}개',
                  color: AppTheme.primaryGreen,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.borderGray,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.thumb_up,
                  label: '받은 따봉',
                  value: '${_tierInfo!.thumbsUpReceived}개',
                  color: AppTheme.primaryPurple,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.borderGray,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.work_outline,
                  label: '최대 공고',
                  value: _tierInfo!.maxJobPosts == 999 ? '무제한' : '${_tierInfo!.maxJobPosts}개',
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: AppTheme.spacing2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final nextTier = _tierInfo!.currentTier.getNextTier()!;
    final progress = _tierInfo!.progressToNextTier;
    
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '다음 등급까지',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          // 진행률 바
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(_tierInfo!.currentTier.colorValue),
                        Color(nextTier.colorValue),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${nextTier.emoji} ${nextTier.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Color(nextTier.colorValue),
                ),
              ),
              Text(
                '필요: 완료 ${_tierInfo!.requiredSchedulesForNextTier ?? 0}개 또는 따봉 ${_tierInfo!.requiredThumbsUpForNextTier ?? 0}개',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    final tier = _tierInfo!.currentTier;
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tier.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                '현재 등급 혜택',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          ...tier.benefits.map((benefit) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(tier.colorValue),
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: Text(
                      benefit,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNextTierCard() {
    final nextTier = _tierInfo!.currentTier.getNextTier()!;
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Color(nextTier.colorValue).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Color(nextTier.colorValue).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                nextTier.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                '다음 등급: ${nextTier.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(nextTier.colorValue),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          Text(
            '필요 조건:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            '• 완료 스케줄 ${nextTier.minCompletedSchedules}개 이상',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '• 또는 따봉 ${nextTier.minThumbsUp}개 이상',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: AppTheme.spacing3),
          Text(
            '다음 등급 혜택:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          ...nextTier.benefits.map((benefit) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: Color(nextTier.colorValue),
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: Text(
                      benefit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpgradeGuideCard() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFEFF6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primaryPurpleLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(Icons.trending_up, size: 18, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                '등급 올리는 방법',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          _buildGuideItem(
            icon: Icons.check_circle_outline,
            title: '완료 스케줄 달성',
            description: '스케줄을 완료하면 등급 상승에 도움이 됩니다.\n완료한 스케줄 수가 많을수록 높은 등급을 받을 수 있습니다.',
            color: AppTheme.primaryGreen,
          ),
          SizedBox(height: AppTheme.spacing3),
          _buildGuideItem(
            icon: Icons.thumb_up_outlined,
            title: '따봉 받기',
            description: '스페어로부터 따봉을 받으면 등급 상승에 도움이 됩니다.\n서비스 품질을 높여 많은 따봉을 받아보세요.',
            color: AppTheme.primaryPurple,
          ),
          SizedBox(height: AppTheme.spacing3),
          _buildGuideItem(
            icon: Icons.info_outline,
            title: '등급 조건',
            description: '완료 스케줄 수 또는 따봉 수 중 하나만 충족해도\n다음 등급으로 상승할 수 있습니다.',
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacing2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.spacing1),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllTiersCard() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(Icons.star, size: 18, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                '등급별 상세 안내',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          ...ShopTier.values.map((tier) {
            final isCurrentTier = tier == _tierInfo!.currentTier;
            return Container(
              margin: EdgeInsets.only(bottom: AppTheme.spacing3),
              padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: isCurrentTier
                    ? Color(tier.colorValue).withOpacity(0.1)
                    : AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: isCurrentTier
                      ? Color(tier.colorValue)
                      : AppTheme.borderGray,
                  width: isCurrentTier ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          tier.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(tier.colorValue),
                          ),
                        ),
                      ),
                      if (isCurrentTier)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing2,
                            vertical: AppTheme.spacing1,
                          ),
                          decoration: BoxDecoration(
                            color: Color(tier.colorValue),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: const Text(
                            '현재 등급',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  Text(
                    '필요 조건:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing1),
                  Text(
                    '• 완료 스케줄 ${tier.minCompletedSchedules}개 이상',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '• 또는 따봉 ${tier.minThumbsUp}개 이상',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '혜택:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing1),
                  ...tier.benefits.map((benefit) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacing1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Color(tier.colorValue),
                          ),
                          SizedBox(width: AppTheme.spacing1),
                          Expanded(
                            child: Text(
                              benefit,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
