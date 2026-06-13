import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/challenge_view_model.dart';

/// 좌하단 음악 정보 칩.
class ChallengeMusicPill extends StatelessWidget {
  const ChallengeMusicPill({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final c = vm.displayedChallenges[vm.currentIndex];
    if (c.musicName == null && c.musicArtist == null) {
      return const SizedBox.shrink();
    }

    final label = c.musicName != null && c.musicArtist != null
        ? '${c.musicName} - ${c.musicArtist}'
        : c.musicName ?? c.musicArtist ?? '';

    return Positioned(
      left: AppTheme.spacing4,
      bottom: AppTheme.spacing2,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing2,
          vertical: AppTheme.spacing1,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconMapper.icon('music', size: 16, color: Colors.white) ??
                const Icon(Icons.music_note, size: 16, color: Colors.white),
            const SizedBox(width: AppTheme.spacing1),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
