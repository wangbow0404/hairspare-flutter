import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/notification.dart';
import 'app_bar_navigation.dart';
import 'messaging_navigation.dart';
import 'notification_chat_resolver.dart';

/// `message_received` 알림 탭 → 해당 채팅방(없으면 목록).
abstract final class MessageNotificationNavigation {
  MessageNotificationNavigation._();

  static void open(
    BuildContext context,
    AppNotification notification, {
    required String audience,
  }) {
    final chatId = NotificationChatResolver.resolveChatId(
      notification,
      audience: audience,
    );
    if (chatId != null) {
      MessagingNavigation.openChatForAudience(
        context,
        chatId,
        audience: audience,
      );
      return;
    }
    AppBarNavigation.pushMessages(context);
  }

  /// 알림 벨·오버레이 등 [BuildContext] 없이 라우터만 쓸 때.
  static void openFromRouter(
    AppNotification notification, {
    required String audience,
  }) {
    final chatId = NotificationChatResolver.resolveChatId(
      notification,
      audience: audience,
    );
    if (chatId != null) {
      appRouter.push(MessagingNavigation.chatRouteForAudience(audience, chatId));
      return;
    }
    switch (audience) {
      case 'model':
        appRouter.push(AppRoutes.modelMessages);
      case 'shop':
        appRouter.push(AppRoutes.shopMessages);
      default:
        appRouter.push(AppRoutes.spareMessages);
    }
  }
}
