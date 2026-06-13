import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

/// 상단바 검색·채팅·알림이 [go_router]로 스페어/샵에 맞는 화면으로 이동하도록 공통 처리합니다.
///
/// 라우팅은 [appRouter] ([registerGoRouter] 등록 인스턴스)를 사용합니다.
abstract final class AppBarNavigation {
  /// 로그인 사용자 역할 우선, 없으면 현재 경로(`/shop` vs `/spare`)로 구간 판별.
  static UserRole inferAppSectionRole(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      if (user.role == UserRole.shop) return UserRole.shop;
      if (user.role == UserRole.spare) return UserRole.spare;
    }
    final path = _currentPath(context);
    if (path.startsWith('/shop')) return UserRole.shop;
    return UserRole.spare;
  }

  static String _currentPath(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      return appRouter.state.uri.path;
    }
  }

  static bool _isShop(BuildContext context) =>
      inferAppSectionRole(context) == UserRole.shop;

  static void pushSearch(BuildContext context) {
    if (_isShop(context)) {
      appRouter.push(AppRoutes.shopSearch);
    } else {
      appRouter.push(AppRoutes.spareSearch);
    }
  }

  static void pushMessages(BuildContext context) {
    if (_isShop(context)) {
      appRouter.push(AppRoutes.shopMessages);
    } else {
      appRouter.push(AppRoutes.spareMessages);
    }
  }

  static void pushNotificationsList(BuildContext context) {
    if (_isShop(context)) {
      appRouter.push(AppRoutes.shopNotifications);
    } else {
      appRouter.push(AppRoutes.spareNotifications);
    }
  }
}
