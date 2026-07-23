import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// a안 풀-width 검색바 (탭 시 검색 화면으로 이동).
class HsSearchBar extends StatelessWidget {
  const HsSearchBar({
    super.key,
    required this.hintText,
    required this.onTap,
  });

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Ink(
          decoration: BoxDecoration(
            color: HairSpareColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: HairSpareColors.border),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: HairSpareColors.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: HairSpareColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
