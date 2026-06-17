import 'package:flutter/material.dart';

import '../../screens/spare/energy_purchase_screen.dart';
import '../../screens/spare/points_screen.dart';
import '../../theme/app_theme.dart';

/// 에너지 부족 시 — 에너지 직접 구매 or 포인트 적립 미션 선택 바텀 시트.
void showEnergyRechargeChoiceSheet(BuildContext context, {int? needed}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EnergyRechargeChoiceSheet(needed: needed),
  );
}

class _EnergyRechargeChoiceSheet extends StatelessWidget {
  const _EnergyRechargeChoiceSheet({this.needed});

  final int? needed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0DBFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppTheme.stitchPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '에너지가 부족해요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.stitchTextPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (needed != null)
                        Text(
                          '이 공고 지원에 에너지 ${needed}개가 필요합니다.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.stitchTextSecondary,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ChoiceTile(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFCA8A04),
              iconBg: const Color(0xFFFEF9C3),
              title: '에너지 충전하기',
              subtitle: '에너지를 직접 구매합니다',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EnergyPurchaseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ChoiceTile(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF0DBFF),
              title: '포인트 받으러가기',
              subtitle: '미션을 완료하고 포인트를 받아보세요',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PointsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundGray,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.stitchTextSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
