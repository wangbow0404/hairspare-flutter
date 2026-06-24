import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass_modal.dart';

/// 샵 회원가입 완료 — 사업자·본인·대리인 인증 안내.
class ShopSignupSuccessScreen extends StatelessWidget {
  const ShopSignupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                '사업자·본인 인증을 완료하면\n공고 등록·인력 매칭 등 모든 기능을 이용할 수 있어요.\n대리인 운영 시 승인 신청도 진행해 주세요.',
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
                  onPressed: () =>
                      context.push(AppRoutes.shopProfileVerification),
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
                    '인증 시작하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => AppNavigation.goShopHome(context),
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
                onPressed: () => AppNavigation.goShopHome(context),
                child: const Text('나중에 하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
