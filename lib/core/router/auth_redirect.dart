import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import 'app_routes.dart';

/// 로그인된 유저가 돌아갈 홈 경로 (역할·모델 여부 기준).
String homeRouteFor(User user) {
  if (user.role == UserRole.admin) return AppRoutes.admin;
  if (user.role == UserRole.shop) return AppRoutes.shopHome;
  if (user.isModelAccount) return AppRoutes.modelHome;
  return AppRoutes.spareHome;
}

/// 스페어 로그인·회원가입·계정찾기 등 비로그인 접근 허용 경로.
bool _isSparePublicPath(String path) {
  const spareAuthPaths = <String>{
    AppRoutes.spareLogin,
    AppRoutes.spareSignup,
    AppRoutes.spareFindId,
    AppRoutes.spareFindPassword,
    AppRoutes.spareSignupProfessional,
    AppRoutes.spareSignupModel,
  };
  return spareAuthPaths.contains(path);
}

/// 전역 인증·역할 기반 리다이렉트 (`GoRouter.redirect`).
String? authRedirect(AuthProvider auth, GoRouterState state) {
  final path = state.uri.path;

  if (path == '/spare' || path == '/shop') {
    return null;
  }

  final user = auth.currentUser;
  final loggedIn = auth.isAuthenticated && user != null;

  // 자동로그인 성공 직후에만 보여주는 브랜드 스플래시. 관리자는 마케팅
  // 스플래시가 의미 없어 건너뛰고, 비로그인이면(자동로그인 실패) 바로
  // 역할선택으로 보낸다.
  if (path == AppRoutes.autoLoginSplash) {
    if (!loggedIn) return AppRoutes.roleSelect;
    if (user.role == UserRole.admin) return AppRoutes.admin;
    return null;
  }

  const shopAuthPaths = <String>{
    AppRoutes.shopLogin,
    AppRoutes.shopSignup,
    AppRoutes.shopFindPassword,
  };

  if (loggedIn) {
    if (path == AppRoutes.roleSelect) {
      return homeRouteFor(user);
    }
    if (_isSparePublicPath(path) && path != AppRoutes.spareSignupSuccess) {
      return homeRouteFor(user);
    }
    if (shopAuthPaths.contains(path)) {
      return homeRouteFor(user);
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
    final isPublic = _isSparePublicPath(path);
    if (!loggedIn && path == AppRoutes.spareSignupSuccess) {
      return AppRoutes.spareLogin;
    }
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
      // 모델 계정은 전용 /model 셸을 쓴다. 가입 완료 화면만 예외.
      if (user.isModelAccount &&
          !isPublic &&
          path != AppRoutes.spareSignupSuccess) {
        return AppRoutes.modelHome;
      }
    }
    return null;
  }

  if (path.startsWith('/model')) {
    if (!loggedIn) return AppRoutes.spareLogin;
    if (!user.isModelAccount) return homeRouteFor(user);
    return null;
  }

  if (path.startsWith('/shop')) {
    final isPublic = shopAuthPaths.contains(path);
    if (!loggedIn && path == AppRoutes.shopSignupSuccess) {
      return AppRoutes.shopLogin;
    }
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
