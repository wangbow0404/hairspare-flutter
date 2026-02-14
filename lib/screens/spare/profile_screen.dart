import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/customer_service_section.dart';
import '../spare/payment_screen.dart';
import '../spare/energy_screen.dart';
import '../spare/schedule_screen.dart';
import '../spare/work_check_screen.dart';
import '../spare/verification_screen.dart';
import '../spare/profile_edit_screen.dart';
import '../spare/referral_screen.dart';
import '../spare/settings_screen.dart';
import '../spare/my_applications_screen.dart';
import '../spare/my_space_bookings_screen.dart';
import '../spare/challenge_profile_screen.dart';
import '../spare/subscriptions_screen.dart';
import '../spare/home_screen.dart';
import '../spare/favorites_screen.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';

/// Next.js와 동일한 프로필 화면
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 3; // 마이 탭

  @override
  void initState() {
    super.initState();
    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnergyProvider>().loadWallet();
      context.read<ScheduleProvider>().loadSchedules();
    });
  }

  // 사용자 ID 기반 일관된 그라데이션 색상 생성
  List<Color> _getAvatarGradient(String userId) {
    final gradients = [
      [const Color(0xFF60A5FA), const Color(0xFFA855F7)], // blue-400 to purple-500
      [const Color(0xFFC084FC), const Color(0xFFEC4899)], // purple-400 to pink-500
      [const Color(0xFFF472B6), const Color(0xFFEF4444)], // pink-400 to red-500
      [const Color(0xFFFB7185), const Color(0xFFF97316)], // red-400 to orange-500
      [const Color(0xFFFB923C), const Color(0xFFEAB308)], // orange-400 to yellow-500
      [const Color(0xFFFACC15), const Color(0xFF22C55E)], // yellow-400 to green-500
      [const Color(0xFF4ADE80), const Color(0xFF14B8A6)], // green-400 to teal-500
      [const Color(0xFF2DD4BF), const Color(0xFF06B6D4)], // teal-400 to cyan-500
      [const Color(0xFF22D3EE), const Color(0xFF3B82F6)], // cyan-400 to blue-500
      [const Color(0xFF818CF8), const Color(0xFFA855F7)], // indigo-400 to purple-500
    ];
    
    // userId의 해시값을 사용하여 일관된 색상 선택
    int hash = 0;
    for (int i = 0; i < userId.length; i++) {
      hash = userId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 70,
          ),
          child: Column(
            children: [
            // Header
            Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      NavigationHelper.navigateToHomeFromLogo(context);
                    },
                    child: Text(
                      'HairSpare',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: IconMapper.icon('settings', size: 24, color: AppTheme.textSecondary) ??
                        const Icon(Icons.settings, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Profile Section
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderGray,
                    width: 1,
                  ),
                ),
              ),
              padding: AppTheme.spacing(AppTheme.spacing6),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  final displayName = user?.name ?? user?.username ?? '사용자';
                  final displayEmail = user?.email ?? '';
                  final displayPhone = user?.phone ?? '';

                  return Column(
                    children: [
                      Row(
                        children: [
                          // 프로필 사진
                          Stack(
                            children: [
                              Container(
                                width: 96, // w-24
                                height: 96, // h-24
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: user?.id != null
                                        ? _getAvatarGradient(user!.id)
                                        : [AppTheme.primaryBlue, AppTheme.primaryPurple],
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                  boxShadow: AppTheme.shadowLg,
                                ),
                                child: user?.profileImage != null
                                    ? ClipRRect(
                                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                        child: Image.network(
                                          user!.profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: IconMapper.icon('user', size: 48, color: Colors.white) ??
                                            const Icon(Icons.person, size: 48, color: Colors.white),
                                      ),
                              ),
                              // 편집 버튼
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 32, // w-8
                                    height: 32, // h-8
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      boxShadow: AppTheme.shadowMd,
                                    ),
                                    child: IconMapper.icon('edit', size: 16, color: Colors.white) ??
                                        const Icon(Icons.edit, size: 16, color: Colors.white),
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
                                      displayName,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spacing2),
                                    Container(
                                      padding: AppTheme.spacingSymmetric(
                                        horizontal: AppTheme.spacing2,
                                        vertical: AppTheme.spacing1 / 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundGray,
                                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '이메일',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textGray700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.spacing2),
                                if (displayEmail.isNotEmpty)
                                  Row(
                                    children: [
                                      IconMapper.icon('mail', size: 16, color: AppTheme.textSecondary) ??
                                          const Icon(Icons.email, size: 16, color: AppTheme.textSecondary),
                                      SizedBox(width: AppTheme.spacing2),
                                      Text(
                                        displayEmail,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (displayPhone.isNotEmpty) ...[
                                  SizedBox(height: AppTheme.spacing2),
                                  Row(
                                    children: [
                                      IconMapper.icon('phone', size: 16, color: AppTheme.textSecondary) ??
                                          const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                                      SizedBox(width: AppTheme.spacing2),
                                      Text(
                                        displayPhone,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.backgroundGray,
                            foregroundColor: AppTheme.textGray700,
                            elevation: 0,
                            padding: AppTheme.spacingSymmetric(
                              horizontal: AppTheme.spacing4,
                              vertical: AppTheme.spacing2 + AppTheme.spacing1 / 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconMapper.icon('user', size: 16, color: AppTheme.textGray700) ??
                                  const Icon(Icons.person, size: 16, color: AppTheme.textGray700),
                              SizedBox(width: AppTheme.spacing2),
                              Text(
                                '프로필 수정',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textGray700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Quick Stats
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderGray,
                    width: 1,
                  ),
                ),
              ),
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Consumer2<EnergyProvider, ScheduleProvider>(
                builder: (context, energyProvider, scheduleProvider, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              energyProvider.isLoading
                                  ? '-'
                                  : energyProvider.balance.toString(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlueDark, // blue-600
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '에너지',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                              scheduleProvider.isLoading
                                  ? '-'
                                  : scheduleProvider.scheduledCount.toString(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '진행중',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                              scheduleProvider.isLoading
                                  ? '-'
                                  : scheduleProvider.completedCount.toString(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.green600, // green-600
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '완료',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Menu Items
            Padding(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Column(
                children: [
                  _MenuItem(
                    icon: IconMapper.icon('video') ?? const Icon(Icons.video_library),
                    label: '챌린지 프로필',
                    description: '내 영상 및 챌린지 프로필 관리',
                    color: AppTheme.primaryPurple,
                    bgColor: AppTheme.primaryPurple.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChallengeProfileScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('heart') ?? const Icon(Icons.favorite),
                    label: '구독한 크리에이터',
                    description: '내가 구독한 크리에이터 목록',
                    color: AppTheme.urgentRed,
                    bgColor: AppTheme.urgentRed.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SubscriptionsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('zap') ?? const Icon(Icons.flash_on),
                    label: '내 에너지',
                    description: '에너지 잔액 및 거래 내역',
                    color: AppTheme.yellow400,
                    bgColor: AppTheme.yellow400.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EnergyScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('calendar') ?? const Icon(Icons.calendar_today),
                    label: '내 스케줄',
                    description: '근무 일정 확인 및 체크인',
                    color: AppTheme.primaryBlue,
                    bgColor: AppTheme.primaryBlue.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkCheckScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('filetext') ?? const Icon(Icons.assignment),
                    label: '내 지원 현황',
                    description: '공고 지원 내역 확인',
                    color: AppTheme.primaryBlue,
                    bgColor: AppTheme.primaryBlue.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApplicationsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('home') ?? const Icon(Icons.room),
                    label: '내 공간 예약',
                    description: '공간대여 예약 내역',
                    color: AppTheme.primaryGreen,
                    bgColor: AppTheme.primaryGreen.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MySpaceBookingsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('creditcard') ?? const Icon(Icons.credit_card),
                    label: '결제 정보',
                    description: '결제 내역 및 구독 관리',
                    color: AppTheme.primaryPurple,
                    bgColor: AppTheme.primaryPurple.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('users') ?? const Icon(Icons.people),
                    label: '추천하기',
                    description: '친구 추천 및 보상',
                    color: Colors.pink,
                    bgColor: Colors.pink.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReferralScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('shield') ?? const Icon(Icons.shield),
                    label: '인증 관리',
                    description: '본인인증 및 면허 인증',
                    color: AppTheme.primaryGreen,
                    bgColor: AppTheme.primaryGreen.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VerificationScreen()),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  _MenuItem(
                    icon: IconMapper.icon('settings') ?? const Icon(Icons.settings),
                    label: '설정',
                    description: '앱 설정 및 계정 관리',
                    color: AppTheme.textSecondary,
                    bgColor: AppTheme.backgroundGray,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
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
                                child: const Text('로그아웃'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red50, // red-50
                        foregroundColor: AppTheme.red600, // red-600
                        elevation: 0,
                        padding: AppTheme.spacingSymmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          side: BorderSide(
                            color: AppTheme.red200, // red-200
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconMapper.icon('logout', size: 20, color: AppTheme.red600) ??
                              const Icon(Icons.logout, size: 20, color: AppTheme.red600),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '로그아웃',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.red600, // red-600
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 고객센터 섹션
            CustomerServiceSection(),
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
              // 마이는 현재 화면이므로 아무것도 하지 않음
              break;
          }
        },
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: AppTheme.spacing(AppTheme.spacing4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.borderGray,
              width: 1,
            ),
            boxShadow: _isPressed ? AppTheme.shadowMd : AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: _isPressed ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 48, // w-12
                  height: 48, // h-12
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: widget.color,
                      size: 20, // w-5 h-5
                    ),
                    child: widget.icon,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing1 / 2),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _isPressed ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: IconMapper.icon('chevronright', size: 20, color: AppTheme.textTertiary) ??
                    const Icon(Icons.chevron_right, size: 20, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
