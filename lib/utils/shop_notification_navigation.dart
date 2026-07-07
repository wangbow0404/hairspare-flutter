import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../utils/shell_navigation.dart';
import 'message_notification_navigation.dart';
import 'navigation_helper.dart';

/// 샵 알림 탭 시 목적 화면 라우팅.
abstract final class ShopNotificationNavigation {
  ShopNotificationNavigation._();

  static void handle(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case 'space_booking_request':
      case 'space_booking_confirmed':
        if (notification.relatedJobId != null) {
          ShellNavigation.pushShopSpaceBookings(
            context,
            notification.relatedJobId!,
          );
        }
        return;
      case 'application_received':
      // 구버전 알림 호환용 타입명
      case 'application':
      case 'pending_applicant':
        ShellNavigation.pushShopApplicants(context);
        return;
      case 'job_closing':
      case 'job':
      // 구버전 알림 호환용 타입명
      case 'deadline':
        if (notification.relatedJobId != null) {
          ShellNavigation.pushShopJobDetail(
            context,
            notification.relatedJobId!,
          );
        }
        return;
      case 'settlement_reminder':
        ShellNavigation.pushShopSchedule(
          context,
          focusJobId: notification.relatedJobId,
        );
        return;
      case 'message_received':
      // 구버전 알림 호환용 타입명
      case 'chat':
        MessageNotificationNavigation.open(
          context,
          notification,
          audience: 'shop',
        );
        return;
      default:
        NavigationHelper.navigateToNotificationsList(context);
        return;
    }
  }
}
