import 'package:flutter/material.dart';

import '../../theme/hairspare_colors.dart';

/// a안 공고·프로필 placeholder — 웜그레이.
class HsPlaceholderImage extends StatelessWidget {
  const HsPlaceholderImage({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image_outlined,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final IconData icon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: HairSpareColors.placeholderWarm,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 28,
        color: HairSpareColors.textSecondary.withValues(alpha: 0.6),
      ),
    );
  }
}
