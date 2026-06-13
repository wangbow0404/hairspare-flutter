import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../screens/shop/applicants_screen.dart';
import '../screens/shop/job_detail_screen.dart';
import '../screens/shop/space_bookings_screen.dart';
import 'navigation_helper.dart';

/// 샵 알림 탭 시 목적 화면 라우팅.
abstract final class ShopNotificationNavigation {
  ShopNotificationNavigation._();

  static void handle(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case 'space_booking_request':
      case 'space_booking_confirmed':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ShopSpaceBookingsScreen(
              spaceId: notification.relatedJobId,
            ),
          ),
        );
        return;
      case 'application_received':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const ShopApplicantsScreen(),
          ),
        );
        return;
      case 'job_closing':
      case 'job':
        if (notification.relatedJobId != null) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ShopJobDetailScreen(
                jobId: notification.relatedJobId!,
              ),
            ),
          );
        }
        return;
      case 'message_received':
        NavigationHelper.navigateToMessages(context);
        return;
      default:
        return;
    }
  }
}
