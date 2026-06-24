import 'package:flutter/material.dart';

import '../../core/router/shop_profile_navigation.dart';
import '../../theme/app_theme.dart';
import '../spare_profile/spare_profile_menu_item.dart';

/// 샵 마이 탭 — 샵 전용 메뉴 목록.
class ShopProfileMenuSection extends StatelessWidget {
  const ShopProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Column(
        children: [
          SpareProfileMenuItem(
            icon: const Icon(Icons.star_rounded),
            label: 'VIP 등급',
            description: '근무 통계 및 VIP 등급 확인',
            color: AppTheme.primaryPurple,
            bgColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushVip(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.calendar_today),
            label: '스케줄 관리',
            description: '근무 일정 확인 및 관리',
            color: Colors.blue,
            bgColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushSchedule(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.work_outline),
            label: '공고 관리',
            description: '등록한 공고 확인 및 관리',
            color: Colors.indigo,
            bgColor: Colors.indigo.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushJobs(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.meeting_room_outlined),
            label: '내 공간 관리',
            description: '등록한 공간 확인 및 관리',
            color: Colors.teal,
            bgColor: Colors.teal.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushSpaces(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.people_outline),
            label: '지원자 관리',
            description: '지원자 확인 및 승인/거절',
            color: AppTheme.primaryBlue,
            bgColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushApplicants(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.collections_outlined),
            label: '작업 포트폴리오',
            description: '모델에게 보여줄 샵 작업 사진',
            color: AppTheme.primaryPurple,
            bgColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushPortfolio(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.credit_card_outlined),
            label: '결제 정보',
            description: '결제 내역 및 구독 관리',
            color: AppTheme.primaryPurple,
            bgColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushPayment(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.verified_outlined),
            label: '인증 관리',
            description: '사업자·본인·대리인 인증',
            color: AppTheme.primaryGreen,
            bgColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            onTap: () => ShopProfileNavigation.pushVerification(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: const Icon(Icons.settings_outlined),
            label: '설정',
            description: '앱 설정 및 계정 관리',
            color: AppTheme.textSecondary,
            bgColor: AppTheme.backgroundGray,
            onTap: () => ShopProfileNavigation.pushSettings(context),
          ),
        ],
      ),
    );
  }
}
