import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/notification.dart';
import 'message_notification_navigation.dart';
import 'notification_detail_navigation.dart';

/// 모델 알림 탭 → 매칭·스케줄·메시지 등 모델 전용 화면.
abstract final class ModelNotificationNavigation {
  static void handle(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case 'model_interest':
        appRouter.push(AppRoutes.modelMatching);
        return;
      case 'schedule_reminder':
      case 'check_in_reminder':
        appRouter.go(AppRoutes.modelSchedule);
        return;
      case 'deposit_payment':
        appRouter.go(AppRoutes.modelSchedule);
        return;
      case 'message_received':
      case 'chat':
        MessageNotificationNavigation.open(
          context,
          notification,
          audience: 'model',
        );
        return;
      case 'admin_message':
        NotificationDetailNavigation.open(context, notification);
        return;
      default:
        appRouter.push(AppRoutes.modelNotifications);
        return;
    }
  }
}
