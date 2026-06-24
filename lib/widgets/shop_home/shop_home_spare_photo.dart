import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../common/app_network_image.dart';

/// 샵 홈 스페어 카드용 프로필 사진 — cover / thumbnail 공용.
class ShopHomeSparePhoto extends StatelessWidget {
  const ShopHomeSparePhoto({
    super.key,
    required this.spare,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
  });

  final SpareProfile spare;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  String? get _imageUrl {
    if (spare.profileImage != null && spare.profileImage!.isNotEmpty) {
      return spare.profileImage;
    }
    final gallery = spare.images;
    if (gallery != null && gallery.isNotEmpty) return gallery.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: AppNetworkImage(
          imageUrl: url,
          fit: fit,
          memCacheWidth: ((width ?? 288) * 2).round(),
          fallbackIcon: Icons.person_outline_rounded,
        ),
      ),
    );
  }
}
