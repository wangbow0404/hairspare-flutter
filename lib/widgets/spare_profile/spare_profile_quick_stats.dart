import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/energy_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../theme/app_theme.dart';

/// 에너지 · 진행중 스케줄 · 완료 스케줄 요약.
class SpareProfileQuickStats extends StatelessWidget {
  const SpareProfileQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Consumer2<EnergyProvider, ScheduleProvider>(
        builder: (context, energyProvider, scheduleProvider, _) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      energyProvider.isLoading ? '-' : energyProvider.balance.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlueDark,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '에너지',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderGray,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      scheduleProvider.isLoading ? '-' : scheduleProvider.scheduledCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '진행중',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderGray,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      scheduleProvider.isLoading ? '-' : scheduleProvider.completedCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.green600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '완료',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
