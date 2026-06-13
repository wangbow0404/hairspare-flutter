import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import 'app_routes.dart';

/// 전역 인증·역할 기반 리다이렉트 (`GoRouter.redirect`).
String? authRedirect(AuthProvider auth, GoRouterState state) {
  final path = state.uri.path;

  if (path == '/spare' || path == '/shop') {
    return null;
  }

  final user = auth.currentUser;
  final loggedIn = auth.isAuthenticated && user != null;

  const spareAuthPaths = <String>{
    AppRoutes.spareLogin,
    AppRoutes.spareSignup,
    AppRoutes.spareFindId,
    AppRoutes.spareFindPassword,
  };
  const shopAuthPaths = <String>{
    AppRoutes.shopLogin,
    AppRoutes.shopSignup,
    AppRoutes.shopFindPassword,
  };

  if (loggedIn) {
    if (path == AppRoutes.roleSelect) {
      if (user.role == UserRole.spare) return AppRoutes.spareHome;
      if (user.role == UserRole.shop) return AppRoutes.shopHome;
      if (user.role == UserRole.admin) return AppRoutes.admin;
    }
    if (spareAuthPaths.contains(path)) {
      if (user.role == UserRole.admin) return AppRoutes.admin;
      if (user.role == UserRole.spare) return AppRoutes.spareHome;
      return AppRoutes.shopHome;
    }
    if (shopAuthPaths.contains(path)) {
      if (user.role == UserRole.admin) return AppRoutes.admin;
      if (user.role == UserRole.shop) return AppRoutes.shopHome;
      return AppRoutes.spareHome;
    }
  }

  if (path.startsWith('/admin')) {
    if (!loggedIn) return AppRoutes.spareLogin;
    if (user.role != UserRole.admin) {
      if (user.role == UserRole.spare) return AppRoutes.spareHome;
      return AppRoutes.shopHome;
    }
    return null;
  }

  if (path.startsWith('/spare')) {
    final isPublic = spareAuthPaths.contains(path);
    if (!loggedIn && !isPublic) {
      return AppRoutes.spareLogin;
    }
    if (loggedIn) {
      if (user.role == UserRole.admin && !isPublic) {
        return AppRoutes.admin;
      }
      if (user.role != UserRole.spare && !isPublic) {
        return AppRoutes.shopHome;
      }
    }
    return null;
  }

  if (path.startsWith('/shop')) {
    final isPublic = shopAuthPaths.contains(path);
    if (!loggedIn && !isPublic) {
      return AppRoutes.shopLogin;
    }
    if (loggedIn) {
      if (user.role == UserRole.admin && !isPublic) {
        return AppRoutes.admin;
      }
      if (user.role != UserRole.shop && !isPublic) {
        return AppRoutes.spareHome;
      }
    }
    return null;
  }

  return null;
}
