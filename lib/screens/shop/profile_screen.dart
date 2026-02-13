import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../models/user.dart';
import '../../services/work_check_service.dart';
import '../../services/schedule_service.dart';
import '../../utils/error_handler.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'vip_status_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'jobs_list_screen.dart';
import 'applicants_screen.dart';
import 'verification_screen.dart';
import 'my_spaces_screen.dart';
import 'profile_edit_screen.dart';
import '../../models/shop_tier.dart';

/// Shop 프로필 화면
class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  int _currentNavIndex = 3;
  bool _isLoading = true;
  int _vipTotalCompleted = 0;
  String _vipLevel = 'bronze';
  int _ongoingSchedules = 0;
  
  final WorkCheckService _workCheckService = WorkCheckService();
  final ScheduleService _scheduleService = ScheduleService();

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
      // VIP 통계 조회
      try {
        final vipStats = await _workCheckService.getShopStats();
        setState(() {
          _vipTotalCompleted = vipStats['totalCompleted'] as int? ?? 0;
          _vipLevel = (vipStats['vipLevel'] ?? vipStats['tier'] ?? 'bronze').toString();
        });
      } catch (e) {
        // VIP 통계 조회 실패 시 기본값 유지
      }
      
      // 오늘 일정 조회
      try {
        final todaySchedules = await _scheduleService.getTodaySchedules();
        setState(() {
          _ongoingSchedules = todaySchedules.length;
        });
      } catch (e) {
        // 스케줄 조회 실패 시 기본값 유지
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Color> _getAvatarGradient(String userId) {
    final gradients = [
      [const Color(0xFFC084FC), const Color(0xFFEC4899)], // purple-400 to pink-500
      [const Color(0xFFF472B6), const Color(0xFFEF4444)], // pink-400 to red-500
      [const Color(0xFFFB7185), const Color(0xFFF97316)], // red-400 to orange-500
      [const Color(0xFFA855F7), const Color(0xFFEC4899)], // violet-400 to pink-500
      [const Color(0xFFE879F9), const Color(0xFFF472B6)], // fuchsia-400 to pink-500
      [const Color(0xFF9333EA), const Color(0xFF6366F1)], // purple-500 to indigo-500
      [const Color(0xFF6366F1), const Color(0xFFA855F7)], // indigo-400 to purple-500
      [const Color(0xFF9333EA), const Color(0xFFEC4899)], // purple-500 to pink-500
    ];
    
    int hash = 0;
    for (int i = 0; i < userId.length; i++) {
      hash = userId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % gradients.length;
    return gradients[index];
  }

  String _getLoginMethodLabel(String? method) {
    switch (method) {
      case 'kakao':
        return '카카오';
      case 'naver':
        return '네이버';
      case 'google':
        return '구글';
      default:
        return '이메일';
    }
  }

  Color _getLoginMethodColor(String? method) {
    switch (method) {
      case 'kakao':
        return Colors.yellow.shade700;
      case 'naver':
        return Colors.green.shade700;
      case 'google':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getLoginMethodBgColor(String? method) {
    switch (method) {
      case 'kakao':
        return Colors.yellow.shade100;
      case 'naver':
        return Colors.green.shade100;
      case 'google':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          // Sticky 헤더
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.backgroundWhite,
            elevation: 0,
            leading: null,
            automaticallyImplyLeading: false,
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
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
                      );
                    },
                    child: Text(
                      'HairSpare',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 24, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShopSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 프로필 정보 섹션
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
                children: [
                  Row(
                    children: [
                      // 프로필 사진
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: user != null
                                    ? _getAvatarGradient(user.id)
                                    : [const Color(0xFFC084FC), const Color(0xFFEC4899)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: user?.profileImage != null
                                ? ClipOval(
                                    child: Image.network(
                                      user!.profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopProfileEditScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppTheme.spacing4),
                      // 프로필 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.name ?? '미용실',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacing2),
                                if (user != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getLoginMethodBgColor(null), // TODO: 로그인 방법 정보 추가 필요
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      _getLoginMethodLabel(null),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getLoginMethodColor(null),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing2),
                            if (user?.email != null)
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16, color: AppTheme.textSecondary),
                                  SizedBox(width: AppTheme.spacing1),
                                  Text(
                                    user!.email!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            if (user?.phone != null) ...[
                              SizedBox(height: AppTheme.spacing1),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                                  SizedBox(width: AppTheme.spacing1),
                                  Text(
                                    user!.phone!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 프로필 수정 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopProfileEditScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text(
                        '프로필 수정',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.backgroundGray,
                        foregroundColor: AppTheme.textGray700,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing2 + AppTheme.spacing1 / 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 빠른 통계 섹션
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, size: 20, color: Color(ShopTierExtension.parse(_vipLevel).colorValue)),
                            SizedBox(width: AppTheme.spacing1),
                            Text(
                              ShopTierExtension.parse(_vipLevel).name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(ShopTierExtension.parse(_vipLevel).colorValue),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacing1),
                        const Text(
                          '등급',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
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
                        Text(
                          '$_vipTotalCompleted',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing1),
                        const Text(
                          '완료 근무',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
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
                        Text(
                          '$_ongoingSchedules',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing1),
                        const Text(
                          '진행중',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 메뉴 항목
          SliverPadding(
            padding: EdgeInsets.all(AppTheme.spacing4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final menuItem = _menuItems[index];
                  return _buildMenuItem(menuItem);
                },
                childCount: _menuItems.length,
              ),
            ),
          ),

          // 로그아웃 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('로그아웃하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await authProvider.logout();
                    // TODO: 로그인 화면으로 이동
                  }
                },
                icon: const Icon(Icons.logout, size: 20, color: AppTheme.urgentRed),
                label: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: AppTheme.urgentRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.red50,
                  foregroundColor: AppTheme.urgentRed,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    side: BorderSide(color: AppTheme.red200, width: 1),
                  ),
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
              // 현재 화면
              break;
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing2),
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
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        title: Text(
          item.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          item.description,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
        onTap: () => item.onTap(context),
      ),
    );
  }

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.star,
      label: 'VIP 등급',
      description: '근무 통계 및 VIP 등급 확인',
      color: AppTheme.primaryPurple,
      bgColor: AppTheme.primaryPurple.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopVipStatusScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.calendar_today,
      label: '스케줄 관리',
      description: '근무 일정 확인 및 관리',
      color: Colors.blue,
      bgColor: Colors.blue.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopScheduleScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.work,
      label: '공고 관리',
      description: '등록한 공고 확인 및 관리',
      color: Colors.indigo,
      bgColor: Colors.indigo.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopJobsListScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.business,
      label: '내 공간 관리',
      description: '등록한 공간 확인 및 관리',
      color: Colors.teal,
      bgColor: Colors.teal.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopMySpacesScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.people,
      label: '지원자 관리',
      description: '지원자 확인 및 승인/거절',
      color: Colors.blue,
      bgColor: Colors.blue.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopApplicantsScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.payment,
      label: '결제 정보',
      description: '결제 내역 및 구독 관리',
      color: AppTheme.primaryPurple,
      bgColor: AppTheme.primaryPurple.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopPaymentScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.verified,
      label: '인증 관리',
      description: '사업자·본인·대리인 인증',
      color: Colors.green,
      bgColor: Colors.green.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopVerificationScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.settings,
      label: '설정',
      description: '앱 설정 및 계정 관리',
      color: Colors.grey,
      bgColor: Colors.grey.withOpacity(0.1),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopSettingsScreen()),
        );
      },
    ),
  ];
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final void Function(BuildContext) onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
