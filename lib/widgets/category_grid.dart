import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryItem {
  final String emoji;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool has3DEffect;
  final Color color;

  const CategoryItem({
    required this.emoji,
    this.icon,
    required this.label,
    this.onTap,
    this.has3DEffect = false,
    this.color = AppTheme.stitchPrimary,
  });
}

/// Stitch 스타일 4×2 카테고리 그리드 — 회색 원 + outline 아이콘.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    this.padding,
    this.wrapInCard = true,
  });

  final List<CategoryItem> categories;
  final EdgeInsetsGeometry? padding;
  final bool wrapInCard;

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 24,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _StitchCategoryItem(
          icon: category.icon,
          emoji: category.emoji,
          label: category.label,
          onTap: category.onTap,
        );
      },
    );

    if (!wrapInCard) {
      return Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
        child: grid,
      );
    }

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.stitchSoftShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: grid,
        ),
      ),
    );
  }
}

class _StitchCategoryItem extends StatefulWidget {
  const _StitchCategoryItem({
    required this.icon,
    required this.emoji,
    required this.label,
    this.onTap,
  });

  final IconData? icon;
  final String emoji;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_StitchCategoryItem> createState() => _StitchCategoryItemState();
}

class _StitchCategoryItemState extends State<_StitchCategoryItem> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _active => _hovered || _pressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) => setState(() => _hovered = hovered),
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          splashColor: AppTheme.stitchPrimary.withValues(alpha: 0.12),
          highlightColor: AppTheme.stitchPrimary.withValues(alpha: 0.08),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _active
                        ? AppTheme.primaryPurpleLight
                        : AppTheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                    boxShadow: _active
                        ? [
                            BoxShadow(
                              color: AppTheme.stitchPrimary
                                  .withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: 24,
                          color: _active
                              ? AppTheme.stitchPrimary
                              : AppTheme.stitchTextSecondary,
                        )
                      : Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.stitchTextPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
