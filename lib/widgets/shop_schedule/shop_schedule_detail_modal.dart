import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/schedule_work_session.dart';

/// 샵 스케줄 상세 오버레이 (정산 가능 조건·24시간 안내·정산/취소).
/// 기획 연결 시 Stack 등에 `ShopScheduleDetailModal(...)` 로 배치.
class ShopScheduleDetailModal extends StatelessWidget {
  const ShopScheduleDetailModal({
    super.key,
    required this.schedule,
    required this.onClose,
    required this.onConfirmWork,
    required this.onCancelSchedule,
  });

  final Schedule schedule;
  final VoidCallback onClose;
  final ValueChanged<String> onConfirmWork;
  final ValueChanged<String> onCancelSchedule;

  @override
  Widget build(BuildContext context) {
    final scheduleDate = DateTime.parse(schedule.date);
    final settlementBlocked =
        ScheduleWorkSession.settlementBlockedMessage(schedule);
    final canConfirm = ScheduleWorkSession.canSettle(schedule);

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 448),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderGray),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '스케줄 상세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        IconButton(
                          icon: IconMapper.icon('x', size: 24, color: AppTheme.textTertiary) ??
                              const Icon(Icons.close, color: AppTheme.textTertiary),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            schedule.job?.title ?? '공고 제목 없음',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          Text(
                            schedule.spare?.name ?? schedule.spareId,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          _infoRow(
                            context,
                            IconMapper.icon('calendar', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.calendar_today, size: 20, color: AppTheme.textTertiary),
                            DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(scheduleDate),
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          _infoRow(
                            context,
                            IconMapper.icon('clock', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.access_time, size: 20, color: AppTheme.textTertiary),
                            '${schedule.startTime}${schedule.endTime != null ? ' ~ ${schedule.endTime}' : ''}',
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          _infoRow(
                            context,
                            IconMapper.icon('dollarsign', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.attach_money, size: 20, color: AppTheme.textTertiary),
                            '${NumberFormat('#,###').format(schedule.job?.amount ?? 0)}원',
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          _infoRow(
                            context,
                            IconMapper.icon('users', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.people, size: 20, color: AppTheme.textTertiary),
                            '필요 인원: ${schedule.job?.requiredCount ?? 0}명',
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          if (canConfirm) ...[
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacing3),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: AppTheme.spacing2),
                                  Expanded(
                                    child: Text(
                                      '24시간 내에 정산 또는 취소를 하지 않으면 스페어에게 자동으로 정산됩니다.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  onConfirmWork(schedule.id);
                                  onClose();
                                },
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text('정산하기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacing3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  onCancelSchedule(schedule.id);
                                  onClose();
                                },
                                icon: const Icon(Icons.cancel_outlined, size: 20),
                                label: const Text('취소하기'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.urgentRed,
                                  side: const BorderSide(color: AppTheme.urgentRed),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacing3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (!canConfirm && settlementBlocked != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppTheme.spacing2),
                              child: Text(
                                settlementBlocked,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.orange600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _infoRow(BuildContext context, Widget icon, String text) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppTheme.spacing2),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppTheme.textGray700,
                ),
          ),
        ),
      ],
    );
  }
}
