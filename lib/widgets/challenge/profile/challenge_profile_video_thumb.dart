import 'package:flutter/material.dart';

import 'package:hairspare/models/challenge_profile.dart';

/// 프로필용 영상 썸네일 타일.
class ChallengeProfileVideoThumb extends StatelessWidget {
  const ChallengeProfileVideoThumb({
    super.key,
    required this.width,
    required this.video,
    required this.onTap,
    this.footer,
  });

  final double width;
  final MyChallenge video;
  final VoidCallback onTap;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Thumbnail(video: video),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
              if (footer != null)
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        footer!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video});

  final MyChallenge video;

  @override
  Widget build(BuildContext context) {
    if (video.thumbnailUrl != null) {
      return Image.network(
        video.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _Placeholder(),
      );
    }
    return const _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2937),
      child: const Icon(
        Icons.video_library,
        color: Colors.white38,
        size: 40,
      ),
    );
  }
}
