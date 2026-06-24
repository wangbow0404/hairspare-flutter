import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

/// 채팅·알림 mock/API 조회 시 역할 구분 (`spare` | `shop` | `model`).
abstract final class MessagingAudience {
  static String resolve(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final path = _currentPath(context);

    if (user?.role == UserRole.shop || path.startsWith('/shop')) {
      return 'shop';
    }
    if (user?.isModelAccount == true || path.startsWith('/model')) {
      return 'model';
    }
    return 'spare';
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
}
