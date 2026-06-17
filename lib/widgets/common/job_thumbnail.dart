import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';

/// 공고/매장 썸네일. `Job.images` 첫 장을 표시하고,
/// 이미지가 없거나 로딩 실패 시 보라 그라데이션 placeholder로 대체한다.
class JobThumbnail extends StatelessWidget {
  const JobThumbnail({
    super.key,
    required this.job,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final Job job;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  String? get _imageUrl {
    final images = job.images;
    if (images == null || images.isEmpty) return null;
    final first = images.first.trim();
    return first.isEmpty ? null : first;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);
    final url = _imageUrl;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? const _ThumbnailPlaceholder()
            : Image.network(
                url,
                fit: fit,
                width: width,
                height: height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const _ThumbnailPlaceholder(showSpinner: true);
                },
                errorBuilder: (context, error, stackTrace) =>
                    const _ThumbnailPlaceholder(),
              ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.stitchPrimaryContainer.withValues(alpha: 0.18),
            AppTheme.stitchPrimary.withValues(alpha: 0.30),
          ],
        ),
      ),
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.stitchPrimary,
                ),
              )
            : Icon(
                Icons.storefront_outlined,
                color: AppTheme.stitchPrimary.withValues(alpha: 0.55),
                size: 28,
              ),
      ),
    );
  }
}
