import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 모델검색 진입 화면 — "조건으로 찾기"(스와이프)와 "날짜로 찾기" 중 선택.
class ModelMatchEntryScreen extends StatelessWidget {
  const ModelMatchEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '모델검색'),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '어떻게 찾아볼까요?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),
            _EntryCard(
              icon: Icons.favorite,
              iconGradient: AppTheme.stitchHeroGradient,
              title: '조건으로 찾기',
              subtitle: '원하는 조건을 설정하고 스와이프로 모델을 만나보세요',
              onTap: () => ShellNavigation.push(context, 'model_match/filter'),
            ),
            const SizedBox(height: AppTheme.spacing4),
            _EntryCard(
              icon: Icons.calendar_month_outlined,
              iconGradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.stitchPrimaryContainer],
              ),
              title: '날짜로 찾기',
              subtitle: '원하는 날짜에 가능한 모델을 바로 찾아보세요',
              onTap: () => ShellNavigation.push(context, 'model_match/by_date'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray),
            boxShadow: AppTheme.stitchSoftShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
