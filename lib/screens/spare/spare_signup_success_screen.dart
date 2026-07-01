import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_navigation.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass_modal.dart';

/// 회원가입 완료 화면.
class SpareSignupSuccessScreen extends StatelessWidget {
  const SpareSignupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isModel = context.select<AuthProvider, bool>(
      (auth) => auth.currentUser?.isModelAccount ?? false,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            children: [
              const Spacer(),
              const GlassModalHeroIcon(emoji: '🎉'),
              const SizedBox(height: AppTheme.spacing6),
              const Text(
                '회원가입이 완료되었어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing3),
              const Text(
                '이제 헤어스페어를 이용할 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.stitchTextSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isModel) {
                      AppNavigation.goModelMainTab(context, 0);
                    } else {
                      AppNavigation.goSpareMainTab(context, 0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: const Text(
                    '홈으로 가기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
