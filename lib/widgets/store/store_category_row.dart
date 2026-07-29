import 'package:flutter/material.dart';

import '../../models/store_product.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// HairSpare 스토어 — 미용 카테고리 가로 스크롤.
class StoreCategoryRow extends StatelessWidget {
  const StoreCategoryRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final StoreProductCategory? selected;
  final ValueChanged<StoreProductCategory?> onSelected;

  static const _icons = <StoreProductCategory, IconData>{
    StoreProductCategory.scissors: Icons.content_cut,
    StoreProductCategory.tools: Icons.air,
    StoreProductCategory.perm: Icons.palette_outlined,
    StoreProductCategory.hairCare: Icons.water_drop_outlined,
    StoreProductCategory.supplies: Icons.inventory_2_outlined,
    StoreProductCategory.apparel: Icons.checkroom_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
        children: [
          _CategoryTile(
            label: '전체',
            icon: Icons.apps,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in StoreProductCategory.values)
            _CategoryTile(
              label: _shortLabel(category),
              icon: _icons[category] ?? Icons.category_outlined,
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }

  static String _shortLabel(StoreProductCategory category) {
    return switch (category) {
      StoreProductCategory.scissors => '가위',
      StoreProductCategory.tools => '드라이기',
      StoreProductCategory.perm => '펌·염색',
      StoreProductCategory.hairCare => '샴푸',
      StoreProductCategory.supplies => '소모품',
      StoreProductCategory.apparel => '가운',
    };
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? HairSpareColors.activeStructural
                      : HairSpareColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? Colors.white
                      : HairSpareColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? HairSpareColors.textPrimary
                      : HairSpareColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
