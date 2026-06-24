import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../utils/shell_navigation.dart';
import 'message_notification_navigation.dart';

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
        ShellNavigation.pushShopApplicants(context);
        return;
      case 'job_closing':
      case 'job':
        if (notification.relatedJobId != null) {
          ShellNavigation.pushShopJobDetail(
            context,
            notification.relatedJobId!,
          );
        }
        return;
      case 'message_received':
        MessageNotificationNavigation.open(
          context,
          notification,
          audience: 'shop',
        );
        return;
      default:
        return;
    }
  }
}
