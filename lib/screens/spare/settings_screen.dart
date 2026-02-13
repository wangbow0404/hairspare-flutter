import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../spare/profile_edit_screen.dart';
import '../spare/notifications_settings_screen.dart';
import '../spare/change_password_screen.dart';
import '../spare/delete_account_screen.dart';
import '../spare/login_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentNavIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  Future<void> _handleLogout() async {
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
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SpareLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          '설정',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Column(
          children: [
            // 설정 메뉴
            ...[
              {
                'icon': IconMapper.icon('user', size: 20, color: AppTheme.primaryBlue) ??
                    const Icon(Icons.person, size: 20, color: AppTheme.primaryBlue),
                'label': '프로필 수정',
                'route': const ProfileEditScreen(),
              },
              {
                'icon': IconMapper.icon('bell', size: 20, color: AppTheme.primaryPurple) ??
                    const Icon(Icons.notifications, size: 20, color: AppTheme.primaryPurple),
                'label': '알림 설정',
                'route': const NotificationsSettingsScreen(),
              },
              {
                'icon': IconMapper.icon('lock', size: 20, color: AppTheme.textSecondary) ??
                    const Icon(Icons.lock, size: 20, color: AppTheme.textSecondary),
                'label': '비밀번호 변경',
                'route': const ChangePasswordScreen(),
              },
              {
                'icon': IconMapper.icon('trash2', size: 20, color: AppTheme.urgentRed) ??
                    const Icon(Icons.delete, size: 20, color: AppTheme.urgentRed),
                'label': '계정 삭제',
                'route': const DeleteAccountScreen(),
              },
            ].map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacing2),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['route'] as Widget),
                    );
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  child: Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.borderGray),
                    ),
                    child: Row(
                      children: [
                        item['icon'] as Widget,
                        SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconMapper.icon('chevronright', size: 20, color: AppTheme.textTertiary) ??
                            const Icon(Icons.chevron_right, size: 20, color: AppTheme.textTertiary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: AppTheme.spacing4),
            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.urgentRedLight,
                  foregroundColor: AppTheme.urgentRed,
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  side: BorderSide(color: AppTheme.urgentRed.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconMapper.icon('logout', size: 20, color: AppTheme.urgentRed) ??
                        const Icon(Icons.logout, size: 20, color: AppTheme.urgentRed),
                    SizedBox(width: AppTheme.spacing2),
                    Text(
                      '로그아웃',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.urgentRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
}
