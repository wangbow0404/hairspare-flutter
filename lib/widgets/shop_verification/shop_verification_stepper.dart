import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';

/// 사업자 → 본인 → 대리인 3단계 진행 표시.
class ShopVerificationStepper extends StatelessWidget {
  const ShopVerificationStepper({super.key, required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(
        label: '사업자',
        done: vm.businessPhase == ShopBusinessVerificationUiPhase.approved ||
            vm.businessPhase == ShopBusinessVerificationUiPhase.pending,
        active: vm.businessPhase == ShopBusinessVerificationUiPhase.notStarted ||
            vm.businessPhase == ShopBusinessVerificationUiPhase.rejected,
      ),
      _StepData(
        label: '본인',
        done: vm.identityVerified,
        active: !vm.identityVerified &&
            (vm.businessPhase == ShopBusinessVerificationUiPhase.approved ||
                vm.businessPhase == ShopBusinessVerificationUiPhase.pending),
      ),
      _StepData(
        label: '대리인',
        done: vm.proxyStatus == 'approved',
        active: vm.identityVerified && vm.proxyStatus != 'approved',
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: steps[i - 1].done
                    ? AppTheme.primaryBlue
                    : AppTheme.borderGray,
              ),
            ),
          _StepDot(step: steps[i], index: i + 1),
        ],
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step, required this.index});

  final _StepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = step.done
        ? AppTheme.primaryGreen
        : step.active
            ? AppTheme.primaryBlue
            : AppTheme.borderGray300;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: step.done || step.active
                ? color.withValues(alpha: 0.12)
                : AppTheme.backgroundGray,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: step.done
                ? Icon(Icons.check, size: 14, color: color)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: step.active ? FontWeight.w700 : FontWeight.w500,
            color: step.active ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
