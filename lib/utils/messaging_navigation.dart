import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';

/// 메시지 목록 → 채팅방 이동 (현재 셸·탭 경로에 맞는 go_router 하위 경로).
abstract final class MessagingNavigation {
  static String chatRouteForContext(BuildContext context, String chatId) {
    final path = _currentPath(context);
    if (path.startsWith('/model/')) {
      return AppRoutes.modelMessageChat(chatId);
    }
    if (path.startsWith('/shop/')) {
      return AppRoutes.shopMessageChat(chatId);
    }
    if (path.startsWith('/spare/payment')) {
      return AppRoutes.sparePaymentChat(chatId);
    }
    return AppRoutes.spareMessageChat(chatId);
  }

  static String _currentPath(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        return appRouter.state.uri.path;
      } catch (_) {
        return '';
      }
    }
  }

  /// 역할·경로에 맞는 채팅방으로 이동 (알림 등 컨텍스트가 다른 탭일 때).
  static String chatRouteForAudience(String audience, String chatId) {
    return switch (audience) {
      'model' => AppRoutes.modelMessageChat(chatId),
      'shop' => AppRoutes.shopMessageChat(chatId),
      _ => AppRoutes.spareMessageChat(chatId),
    };
  }

  static void openChat(BuildContext context, String chatId) {
    context.push(chatRouteForContext(context, chatId));
  }

  static void openChatForAudience(
    BuildContext context,
    String chatId, {
    required String audience,
  }) {
    context.push(chatRouteForAudience(audience, chatId));
  }
}
