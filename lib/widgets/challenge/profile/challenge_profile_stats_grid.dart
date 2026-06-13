import 'package:flutter/material.dart';

import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/count_format.dart';

/// 프로필 통계 2×2 카드.
class ChallengeProfileStatsGrid extends StatelessWidget {
  const ChallengeProfileStatsGrid({super.key, required this.profile});

  final ChallengeProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: CountFormat.compact(profile.videoCount),
                  label: '내 영상',
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: _StatCard(
                  value: CountFormat.compact(profile.subscriberCount),
                  label: '구독자',
                  color: AppTheme.urgentRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: CountFormat.compact(profile.totalLikes),
                  label: '총 좋아요',
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: _StatCard(
                  value: CountFormat.compact(profile.totalViews),
                  label: '총 조회수',
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing3,
        horizontal: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
