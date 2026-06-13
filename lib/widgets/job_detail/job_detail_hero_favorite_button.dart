import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 공고 상세 히어로 이미지 우측 상단 찜 버튼.
class JobDetailHeroFavoriteButton extends StatelessWidget {
  const JobDetailHeroFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.isLoading = false,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: isFavorite
                        ? AppTheme.urgentRed
                        : AppTheme.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}
