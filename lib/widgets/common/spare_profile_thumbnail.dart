import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import 'app_network_image.dart';

/// 스페어 프로필 썸네일 — [JobThumbnail]과 동일 패턴.
class SpareProfileThumbnail extends StatelessWidget {
  const SpareProfileThumbnail({
    super.key,
    required this.spare,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final SpareProfile spare;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  String? get _imageUrl {
    final profile = spare.profileImage?.trim();
    if (profile != null && profile.isNotEmpty) return profile;
    final gallery = spare.images;
    if (gallery != null && gallery.isNotEmpty) {
      final first = gallery.first.trim();
      if (first.isNotEmpty) return first;
    }
    return null;
  }

  int? get _memCacheWidth {
    final w = width;
    if (w == null || !w.isFinite) return null;
    return (w * 2).round();
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: AppNetworkImage(
          imageUrl: _imageUrl,
          fit: fit,
          memCacheWidth: _memCacheWidth,
          fallbackIcon: Icons.person_outline_rounded,
        ),
      ),
    );
  }
}
