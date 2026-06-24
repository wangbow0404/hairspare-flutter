import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../models/match_like.dart';

/// 매칭 프로필 상세 — go_router 중첩 라우트.
Future<bool?> openMatchProfile(
  BuildContext context, {
  required String likeId,
  MatchLike? initialLike,
}) {
  return context.push<bool>(
    _routeForContext(context, likeId),
    extra: initialLike,
  );
}

String _routeForContext(BuildContext context, String likeId) {
  final path = GoRouterState.of(context).uri.path;
  if (path.startsWith('/model/matching')) {
    return AppRoutes.modelMatchingMatchLike(likeId);
  }
  return AppRoutes.modelHomeMatchLike(likeId);
}
