import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../view_models/shop_space_form_view_model.dart';
import '../shop_job_new/shop_job_new_ui_kit.dart';

/// 최소 이용 시간 (1–8시간).
class ShopSpaceMinHoursField extends StatelessWidget {
  const ShopSpaceMinHoursField({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopSpaceFormViewModel>();
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShopJobNewFieldLabel(label: '최소 이용 시간', isRequired: true),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: List.generate(8, (i) {
              final hours = i + 1;
              final selected = vm.minHours == hours;
              return ChoiceChip(
                label: Text('$hours시간'),
                selected: selected,
                onSelected: (_) => vm.setMinHours(hours),
                selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
                side: BorderSide(
                  color: selected ? AppTheme.primaryBlue : AppTheme.borderGray,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
