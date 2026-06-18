import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass_modal.dart';
import '../../screens/spare/verification_screen.dart';

/// 회원가입 완료 — 본인인증 안내.
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
              Text(
                isModel
                    ? '모델 매칭 노출을 위해\n본인인증이 필수입니다.'
                    : '본인인증을 완료하면\n공고 지원·모델 매칭 등 모든 기능을 이용할 수 있어요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const VerificationScreen(),
                      ),
                    );
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
                    '본인인증 하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (!isModel) ...[
                const SizedBox(height: AppTheme.spacing3),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => AppNavigation.goSpareHome(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppTheme.borderGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text(
                      '홈으로 가기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                TextButton(
                  onPressed: () => context.go(AppRoutes.spareLogin),
                  child: const Text('나중에 하기'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
