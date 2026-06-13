import 'package:flutter/material.dart';

import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/count_format.dart';
import 'package:hairspare/widgets/challenge/profile/challenge_profile_video_thumb.dart';

/// 인기 영상 가로 스크롤.
class ChallengeProfileFeaturedVideosRow extends StatelessWidget {
  const ChallengeProfileFeaturedVideosRow({
    super.key,
    required this.videos,
    required this.isLoading,
    required this.onVideoTap,
    this.onSeeAllTap,
  });

  final List<MyChallenge> videos;
  final bool isLoading;
  final void Function(MyChallenge video) onVideoTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacing4,
        right: AppTheme.spacing4,
        bottom: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '인기 영상',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (onSeeAllTap != null && videos.isNotEmpty)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('전체 보기'),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          if (isLoading)
            const SizedBox(
              height: 168,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (videos.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              child: const Text(
                '아직 공개된 영상이 없습니다',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return ChallengeProfileVideoThumb(
                    width: 112,
                    video: video,
                    onTap: () => onVideoTap(video),
                    footer: CountFormat.compact(video.likes),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
