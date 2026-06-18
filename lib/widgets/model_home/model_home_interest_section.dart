import 'package:flutter/material.dart';

import '../../models/model_home_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';

/// 모델 홈 — 받은 관심 그리드.
class ModelHomeInterestSection extends StatelessWidget {
  const ModelHomeInterestSection({
    super.key,
    required this.interests,
  });

  final List<ModelHomeInterest> interests;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '받은 관심',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              SizedBox(width: AppTheme.spacing1),
              Icon(
                Icons.favorite,
                size: 20,
                color: AppTheme.urgentRed,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          if (interests.isEmpty)
            const _InterestEmpty()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacing2,
                mainAxisSpacing: AppTheme.spacing2,
                childAspectRatio: 0.78,
              ),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                return _InterestCard(interest: interests[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _InterestEmpty extends StatelessWidget {
  const _InterestEmpty();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppTheme.spacing6),
        child: Center(
          child: Text(
            '아직 받은 관심이 없어요.\n프로필을 완성하고 매칭 노출을 켜 보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.stitchTextSecondary,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.interest});

  final ModelHomeInterest interest;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.stitchPrimaryContainer,
                    AppTheme.primaryPurpleLight,
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.surfaceContainerLow,
                      backgroundImage: interest.avatarUrl != null
                          ? NetworkImage(interest.avatarUrl!)
                          : null,
                      child: interest.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.stitchTextSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      interest.designerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${interest.treatment} • ${interest.region}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: interest.isPrimaryCta
                          ? FilledButton.icon(
                              onPressed: () =>
                                  AppBarNavigation.pushMessages(context),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16),
                              label: const Text('채팅하기'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    AppTheme.stitchPrimaryContainer,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacing2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLg,
                                  ),
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () =>
                                  AppBarNavigation.pushMessages(context),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16),
                              label: const Text('채팅하기'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppTheme.stitchPrimaryContainer,
                                side: const BorderSide(
                                  color: AppTheme.stitchPrimaryContainer,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacing2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLg,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
