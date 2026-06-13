import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/challenge_view_model.dart';
import 'challenge_feed_tab_button.dart';

/// AppBar 아래: 피드 탭(전체·구독) — 영상 영역 위 검은 띠.
class ChallengeFeedTabStrip extends StatelessWidget {
  const ChallengeFeedTabStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChallengeFeedTabButton(
            label: '전체',
            isSelected: vm.feedTabIndex == 0,
            onTap: () async {
              await context.read<ChallengeViewModel>().switchFeedTab(0);
            },
          ),
          const SizedBox(width: AppTheme.spacing4),
          ChallengeFeedTabButton(
            label: '구독',
            isSelected: vm.feedTabIndex == 1,
            onTap: () async {
              await context.read<ChallengeViewModel>().switchFeedTab(1);
            },
          ),
        ],
      ),
    );
  }
}

/// 상단 우측: 음소거, 전체화면, 더보기.
class ChallengeTopRightControls extends StatelessWidget {
  const ChallengeTopRightControls({
    super.key,
    required this.onMute,
    required this.onFullscreen,
    required this.onMore,
  });

  final VoidCallback onMute;
  final VoidCallback onFullscreen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();

    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: IconMapper.icon('volumeX', size: 20, color: Colors.white) ??
                    Icon(
                      vm.isMuted ? Icons.volume_off : Icons.volume_up,
                      size: 20,
                      color: Colors.white,
                    ),
                onPressed: onMute,
              ),
              IconButton(
                icon: IconMapper.icon('maximize', size: 20, color: Colors.white) ??
                    const Icon(Icons.fullscreen, size: 20, color: Colors.white),
                onPressed: onFullscreen,
              ),
              IconButton(
                icon: IconMapper.icon('morevertical', size: 20, color: Colors.white) ??
                    const Icon(Icons.more_vert, size: 20, color: Colors.white),
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
