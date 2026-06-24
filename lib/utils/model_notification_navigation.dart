import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/notification.dart';
import 'message_notification_navigation.dart';

/// 모델 알림 탭 → 매칭·스케줄·메시지 등 모델 전용 화면.
abstract final class ModelNotificationNavigation {
  static void handle(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case 'model_interest':
        appRouter.push(AppRoutes.modelMatching);
      case 'schedule_reminder':
      case 'deposit_payment':
        appRouter.go(AppRoutes.modelSchedule);
      case 'message_received':
        MessageNotificationNavigation.open(
          context,
          notification,
          audience: 'model',
        );
      default:
        appRouter.push(AppRoutes.modelNotifications);
    }
  }
}
