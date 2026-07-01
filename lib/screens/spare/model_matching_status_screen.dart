import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/match_like.dart';
import '../../providers/auth_provider.dart';
import '../../services/matching_service.dart';
import '../../core/router/app_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/match_profile_navigation.dart';
import '../../utils/messaging_navigation.dart';
import '../../view_models/matching_view_model.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_segment_tabs.dart';

/// 모델 매칭 탭 — 받은 관심(pending) / 매칭 목록.
class ModelMatchingStatusScreen extends StatefulWidget {
  const ModelMatchingStatusScreen({super.key});

  @override
  State<ModelMatchingStatusScreen> createState() =>
      _ModelMatchingStatusScreenState();
}

class _ModelMatchingStatusScreenState extends State<ModelMatchingStatusScreen> {
  MatchingViewModel? _matchingViewModel;
  bool _providersReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providersReady) return;
    _providersReady = true;

    final userId =
        context.read<AuthProvider>().currentUser?.id ?? 'mock-model-dev';
    _matchingViewModel = MatchingViewModel(sl<MatchingService>())
      ..load(modelUserId: userId);
  }

  @override
  void dispose() {
    _matchingViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _matchingViewModel;
    if (vm == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<MatchingViewModel>.value(
      value: vm,
      child: const _ModelMatchingBody(),
    );
  }
}

class _ModelMatchingBody extends StatefulWidget {
  const _ModelMatchingBody();

  @override
  State<_ModelMatchingBody> createState() => _ModelMatchingBodyState();
}

class _ModelMatchingBodyState extends State<_ModelMatchingBody> {
  String _activeTab = 'received';

  Future<void> _openProfile(String likeId) async {
    final vm = context.read<MatchingViewModel>();
    final refreshed = await openMatchProfile(
      context,
      likeId: likeId,
      initialLike: vm.findLikeLocal(likeId),
    );
    if (refreshed == true && mounted) {
      await context.read<MatchingViewModel>().refresh();
    }
  }

  void _openChat(String chatId) {
    MessagingNavigation.openChat(context, chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchingViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.receivedLikes.isEmpty && vm.matches.isEmpty) {
          return Scaffold(
            appBar: SpareSubpageAppBar(
              title: '매칭 현황',
              showToolbarActions: false,
              onBackPressed: () => AppNavigation.backFromModelTab(context),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final tabIndex = _activeTab == 'matched' ? 1 : 0;
        final list = _activeTab == 'matched' ? vm.matches : vm.receivedLikes;

        return Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: SpareSubpageAppBar(
            title: '매칭 현황',
            showToolbarActions: false,
            onBackPressed: () => AppNavigation.backFromModelTab(context),
          ),
          body: Column(
            children: [
              StitchSegmentTabs(
                tabs: const ['받은 관심', '매칭'],
                activeIndex: tabIndex,
                onChanged: (index) {
                  setState(() {
                    _activeTab = index == 1 ? 'matched' : 'received';
                  });
                },
              ),
              Expanded(
                child: list.isEmpty
                    ? StitchEmptyState(
                        message: _activeTab == 'matched'
                            ? '아직 매칭된 디자이너가 없어요'
                            : '받은 관심이 없어요',
                        iconName: 'heart',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppTheme.spacing4),
                        children: [
                          if (_activeTab == 'received')
                            _SummaryCard(
                              todayCount: vm.pendingCount,
                              isVisible: true,
                            ),
                          if (_activeTab == 'received')
                            const SizedBox(height: AppTheme.spacing4),
                          ...list.map(
                            (like) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.spacing2,
                              ),
                              child: _LikeListCard(
                                like: like,
                                isMatchedTab: _activeTab == 'matched',
                                onProfile: () => _openProfile(like.id),
                                onChat: like.chatId != null
                                    ? () => _openChat(like.chatId!)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.todayCount, required this.isVisible});

  final int todayCount;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Row(
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: AppTheme.urgentRed,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacing2),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                ),
                children: [
                  const TextSpan(text: '받은 관심 '),
                  TextSpan(
                    text: '$todayCount개',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stitchPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isVisible
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                isVisible ? '매칭 노출 중' : '노출 꺼짐',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isVisible
                      ? AppTheme.primaryGreen
                      : AppTheme.stitchTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeListCard extends StatelessWidget {
  const _LikeListCard({
    required this.like,
    required this.isMatchedTab,
    required this.onProfile,
    this.onChat,
  });

  final MatchLike like;
  final bool isMatchedTab;
  final VoidCallback onProfile;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final profile = like.fromProfile;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: InkWell(
        onTap: isMatchedTab ? onChat : onProfile,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: profile.avatarUrl != null
                      ? AppNetworkImage(
                          imageUrl: profile.avatarUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 104,
                          fallbackIcon: Icons.person_outline_rounded,
                        )
                      : const ColoredBox(
                          color: AppTheme.surfaceContainerLow,
                          child: Icon(
                            Icons.person,
                            color: AppTheme.stitchTextSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              if (isMatchedTab)
                FilledButton(
                  onPressed: onChat,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: const Text('채팅하기', style: TextStyle(fontSize: 13)),
                )
              else
                OutlinedButton(
                  onPressed: onProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.stitchPrimaryContainer,
                    side: const BorderSide(color: AppTheme.stitchPrimaryContainer),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: const Text('프로필 보기', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
