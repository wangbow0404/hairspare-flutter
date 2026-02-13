import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/work_check_service.dart';
import '../../services/schedule_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../../models/shop_tier.dart';

/// Shop VIP 등급 화면
class ShopWorkCheckScreen extends StatefulWidget {
  const ShopWorkCheckScreen({super.key});

  @override
  State<ShopWorkCheckScreen> createState() => _ShopWorkCheckScreenState();
}

class _ShopWorkCheckScreenState extends State<ShopWorkCheckScreen> {
  int _currentNavIndex = 0;
  final WorkCheckService _workCheckService = WorkCheckService();
  final ScheduleService _scheduleService = ScheduleService();
  
  int _totalCompleted = 0;
  String _vipLevel = 'bronze';
  int _nextCount = 1;
  int _vipProgress = 0;
  List<String> _vipBenefits = [];
  bool _isLoading = true;

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
      final stats = await _workCheckService.getShopStats();
      setState(() {
        _totalCompleted = stats['totalCompleted'] ?? 0;
        _vipLevel = (stats['vipLevel'] ?? stats['tier'] ?? 'bronze').toString();
        _nextCount = stats['nextCount'] ?? 1;
        _vipProgress = stats['vipProgress'] ?? 0;
        _vipBenefits = List<String>.from(stats['vipBenefits'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getVipInfo(int count, String level) {
    if (count == 0) {
      return {
        'title': '근무체크 시작하기',
        'subtitle': '2026년 스페어와 함께 일하기 시작해보세요!',
        'emoji': '🚀',
      };
    } else if (count == 1) {
      return {
        'title': '첫 근무 완료!',
        'subtitle': '벌써 1번의 근무를 완료했어요!',
        'emoji': '🌱',
      };
    } else if (count < 5) {
      return {
        'title': '스페어와 함께!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '💪',
      };
    } else if (count < 10) {
      return {
        'title': '헤어스페어 VIP!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '⭐',
      };
    } else if (count < 20) {
      return {
        'title': '헤어스페어 VIP!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '🔥',
      };
    } else if (count < 50) {
      return {
        'title': '헤어스페어 VIP 브론즈!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '🏆',
      };
    } else if (count < 100) {
      return {
        'title': '헤어스페어 VIP 실버!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '💎',
      };
    } else if (count < 200) {
      return {
        'title': '헤어스페어 VIP 골드!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '👑',
      };
    } else {
      return {
        'title': '헤어스페어 VIP 플래티넘!',
        'subtitle': '벌써 $count번의 근무를 완료했어요!',
        'emoji': '💫',
      };
    }
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
            'VIP 등급',
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

    final vipInfo = _getVipInfo(_totalCompleted, _vipLevel);

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
          'VIP 등급',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // VIP 정보 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryPurple.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      vipInfo['emoji'] as String,
                      style: const TextStyle(fontSize: 64),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      vipInfo['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      vipInfo['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.spacing6),
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '완료된 근무',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          Text(
                            '$_totalCompleted회',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // VIP 등급 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
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
                    Text(
                      '현재 등급',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      ShopTierExtension.parse(_vipLevel).name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(ShopTierExtension.parse(_vipLevel).colorValue),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    if (_vipBenefits.isNotEmpty) ...[
                      Text(
                        'VIP 혜택',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      ..._vipBenefits.map((benefit) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppTheme.spacing1),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppTheme.primaryGreen,
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
                  ],
                ),
              ),
            ),
          ),

          // 다음 등급까지 진행률
          if (_nextCount > _totalCompleted)
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
                      Text(
                        '다음 등급까지',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      LinearProgressIndicator(
                        value: _vipProgress / 100,
                        backgroundColor: AppTheme.backgroundGray,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                        minHeight: 8,
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '$_totalCompleted / $_nextCount 회',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
}
