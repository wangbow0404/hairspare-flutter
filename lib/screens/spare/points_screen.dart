import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/spare_app_bar.dart';
import '../../utils/icon_mapper.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 +포인트 화면
class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int _currentNavIndex = 0;
  int _currentPoints = 1250; // 보유 포인트
  bool _attendanceChecked = false; // 출석체크 여부
  bool _showMoreSimple = false;
  bool _showMoreParticipation = false;
  bool _showMorePurchase = false;
  Set<String> _completedMissionIds = {}; // 완료된 미션 ID 추적

  // Mock 데이터
  final List<_Mission> _dailyMissions = [
    _Mission(
      id: 'daily-1',
      title: '출석체크',
      description: '포포몬',
      points: 10,
      icon: '🎮',
      completed: false,
      category: 'daily',
    ),
  ];

  final List<_Mission> _simpleMissions = [
    _Mission(
      id: 'simple-1',
      title: '[채널추가] 쿠팡로지스틱스 채용 카카오톡 채널',
      description: 'coupang logistics services',
      points: 94,
      iconUrl: '/images/missions/coupang.png',
      completed: false,
      category: 'simple',
    ),
    _Mission(
      id: 'simple-2',
      title: '[구독하기] 세계일보 네이버 뉴스',
      description: '세계일보 Hi Paper',
      points: 94,
      iconUrl: '/images/missions/segye.png',
      completed: false,
      category: 'simple',
    ),
    _Mission(
      id: 'simple-3',
      title: '미래엔(현재엔) 유튜브 구독하기',
      description: '미래엔',
      points: 77,
      iconUrl: '/images/missions/miraen.png',
      completed: false,
      category: 'simple',
    ),
    _Mission(
      id: 'simple-4',
      title: '르꼬끄 인스타 팔로우 하기',
      description: 'Le Coq Sportif',
      points: 77,
      iconUrl: '/images/missions/lecoq.png',
      completed: false,
      category: 'simple',
    ),
    _Mission(
      id: 'simple-5',
      title: '국민연금 인스타 팔로우하기',
      description: 'NPS 국민연금',
      points: 77,
      iconUrl: '/images/missions/nps.png',
      completed: false,
      category: 'simple',
    ),
  ];

  final List<_Mission> _participationMissions = [
    _Mission(
      id: 'participation-1',
      title: '티플러스 모바일 (클릭하고 20초보기)',
      description: '알뜰폰의 기준 tplus',
      points: 3,
      iconUrl: '/images/missions/tplus.png',
      completed: false,
      category: 'participation',
    ),
    _Mission(
      id: 'participation-2',
      title: '[음악듣기] 큰거온다',
      description: '음악 아티스트',
      points: 3,
      iconUrl: '/images/missions/music1.png',
      completed: false,
      category: 'participation',
    ),
    _Mission(
      id: 'participation-3',
      title: '[음악듣기] 그리고 며칠 후 (Thereafter)',
      description: '음악 아티스트',
      points: 3,
      iconUrl: '/images/missions/music2.png',
      completed: false,
      category: 'participation',
    ),
    _Mission(
      id: 'participation-4',
      title: '[방문하기] SSG.COM',
      description: 'SSG',
      points: 1,
      iconUrl: '/images/missions/ssg.png',
      completed: false,
      category: 'participation',
    ),
    _Mission(
      id: 'participation-5',
      title: '[음악듣기] Wish',
      description: 'essential',
      points: 3,
      iconUrl: '/images/missions/music3.png',
      completed: false,
      category: 'participation',
    ),
  ];

  final List<_Mission> _purchaseMissions = [
    _Mission(
      id: 'purchase-1',
      title: '[구매하기] 특가 상품 구매',
      description: '할인 상품',
      points: 50,
      icon: '🛒',
      completed: false,
      category: 'purchase',
    ),
    _Mission(
      id: 'purchase-2',
      title: '[구매하기] 프리미엄 상품 구매',
      description: '프리미엄',
      points: 100,
      icon: '💎',
      completed: false,
      category: 'purchase',
    ),
  ];


  void _handleAttendanceCheck() {
    if (!_attendanceChecked) {
      setState(() {
        _attendanceChecked = true;
        _currentPoints += 10;
        _completedMissionIds.add('daily-1');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('출석체크 완료! 10P를 받았습니다.'),
          backgroundColor: AppTheme.primaryPurple,
        ),
      );
    }
  }

  void _handleMissionComplete(_Mission mission) {
    if (!mission.completed && !_completedMissionIds.contains(mission.id)) {
      setState(() {
        _currentPoints += mission.points;
        _completedMissionIds.add(mission.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mission.title} 완료! ${mission.points}P를 받았습니다.'),
          backgroundColor: AppTheme.primaryPurple,
        ),
      );
    }
  }

  bool _isMissionCompleted(String missionId) {
    return _completedMissionIds.contains(missionId);
  }

  Widget _buildMissionPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.green200, AppTheme.blue100],
        ),
      ),
      child: Center(
        child: IconMapper.icon('briefcase', size: 28, color: Colors.white.withOpacity(0.9)) ??
            Icon(Icons.work_outline, size: 28, color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
                // 상단 배너 (광고용)
                Container(
                  width: double.infinity,
                  height: 128,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryPurple500,
                        AppTheme.primaryPink,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '광고 배너 영역',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 보유 포인트
                Container(
                  width: double.infinity,
                  padding: AppTheme.spacingSymmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderGray,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.yellow400,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'P',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '보유 포인트',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textGray700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            NumberFormat('#,###').format(_currentPoints),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            'P',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 오늘의 미션
                Container(
                  width: double.infinity,
                  padding: AppTheme.spacingSymmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderGray,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 미션',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing1),
                          Text(
                            '매주 일요일 00시에 초기화돼요',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing3),
                      ..._dailyMissions.map((mission) {
                        final isCompleted = _isMissionCompleted(mission.id) || 
                            (mission.id == 'daily-1' && _attendanceChecked);
                        return _buildMissionItem(
                          mission: mission,
                          isCompleted: isCompleted,
                          onTap: mission.id == 'daily-1' 
                              ? _handleAttendanceCheck 
                              : () => _handleMissionComplete(mission),
                        );
                      }),
                    ],
                  ),
                ),

                // 간단미션
                _buildMissionSection(
                  title: '간단미션',
                  missions: _simpleMissions,
                  showMore: _showMoreSimple,
                  onShowMoreToggle: () {
                    setState(() {
                      _showMoreSimple = !_showMoreSimple;
                    });
                  },
                ),

                // 참여미션
                _buildMissionSection(
                  title: '참여미션',
                  missions: _participationMissions,
                  showMore: _showMoreParticipation,
                  onShowMoreToggle: () {
                    setState(() {
                      _showMoreParticipation = !_showMoreParticipation;
                    });
                  },
                ),

                // 구매미션
                _buildMissionSection(
                  title: '구매미션',
                  missions: _purchaseMissions,
                  showMore: _showMorePurchase,
                  onShowMoreToggle: () {
                    setState(() {
                      _showMorePurchase = !_showMorePurchase;
                    });
                  },
                ),

                // 하단 배너 (광고용)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: AppTheme.spacing4,
                    right: AppTheme.spacing4,
                    top: AppTheme.spacing6,
                    bottom: AppTheme.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 128,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryPurple500,
                        ],
                      ),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                    child: Center(
                      child: Text(
                        '광고 배너 영역',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

            // 하단 여백 (하단 네비게이션 바 공간)
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildMissionSection({
    required String title,
    required List<_Mission> missions,
    required bool showMore,
    required VoidCallback onShowMoreToggle,
  }) {
    final displayedMissions = showMore ? missions : missions.take(5).toList();

    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onShowMoreToggle,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                  child: Padding(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing1,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing1),
                        IconMapper.icon(
                          'chevrondown',
                          size: 16,
                          color: AppTheme.textSecondary,
                        ) ??
                            Transform.rotate(
                              angle: showMore ? 3.14159 : 0,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          ...displayedMissions.map((mission) {
            final isCompleted = _isMissionCompleted(mission.id);
            return _buildMissionItem(
              mission: mission,
              isCompleted: isCompleted,
              onTap: () => _handleMissionComplete(mission),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMissionItem({
    required _Mission mission,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
      child: Row(
        children: [
          // 사진 미리보기 영역 (4번 사진 스타일: 정사각형, 라운드, 그라데이션)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              gradient: mission.category == 'daily'
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.purple100, AppTheme.primaryPurple.withOpacity(0.3)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.green200, AppTheme.blue100],
                    ),
            ),
            child: ClipRRect(
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              child: mission.icon != null
                  ? Center(
                      child: Text(
                        mission.icon!,
                        style: const TextStyle(fontSize: 28),
                      ),
                    )
                  : mission.iconUrl != null && mission.iconUrl!.startsWith('http')
                      ? Image.network(
                          mission.iconUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildMissionPlaceholder(),
                        )
                      : _buildMissionPlaceholder(),
            ),
          ),
          SizedBox(width: AppTheme.spacing3),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.spacing1 / 2),
                Text(
                  mission.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppTheme.spacing2),
          // 버튼 영역
          ElevatedButton(
            onPressed: isCompleted ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted 
                  ? AppTheme.borderGray300 
                  : AppTheme.primaryPurple,
              foregroundColor: isCompleted 
                  ? AppTheme.textSecondary 
                  : Colors.white,
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
            ),
            child: isCompleted
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconMapper.icon('check', size: 16, color: AppTheme.textSecondary) ??
                          const Icon(Icons.check, size: 16),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        '완료',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '${mission.points}P',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Mission {
  final String id;
  final String title;
  final String description;
  final int points;
  final String? icon;
  final String? iconUrl;
  final bool completed;
  final String category;

  _Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.icon,
    this.iconUrl,
    required this.completed,
    required this.category,
  });
}
