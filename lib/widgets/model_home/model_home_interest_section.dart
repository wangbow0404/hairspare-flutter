import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/model_home_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/match_profile_navigation.dart';
import '../../view_models/matching_view_model.dart';
import '../common/app_network_image.dart';

/// 모델 홈 — 받은 관심(pending) Sliver 그리드.
abstract final class ModelHomeInterestSection {
  ModelHomeInterestSection._();

  static const _header = Row(
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
  );

  static List<Widget> buildSlivers(BuildContext context) {
    return [
      const SliverPadding(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing6,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        sliver: SliverToBoxAdapter(child: _header),
      ),
      Selector<MatchingViewModel, String>(
        selector: (_, vm) => vm.pendingInterestKey,
        builder: (context, _, __) {
          final interests =
              context.read<MatchingViewModel>().pendingHomeInterests;
          if (interests.isEmpty) {
            return const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              sliver: SliverToBoxAdapter(child: _InterestEmpty()),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacing2,
                mainAxisSpacing: AppTheme.spacing2,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _InterestCard(interest: interests[index]),
                childCount: interests.length,
                addRepaintBoundaries: true,
              ),
            ),
          );
        },
      ),
    ];
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

  static const int _avatarCachePx = 112;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
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
                      _InterestAvatar(avatarUrl: interest.avatarUrl),
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
                        child: FilledButton.icon(
                          onPressed: () => _openProfile(context, interest.id),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('프로필 보기'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.stitchPrimaryContainer,
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
                        ),
                      ),
                    ],
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

class _InterestAvatar extends StatelessWidget {
  const _InterestAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: AppNetworkImage(
          imageUrl: avatarUrl,
          memCacheWidth: _InterestCard._avatarCachePx,
          fallbackIcon: Icons.person,
        ),
      ),
    );
  }
}

Future<void> _openProfile(BuildContext context, String likeId) async {
  final vm = context.read<MatchingViewModel>();
  final refreshed = await openMatchProfile(
    context,
    likeId: likeId,
    initialLike: vm.findLikeLocal(likeId),
  );
  if (refreshed == true && context.mounted) {
    await context.read<MatchingViewModel>().refresh();
  }
}
