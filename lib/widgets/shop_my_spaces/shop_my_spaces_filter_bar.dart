import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum ShopMySpacesFilter { all, visible, hidden }

class ShopMySpacesFilterBar extends StatelessWidget {
  const ShopMySpacesFilterBar({
    super.key,
    required this.selected,
    required this.totalCount,
    required this.visibleCount,
    required this.hiddenCount,
    required this.onChanged,
  });

  final ShopMySpacesFilter selected;
  final int totalCount;
  final int visibleCount;
  final int hiddenCount;
  final ValueChanged<ShopMySpacesFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing5,
        AppTheme.spacing3,
        AppTheme.spacing5,
        AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterPill(
              label: '전체 ($totalCount)',
              isSelected: selected == ShopMySpacesFilter.all,
              onTap: () => onChanged(ShopMySpacesFilter.all),
            ),
            const SizedBox(width: AppTheme.spacing2),
            _FilterPill(
              label: '노출중 ($visibleCount)',
              isSelected: selected == ShopMySpacesFilter.visible,
              onTap: () => onChanged(ShopMySpacesFilter.visible),
            ),
            const SizedBox(width: AppTheme.spacing2),
            _FilterPill(
              label: '숨김 ($hiddenCount)',
              isSelected: selected == ShopMySpacesFilter.hidden,
              onTap: () => onChanged(ShopMySpacesFilter.hidden),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
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
            color: isSelected ? AppTheme.stitchPrimary : AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: isSelected ? AppTheme.stitchPrimary : AppTheme.borderGray,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing2,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.stitchTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
