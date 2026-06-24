import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/shell_navigation.dart';
import 'package:hairspare/view_models/challenge_profile_view_model.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_links_section.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_featured_videos_row.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_header.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_stats_grid.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_subscribe_bar.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_videos_tab.dart';
import 'package:hairspare/widgets/common/shared_app_bar.dart';

/// 챌린지 프로필 (본인 · 타인 크리에이터).
class ChallengeProfileScreen extends StatefulWidget {
  const ChallengeProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ChallengeProfileScreen> createState() => _ChallengeProfileScreenState();
}

class _ChallengeProfileScreenState extends State<ChallengeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChallengeProfileViewModel _viewModel;
  late String _targetUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    _targetUserId = widget.userId ?? auth.currentUser?.id ?? 'guest';
    final isOwn = widget.userId == null;

    _viewModel = ChallengeProfileViewModel(
      targetUserId: _targetUserId,
      isOwnProfile: isOwn,
      canEdit: isOwn,
    )..loadAll();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _tabController.indexIsChanging == false) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openVideo(MyChallenge video) {
    ShellNavigation.pushChallengeFeed(
      context,
      creatorId: _targetUserId,
      initialVideoId: video.id,
    );
  }

  Future<void> _openEdit(ChallengeProfile profile) async {
    final updated =
        await ShellNavigation.pushChallengeProfileEdit(context, profile);
    if (updated == true) {
      await _viewModel.loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChallengeProfileViewModel>.value(
      value: _viewModel,
      child: Consumer<ChallengeProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundGray,
            appBar: SharedAppBar(
              title: '챌린지 프로필',
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryPurple,
                tabs: [
                  const Tab(text: '프로필'),
                  Tab(text: vm.videosTabLabel),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _ProfileTabContent(
                  onEdit: _openEdit,
                  onVideoTap: _openVideo,
                  onSeeAllVideos: () => _tabController.animateTo(1),
                ),
                ChallengeProfileVideosTab(
                  targetUserId: _targetUserId,
                  isOwnProfile: vm.isOwnProfile,
                  onVideoTap: _openVideo,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({
    required this.onEdit,
    required this.onVideoTap,
    required this.onSeeAllVideos,
  });

  final Future<void> Function(ChallengeProfile profile) onEdit;
  final void Function(MyChallenge video) onVideoTap;
  final VoidCallback onSeeAllVideos;

  @override
  Widget build(BuildContext context) {
    return Selector<ChallengeProfileViewModel, _ProfileTabUi>(
      selector: (_, vm) => _ProfileTabUi(
        isLoading: vm.isLoading,
        profile: vm.profile,
        canEdit: vm.canEdit,
        featured: vm.featuredVideos,
        featuredLoading: vm.isFeaturedLoading,
      ),
      builder: (context, ui, _) {
        if (ui.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = ui.profile;
        if (profile == null) {
          return const Center(child: Text('프로필을 불러올 수 없습니다'));
        }

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ChallengeProfileViewModel>().loadAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChallengeProfileHeader(
                  profile: profile,
                  showEditButton: ui.canEdit,
                  onEdit: () => onEdit(profile),
                ),
                // 구독 버튼 위치: 아래 [ChallengeProfileSubscribeBar] 블록만
                // Column 안에서 원하는 순서로 옮기면 됩니다.
                const ChallengeProfileSubscribeBar(),
                ChallengeProfileStatsGrid(profile: profile),
                ChallengeProfileLinksSection(profile: profile),
                ChallengeProfileFeaturedVideosRow(
                  videos: ui.featured,
                  isLoading: ui.featuredLoading,
                  onVideoTap: onVideoTap,
                  onSeeAllTap: onSeeAllVideos,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTabUi {
  const _ProfileTabUi({
    required this.isLoading,
    required this.profile,
    required this.canEdit,
    required this.featured,
    required this.featuredLoading,
  });

  final bool isLoading;
  final ChallengeProfile? profile;
  final bool canEdit;
  final List<MyChallenge> featured;
  final bool featuredLoading;

  @override
  bool operator ==(Object other) =>
      other is _ProfileTabUi &&
      isLoading == other.isLoading &&
      profile == other.profile &&
      canEdit == other.canEdit &&
      featuredLoading == other.featuredLoading &&
      featured.length == other.featured.length;

  @override
  int get hashCode => Object.hash(
        isLoading,
        profile,
        canEdit,
        featuredLoading,
        featured.length,
      );
}
