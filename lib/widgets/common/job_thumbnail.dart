import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import 'app_network_image.dart';

/// 공고/매장 썸네일. `Job.images` 첫 장을 표시하고,
/// 이미지가 없거나 로딩 실패 시 보라 그라데이션 placeholder로 대체한다.
///
/// mock/dev 및 hot reload: [AppNetworkImage]로 picsum fetch 없이 즉시 렌더.
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

  int? get _memCacheWidth {
    final w = width;
    if (w == null || !w.isFinite) return null;
    return (w * 2).round();
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
            ? const _JobThumbnailPlaceholder()
            : AppNetworkImage(
                imageUrl: url,
                fit: fit,
                memCacheWidth: _memCacheWidth,
                fallbackIcon: Icons.storefront_outlined,
              ),
      ),
    );
  }
}

class _JobThumbnailPlaceholder extends StatelessWidget {
  const _JobThumbnailPlaceholder();

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
        child: Icon(
          Icons.storefront_outlined,
          color: AppTheme.stitchPrimary.withValues(alpha: 0.55),
          size: 28,
        ),
      ),
    );
  }
}
