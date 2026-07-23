import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../design_system/hs_primary_button.dart';
import '../../utils/schedule_cancel_flow.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';

/// 근무체크 / 시술 완료 하단 액션 바.
class WorkCheckActionBar extends StatelessWidget {
  const WorkCheckActionBar({super.key, required this.isModelMode});

  final bool isModelMode;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkCheckViewModel>(
      builder: (context, vm, _) {
        final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
        if (!vm.hasScheduledWork(vm.selectedDate)) {
          return const SizedBox.shrink();
        }

        final dateKey = DateFormat('yyyy-MM-dd').format(vm.selectedDate);
        final pendingShop = vm.pendingApprovals[dateKey];
        final isPending = pendingShop != null;
        final canCheckIn = vm.selectedScheduleId != null &&
            !vm.isChecked(vm.selectedDate) &&
            !isPending;

        return Container(
          width: double.infinity,
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
            border: Border(
              top: BorderSide(color: AppTheme.borderGray, width: 1),
            ),
          ),
          child: Column(
            children: [
              if (isPending)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow50,
                    border: Border.all(color: AppTheme.yellow600, width: 1),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: Text(
                    audience.pendingProcessingMessage(pendingShop),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.yellow800,
                        ),
                  ),
                ),
              HsPrimaryButton(
                label: audience.completeButtonLabel,
                onPressed: canCheckIn ? vm.handleCheckIn : null,
              ),
              if (vm.selectedScheduleId != null &&
                  !vm.isChecked(vm.selectedDate))
                Builder(
                  builder: (ctx) {
                    final selected = vm.schedules.where(
                      (s) => s.id == vm.selectedScheduleId,
                    );
                    if (selected.isEmpty ||
                        selected.first.status != 'scheduled') {
                      return const SizedBox.shrink();
                    }
                    final schedule = selected.first;
                    return Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spacing3),
                      child: TextButton(
                        onPressed: () async {
                          await ScheduleCancelFlow.requestCancel(
                            context: ctx,
                            schedule: schedule,
                            actor: CancellationActor.spare,
                            isModelMode: isModelMode,
                            onSuccess: () => vm.loadData(),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.urgentRed,
                        ),
                        child: Text(
                          audience.cancelButtonLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
