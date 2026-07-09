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

  /// GoRouterState.of(context)는 InheritedWidget 구독을 만들어서, 라우팅
  /// 이벤트가 있을 때마다 이 위젯(앱 전역에서 쓰이는 SpareSubpageAppBar)이
  /// 전부 다시 빌드되는 원인이 된다. 여기선 현재 role 라벨만 필요하고 매
  /// 리빌드마다 최신일 필요는 없으므로, 구독 없이 값만 읽는
  /// appRouter.state를 우선 사용한다.
  static String _currentPath(BuildContext context) {
    try {
      return appRouter.state.uri.path;
    } catch (_) {
      try {
        return GoRouterState.of(context).uri.path;
      } catch (_) {
        return '';
      }
    }
  }
}
