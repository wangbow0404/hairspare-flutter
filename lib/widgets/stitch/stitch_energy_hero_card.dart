import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 에너지/결제 화면 상단 잔액 히어로 카드.
class StitchEnergyHeroCard extends StatelessWidget {
  const StitchEnergyHeroCard({
    super.key,
    required this.balance,
    required this.onPurchase,
    this.actionLabel = '에너지 구매하기',
  });

  final int balance;
  final VoidCallback onPurchase;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing6),
      decoration: BoxDecoration(
        gradient: AppTheme.stitchHeroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: IconMapper.icon('zap', size: 24, color: Colors.white) ??
                    const Icon(Icons.flash_on, size: 24, color: Colors.white),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 에너지',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    '$balance개',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.stitchPrimary,
                padding: AppTheme.spacing(AppTheme.spacing3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
