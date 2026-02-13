import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../screens/spare/login_screen.dart';
import '../../screens/shop/login_screen.dart' as shop;
import '../../theme/app_theme.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  bool _showStoreModal = false;

  void _handleRoleSelect(UserRole role) {
    // 역할에 따라 로그인 화면으로 이동
    // TODO: 네비게이션 라우터 설정 후 수정
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => role == UserRole.spare
            ? const SpareLoginScreen()
            : const shop.ShopLoginScreen(),
      ),
    );
  }

  void _handleStoreClick() {
    setState(() {
      _showStoreModal = true;
    });
  }

  Future<void> _handleBackPress() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('앱을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('종료'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackPress();
      },
      child: Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: AppTheme.gradientBackground,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Section
                      Column(
                        children: [
                          Text(
                            'HairSpare',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48, // 모바일: 48px, 데스크탑에서는 64px
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1.0, // tracking-tight
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppTheme.spacing3),
                          Text(
                            '스페어 급구 해결',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing12),
                      // Button Section
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            // 스페어 버튼
                            _RoleButton(
                              label: '스페어로 시작하기',
                              color: AppTheme.primaryBlue,
                              onTap: () => _handleRoleSelect(UserRole.spare),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            _RoleButton(
                              label: '미용실로 시작하기',
                              color: AppTheme.primaryPurple,
                              onTap: () => _handleRoleSelect(UserRole.shop),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            _RoleButton(
                              label: '스토어로 시작하기',
                              color: AppTheme.primaryGreen,
                              onTap: _handleStoreClick,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing8),
                      // Tagline
                      Text(
                        '미용실 스페어 매칭 플랫폼',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
          // 스토어 준비중 모달
          if (_showStoreModal)
            _StoreModal(
              onClose: () {
                setState(() {
                  _showStoreModal = false;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _StoreModal extends StatelessWidget {
  final VoidCallback onClose;

  const _StoreModal({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5), // bg-black bg-opacity-50
      child: GestureDetector(
        onTap: onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4), // p-4
              constraints: const BoxConstraints(maxWidth: 384), // max-w-md
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite, // bg-white
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl), // rounded-2xl
                boxShadow: AppTheme.shadowXl, // shadow-2xl
              ),
              padding: AppTheme.spacing(AppTheme.spacing6), // p-6
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 닫기 버튼
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: AppTheme.textTertiary, // text-gray-400
                      onPressed: onClose,
                    ),
                  ),
                  // 내용
                  Padding(
                    padding: AppTheme.spacingVertical(AppTheme.spacing4), // py-4
                    child: Column(
                      children: [
                        Text(
                          '스토어 서비스는 현재 준비중입니다!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 24, // text-2xl
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary, // text-gray-900
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.spacing4), // mt-4
                        Text(
                          '빠른 시일 내에 만나뵐 수 있도록 준비하겠습니다.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16, // text-base
                            color: AppTheme.textSecondary, // text-gray-600
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.spacing6), // mt-6
                        // 확인 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen, // bg-green-500
                              foregroundColor: Colors.white,
                              padding: AppTheme.spacingSymmetric(
                                horizontal: AppTheme.spacing3,
                                vertical: AppTheme.spacing3,
                              ), // py-3
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600, // font-semibold
                                color: Colors.white,
                              ),
                            ),
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
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('[RoleSelect] Button tapped: $label');
          onTap();
        },
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowLg,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
