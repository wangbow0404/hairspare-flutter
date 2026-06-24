import 'package:flutter/material.dart';

import '../../core/router/spare_profile_navigation.dart';
import '../../theme/app_theme.dart';
import 'spare_profile_edit_section_card.dart';

/// 프로필 수정 — 포트폴리오·인증 바로가기.
class SpareProfileEditLinkCards extends StatelessWidget {
  const SpareProfileEditLinkCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SpareProfileEditSectionCard(
      title: '프로필 보완',
      subtitle: '매칭 성사율을 높이려면 아래 항목도 채워 주세요.',
      child: Column(
        children: [
          _ProfileEditLinkTile(
            icon: Icons.collections_outlined,
            iconColor: AppTheme.primaryPurple,
            title: '작업 포트폴리오',
            subtitle: '모델·샵에 노출할 시술 사진',
            onTap: () => SpareProfileNavigation.pushPortfolio(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          _ProfileEditLinkTile(
            icon: Icons.verified_user_outlined,
            iconColor: AppTheme.primaryGreen,
            title: '인증 관리',
            subtitle: '본인인증·자격증으로 신뢰도 UP',
            onTap: () => SpareProfileNavigation.pushVerification(context),
          ),
          const SizedBox(height: AppTheme.spacing2),
          _ProfileEditLinkTile(
            icon: Icons.video_library_outlined,
            iconColor: AppTheme.stitchPrimaryContainer,
            title: '챌린지 프로필',
            subtitle: '영상·챌린지용 별도 소개',
            onTap: () => SpareProfileNavigation.pushChallengeProfile(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditLinkTile extends StatelessWidget {
  const _ProfileEditLinkTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundGray,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.stitchTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
