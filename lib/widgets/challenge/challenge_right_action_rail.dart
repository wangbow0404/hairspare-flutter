import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/challenge_view_model.dart';

/// 오른쪽 세로 액션: (몰입형) 프로필·좋아요·댓글·공유·리믹스 — 흰색 라인 아이콘.
class ChallengeRightActionRail extends StatelessWidget {
  const ChallengeRightActionRail({
    super.key,
    required this.onOpenCreatorProfile,
    this.immersive = false,
  });

  final void Function(String? creatorId) onOpenCreatorProfile;
  final bool immersive;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final c = vm.displayedChallenges[vm.currentIndex];

    if (immersive) {
      final bottomPad = MediaQuery.paddingOf(context).bottom;
      return Positioned(
        right: 10,
        bottom: bottomPad + 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ImmersiveAction(
              icon: c.isLiked ? Icons.favorite : Icons.favorite_border,
              filled: c.isLiked,
              caption: ChallengeViewModel.formatCount(c.likes),
              onTap: () => context.read<ChallengeViewModel>().toggleLike(),
            ),
            const SizedBox(height: 14),
            _ImmersiveAction(
              icon: Icons.chat_bubble_outline,
              caption: ChallengeViewModel.formatCount(c.comments),
              onTap: () =>
                  context.read<ChallengeViewModel>().handleCommentOpen(),
            ),
            const SizedBox(height: 14),
            _ImmersiveAction(
              icon: Icons.share_outlined,
              caption: ChallengeViewModel.formatCount(c.shares),
              onTap: () => context.read<ChallengeViewModel>().handleShare(),
            ),
            const SizedBox(height: 14),
            _ImmersiveAction(
              icon: Icons.autorenew,
              caption: '리믹스',
              onTap: () => context.read<ChallengeViewModel>().handleRemix(),
            ),
            const SizedBox(height: 16),
            _ImmersiveAvatar(
              onTap: () => onOpenCreatorProfile(c.creatorId),
              emoji: c.creatorAvatar,
            ),
          ],
        ),
      );
    }

    return Positioned(
      right: AppTheme.spacing4,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleActionColumn(
            caption: ChallengeViewModel.formatCount(c.likes),
            child: GestureDetector(
              onTap: () => context.read<ChallengeViewModel>().toggleLike(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  c.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: c.isLiked ? AppTheme.urgentRed : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          _CircleActionColumn(
            caption: '싫어요',
            child: GestureDetector(
              onTap: () => context.read<ChallengeViewModel>().handleDislike(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.isDisliked
                      ? Colors.blue[300]!.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  c.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  size: 20,
                  color: c.isDisliked ? Colors.blue[300]! : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          _CircleActionColumn(
            caption: ChallengeViewModel.formatCount(c.comments),
            child: GestureDetector(
              onTap: () =>
                  context.read<ChallengeViewModel>().handleCommentOpen(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    IconMapper.icon(
                      'messagecircle',
                      size: 20,
                      color: Colors.white,
                    ) ??
                    const Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          _CircleActionColumn(
            caption: '공유',
            child: GestureDetector(
              onTap: () => context.read<ChallengeViewModel>().handleShare(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    IconMapper.icon('share2', size: 20, color: Colors.white) ??
                    const Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          _CircleActionColumn(
            caption: '리믹스',
            child: GestureDetector(
              onTap: () => context.read<ChallengeViewModel>().handleRemix(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    IconMapper.icon(
                      'rotateccw',
                      size: 20,
                      color: Colors.white,
                    ) ??
                    const Icon(
                      Icons.replay_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          GestureDetector(
            onTap: () => onOpenCreatorProfile(c.creatorId),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  c.creatorAvatar ?? '👤',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImmersiveAvatar extends StatelessWidget {
  const _ImmersiveAvatar({required this.onTap, required this.emoji});

  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.85),
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            color: Colors.black26,
          ),
          child: Center(
            child: Text(emoji ?? '👤', style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}

class _ImmersiveAction extends StatelessWidget {
  const _ImmersiveAction({
    required this.icon,
    required this.caption,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String caption;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    const textShadow = <Shadow>[
      Shadow(color: Color(0xB3000000), blurRadius: 6, offset: Offset(0, 1.2)),
    ];
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: filled ? const Color(0xFFFF4D6A) : Colors.white,
            shadows: textShadow,
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.1,
              shadows: textShadow,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionColumn extends StatelessWidget {
  const _CircleActionColumn({required this.child, required this.caption});

  final Widget child;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          caption,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
