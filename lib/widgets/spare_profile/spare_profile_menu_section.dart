import 'package:flutter/material.dart';

import '../../core/router/spare_profile_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import 'spare_profile_menu_item.dart';

/// 챌린지·에너지·스케줄 등 메뉴 목록.
class SpareProfileMenuSection extends StatelessWidget {
  const SpareProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Column(
        children: [
          SpareProfileMenuItem(
            icon: IconMapper.icon('video') ?? const Icon(Icons.video_library),
            label: '챌린지 프로필',
            description: '내 영상 및 챌린지 프로필 관리',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushChallengeProfile(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('image') ?? const Icon(Icons.collections_outlined),
            label: '작업 포트폴리오',
            description: '모델 매칭·프로필에 노출할 작업 사진',
            color: AppTheme.primaryPurple,
            bgColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushPortfolio(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('heart') ?? const Icon(Icons.favorite),
            label: '구독한 크리에이터',
            description: '내가 구독한 크리에이터 목록',
            color: AppTheme.urgentRed,
            bgColor: AppTheme.urgentRed.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushSubscriptions(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('calendar') ?? const Icon(Icons.calendar_today),
            label: '내 스케줄',
            description: '근무 일정 확인 및 체크인',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushWorkCheck(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('filetext') ?? const Icon(Icons.assignment),
            label: '내 지원 현황',
            description: '공고 지원 내역 확인',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushMyApplications(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('creditcard') ?? const Icon(Icons.credit_card),
            label: '결제 정보',
            description: '결제 내역 및 구독 관리',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushPayment(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('users') ?? const Icon(Icons.people),
            label: '추천하기',
            description: '친구 추천 및 보상',
            color: Colors.pink,
            bgColor: Colors.pink.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushReferral(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('shield') ?? const Icon(Icons.shield),
            label: '인증 관리',
            description: '본인인증',
            color: AppTheme.primaryGreen,
            bgColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            onTap: () => SpareProfileNavigation.pushVerification(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('settings') ?? const Icon(Icons.settings),
            label: '설정',
            description: '앱 설정 및 계정 관리',
            color: AppTheme.textSecondary,
            bgColor: AppTheme.backgroundGray,
            onTap: () => SpareProfileNavigation.pushSettings(context),
          ),
        ],
      ),
    );
  }
}
