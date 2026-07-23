import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../design_system/hs_filter_chip.dart';

/// 홈 공고 필터 칩 — 전체/급구/당일정산/초보가능.
class SpareHomeFilterChips extends StatelessWidget {
  const SpareHomeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const filters = <String, String>{
    'all': '전체',
    'urgent': '급구',
    'same_day': '당일정산',
    'beginner': '초보가능',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacing2),
        itemBuilder: (context, index) {
          final key = filters.keys.elementAt(index);
          final label = filters[key]!;
          return HsFilterChip(
            label: label,
            isSelected: selected == key,
            urgent: key == 'urgent' && selected == key,
            onTap: () => onSelected(key),
          );
        },
      ),
    );
  }
}
