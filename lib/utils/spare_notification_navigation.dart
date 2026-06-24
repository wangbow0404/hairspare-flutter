import 'package:flutter/material.dart';

import '../models/notification.dart';
import 'message_notification_navigation.dart';
import 'navigation_helper.dart';

/// 스페어 알림 탭 시 목적 화면 라우팅 (벨·알림 목록 공통).
abstract final class SpareNotificationNavigation {
  SpareNotificationNavigation._();

  static void handle(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case 'work_proposal':
        NavigationHelper.navigateToWorkCheck(
          context,
          initialDay: _parseScheduleDay(notification),
          jobId: notification.relatedJobId,
          scheduleId: notification.relatedScheduleId,
          openProposalDetail: true,
        );
        return;
      case 'application_accepted':
      case 'schedule_reminder':
      case 'schedule_confirmed':
      case 'schedule_cancelled':
        NavigationHelper.navigateToWorkCheck(
          context,
          initialDay: _parseScheduleDay(notification),
          jobId: notification.relatedJobId,
          scheduleId: notification.relatedScheduleId,
        );
        return;
      case 'application_received':
      case 'application_rejected':
      case 'job_posted':
      case 'job':
      case 'job_closing':
        if (notification.relatedJobId != null) {
          NavigationHelper.navigateToJobDetail(
            context,
            notification.relatedJobId!,
          );
        }
        return;
      case 'message_received':
        MessageNotificationNavigation.open(
          context,
          notification,
          audience: 'spare',
        );
        return;
      default:
        return;
    }
  }

  static DateTime? _parseScheduleDay(AppNotification notification) {
    final raw = notification.scheduleDate?.trim();
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
