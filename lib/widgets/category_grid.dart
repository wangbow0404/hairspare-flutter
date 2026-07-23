import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/hairspare_colors.dart';

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
    this.color = HairSpareColors.brandPrimary,
  });
}

/// a안 카테고리 그리드 — 회색 원 + outline 아이콘.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    this.padding,
    this.wrapInCard = true,
    this.crossAxisCount = 4,
  });

  final List<CategoryItem> categories;
  final EdgeInsetsGeometry? padding;
  final bool wrapInCard;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        mainAxisExtent: 70,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryItemTile(
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
          color: HairSpareColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: HairSpareColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: grid,
        ),
      ),
    );
  }
}

class _CategoryItemTile extends StatefulWidget {
  const _CategoryItemTile({
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
  State<_CategoryItemTile> createState() => _CategoryItemTileState();
}

class _CategoryItemTileState extends State<_CategoryItemTile> {
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
          splashColor: HairSpareColors.brandPrimary.withValues(alpha: 0.12),
          highlightColor: HairSpareColors.brandPrimary.withValues(alpha: 0.08),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _active
                        ? HairSpareColors.brandPrimarySoft
                        : HairSpareColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: 20,
                          color: _active
                              ? HairSpareColors.brandPrimary
                              : HairSpareColors.textSecondary,
                        )
                      : Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: HairSpareColors.textPrimary,
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
