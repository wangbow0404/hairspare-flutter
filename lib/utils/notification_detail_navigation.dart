import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../screens/common/notification_detail_screen.dart';

/// 알림 본문 전체를 보여주는 상세 화면으로 이동.
abstract final class NotificationDetailNavigation {
  NotificationDetailNavigation._();

  static Future<void> open(
    BuildContext context,
    AppNotification notification,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NotificationDetailScreen(notification: notification),
      ),
    );
  }
}
