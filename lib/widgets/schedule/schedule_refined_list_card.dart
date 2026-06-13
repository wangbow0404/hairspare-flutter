import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../utils/schedule_work_session.dart';
import 'schedule_list_card_shell.dart';
import 'schedule_pastel_status_chip.dart';
import 'schedule_status_chip_theme.dart';
import 'schedule_work_check_cta_button.dart';

/// 스케줄표 — 단일 공고 카드.
class ScheduleRefinedListCard extends StatelessWidget {
  const ScheduleRefinedListCard({
    super.key,
    required this.schedule,
    required this.statusLabel,
    required this.workCheckReady,
    required this.onCardTap,
    required this.onWorkCheckTap,
    this.showWorkCheckButton = true,
  });

  final Schedule schedule;
  final String statusLabel;
  final bool workCheckReady;
  final VoidCallback onCardTap;
  final VoidCallback onWorkCheckTap;
  final bool showWorkCheckButton;

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg, chipBorder) =
        ScheduleStatusChipTheme.forLabel(statusLabel);
    final title = schedule.job?.title ?? '공고 제목 없음';
    final shop = schedule.job?.shopName ?? '매장명 없음';
    final amount = NumberFormat('#,###').format(schedule.job?.amount ?? 0);
    final timeLine = schedule.endTime != null && schedule.endTime!.isNotEmpty
        ? '${schedule.startTime} ~ ${schedule.endTime}'
        : '${schedule.startTime} ~ ${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(schedule))}';

    return ScheduleListCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCardTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.28,
                                letterSpacing: -0.2,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SchedulePastelStatusChip(
                        label: statusLabel,
                        background: chipBg,
                        foreground: chipFg,
                        borderColor: chipBorder,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    shop,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timeLine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textTertiary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '금액 $amount원',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (showWorkCheckButton) ...[
              const SizedBox(height: 12),
              ScheduleWorkCheckCtaButton(
                onPressed: onWorkCheckTap,
                variant: workCheckReady
                    ? ScheduleWorkCheckCtaVariant.ready
                    : ScheduleWorkCheckCtaVariant.waiting,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
