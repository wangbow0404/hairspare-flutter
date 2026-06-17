import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/energy_purchase_pricing.dart';

/// 에너지 구매·결제 화면 — 가격 미확정(TBD) 예시 안내 배너.
class EnergyPurchaseProvisionalNotice extends StatelessWidget {
  const EnergyPurchaseProvisionalNotice({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kEnergyPurchasePricingIsProvisional) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.orange50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.orange100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.orange100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '예시',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.orange600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kEnergyPurchaseProvisionalNotice,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.orange600,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
