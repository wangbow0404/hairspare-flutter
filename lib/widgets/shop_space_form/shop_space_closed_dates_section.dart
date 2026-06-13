import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_date_picker.dart';
import '../../view_models/shop_space_form_view_model.dart';
import '../shop_job_new/shop_job_new_form_content.dart';
import '../shop_job_new/shop_job_new_ui_kit.dart';

/// 휴무일 선택 (날짜별 예약 불가).
class ShopSpaceClosedDatesSection extends StatelessWidget {
  const ShopSpaceClosedDatesSection({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopSpaceFormViewModel>();
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: ShopJobNewFieldLabel(label: '휴무일'),
              ),
              TextButton.icon(
                onPressed: () => _pickDate(context, vm),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          if (vm.closedDates.isEmpty)
            const Text(
              '특정 날짜에 예약을 받지 않으려면 휴무일을 추가하세요.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          else
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: vm.closedDates.map((date) {
                final label = DateFormat('M월 d일 (E)', 'ko').format(date);
                return InputChip(
                  label: Text(label),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => vm.removeClosedDate(date),
                  backgroundColor: AppTheme.backgroundGray,
                  side: const BorderSide(color: AppTheme.borderGray),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, ShopSpaceFormViewModel vm) async {
    final picked = await shopJobNewRunPicker<DateTime?>(
      scrollController,
      () => showAppDatePicker(
        context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );
    if (picked == null) return;
    vm.addClosedDate(picked);
  }
}
