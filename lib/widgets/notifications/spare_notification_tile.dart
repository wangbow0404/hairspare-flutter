import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification.dart' show AppNotification;
import '../../theme/app_theme.dart';

/// 스페어 알림 목록·벨용 카드.
class SpareNotificationTile extends StatelessWidget {
  const SpareNotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDelete,
    this.compact = false,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        child: Container(
          margin: EdgeInsets.only(bottom: compact ? 0 : AppTheme.spacing3),
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: compact ? AppTheme.spacing3 : AppTheme.spacing4,
          ),
          decoration: BoxDecoration(
            color: isUnread
                ? AppTheme.backgroundWhite
                : AppTheme.backgroundWhite.withValues(alpha: 0.92),
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            border: Border.all(
              color: isUnread ? AppTheme.stitchPrimaryContainer.withValues(alpha: 0.35) : AppTheme.borderGray,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: isUnread ? AppTheme.stitchSoftShadow : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationTypeIcon(type: notification.type, isUnread: isUnread),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight:
                                      isUnread ? FontWeight.w700 : FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppTheme.spacing2),
                            decoration: const BoxDecoration(
                              color: AppTheme.stitchPrimaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (onDelete != null)
                          Padding(
                            padding: const EdgeInsets.only(left: AppTheme.spacing2),
                            child: InkWell(
                              onTap: onDelete,
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnread
                                ? AppTheme.textSecondary
                                : AppTheme.textTertiary,
                            height: 1.4,
                          ),
                      maxLines: compact ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      DateFormat('yyyy.M.d HH:mm', 'ko_KR')
                          .format(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTypeIcon extends StatelessWidget {
  const _NotificationTypeIcon({
    required this.type,
    required this.isUnread,
  });

  final String type;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color bg) = switch (type) {
      'work_proposal' => (Icons.work_outline, AppTheme.stitchPrimaryContainer),
      'application_accepted' => (Icons.check_circle_outline, AppTheme.primaryGreen),
      'application_received' => (Icons.person_add_alt_1_outlined, AppTheme.primaryPurple),
      'job_closing' => (Icons.timer_outlined, AppTheme.orange500),
      'space_booking_request' ||
      'space_booking_confirmed' =>
        (Icons.meeting_room_outlined, AppTheme.stitchPrimaryContainer),
      'schedule_reminder' || 'schedule_confirmed' => (
          Icons.calendar_today_outlined,
          AppTheme.stitchPrimaryContainer,
        ),
      'message_received' => (Icons.chat_bubble_outline, AppTheme.textSecondary),
      _ => (Icons.notifications_outlined, AppTheme.textSecondary),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (isUnread ? bg : AppTheme.borderGray).withValues(
          alpha: isUnread ? 0.12 : 0.5,
        ),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isUnread ? bg : AppTheme.textTertiary,
      ),
    );
  }
}

/// 섹션 헤더 (확인 필요 / 확인함).
class SpareNotificationSectionHeader extends StatelessWidget {
  const SpareNotificationSectionHeader({
    super.key,
    required this.label,
    this.count,
  });

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spacing2,
        bottom: AppTheme.spacing3,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: AppTheme.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.stitchPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
