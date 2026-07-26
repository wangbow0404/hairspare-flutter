import 'package:flutter/material.dart';

import '../../models/store_product.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 카테고리 선택 bottom sheet.
class StoreCategorySheet {
  static Future<StoreProductCategory?> show(
    BuildContext context, {
    StoreProductCategory? selected,
  }) {
    return showModalBottomSheet<StoreProductCategory?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.72;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: HairSpareColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppTheme.spacing3),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HairSpareColors.borderStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.spacing5,
                        AppTheme.spacing4,
                        AppTheme.spacing5,
                        AppTheme.spacing2,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '카테고리',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: HairSpareColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacing5,
                          0,
                          AppTheme.spacing5,
                          AppTheme.spacing4,
                        ),
                        children: [
                          _CategoryTile(
                            label: '전체',
                            selected: selected == null,
                            onTap: () => Navigator.of(ctx).pop(null),
                          ),
                          for (final category in StoreProductCategory.values)
                            _CategoryTile(
                              label: category.label,
                              selected: selected == category,
                              onTap: () => Navigator.of(ctx).pop(category),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? HairSpareColors.brandPrimary
              : HairSpareColors.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: HairSpareColors.brandPrimary)
          : null,
      onTap: onTap,
    );
  }
}
