import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../spare_profile/spare_profile_menu_item.dart';

/// 모델 마이 탭 — 모델 전용 메뉴 목록.
class ModelProfileMenuSection extends StatelessWidget {
  const ModelProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Column(
        children: [
          SpareProfileMenuItem(
            icon: IconMapper.icon('calendar') ?? const Icon(Icons.calendar_today),
            label: '내 스케줄',
            description: '시술 일정 확인',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => context.push(AppRoutes.modelProfileSchedule),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('creditcard') ?? const Icon(Icons.credit_card),
            label: '결제 정보',
            description: '예약금 결제 내역',
            color: AppTheme.stitchPrimaryContainer,
            bgColor: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
            onTap: () => context.push(AppRoutes.modelProfilePayment),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('users') ?? const Icon(Icons.people),
            label: '추천하기',
            description: '친구 추천 및 보상',
            color: Colors.pink,
            bgColor: Colors.pink.withValues(alpha: 0.1),
            onTap: () => context.push(AppRoutes.modelProfileReferral),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('shield') ?? const Icon(Icons.shield),
            label: '인증 관리',
            description: '본인인증',
            color: AppTheme.primaryGreen,
            bgColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            onTap: () => context.push(AppRoutes.modelProfileVerification),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SpareProfileMenuItem(
            icon: IconMapper.icon('settings') ?? const Icon(Icons.settings),
            label: '설정',
            description: '앱 설정 및 계정 관리',
            color: AppTheme.textSecondary,
            bgColor: AppTheme.backgroundGray,
            onTap: () => context.push(AppRoutes.modelProfileSettings),
          ),
        ],
      ),
    );
  }
}
