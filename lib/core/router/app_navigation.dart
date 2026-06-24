import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import 'app_router.dart';
import 'app_routes.dart';

/// 하드코딩된 `Navigator.pushReplacement(..., HomeScreen)` 대체.
///
/// [BuildContext]는 호출부 호환용이며, 라우팅은 [appRouter]로 수행합니다.
class AppNavigation {
  AppNavigation._();

  static void goRoleSelect(BuildContext context) =>
      appRouter.go(AppRoutes.roleSelect);

  /// 로그인 화면 뒤로 — go_router 스택이 비면 역할 선택으로.
  static void backFromLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    goRoleSelect(context);
  }

  static void goSpareLogin(BuildContext context) =>
      appRouter.go(AppRoutes.spareLogin);

  static void goShopLogin(BuildContext context) =>
      appRouter.go(AppRoutes.shopLogin);

  static void goSpareHome(BuildContext context) =>
      appRouter.go(AppRoutes.spareHome);

  static void goShopHome(BuildContext context) =>
      appRouter.go(AppRoutes.shopHome);

  static void goAdminDashboard(BuildContext context) =>
      appRouter.go(AppRoutes.admin);

  /// 로그인 성공 후 [role]에 맞는 홈으로 이동 (admin → `/admin`).
  static void goHomeForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        appRouter.go(AppRoutes.admin);
      case UserRole.shop:
        appRouter.go(AppRoutes.shopHome);
      case UserRole.spare:
        appRouter.go(AppRoutes.spareHome);
    }
  }

  /// 결제 화면 뒤로 — push 스택이 있으면 pop, 탭 루트면 [homeTabIndex]로 이동.
  static void backFromPaymentTab(
    BuildContext context, {
    required void Function(BuildContext context) goHomeTab,
  }) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    goHomeTab(context);
  }

  static void backFromSparePayment(BuildContext context) {
    backFromPaymentTab(context, goHomeTab: (ctx) => goSpareMainTab(ctx, 0));
  }

  static void backFromShopPayment(BuildContext context) {
    backFromPaymentTab(context, goHomeTab: (ctx) => goShopMainTab(ctx, 0));
  }

  /// 모델 메인 탭 (0=홈, 1=매칭, 2=스케줄, 3=마이)
  static void goModelMainTab(BuildContext context, int index) {
    const paths = <String>[
      AppRoutes.modelHome,
      AppRoutes.modelMatching,
      AppRoutes.modelSchedule,
      AppRoutes.modelProfile,
    ];
    appRouter.go(paths[index]);
  }

  /// 모델 탭 루트·프로필 push 공통 — pop 가능하면 pop, 아니면 홈 탭.
  static void backFromModelTab(BuildContext context) {
    backFromPaymentTab(context, goHomeTab: (ctx) => goModelMainTab(ctx, 0));
  }

  /// 스페어 메인 탭 (0=홈, 1=결제, 2=찜, 3=마이)
  static void goSpareMainTab(BuildContext context, int index) {
    const paths = <String>[
      AppRoutes.spareHome,
      AppRoutes.sparePayment,
      AppRoutes.spareFavorites,
      AppRoutes.spareProfile,
    ];
    appRouter.go(paths[index]);
  }

  /// 샵 메인 탭 (0=홈, 1=결제, 2=찜, 3=마이)
  static void goShopMainTab(BuildContext context, int index) {
    const paths = <String>[
      AppRoutes.shopHome,
      AppRoutes.shopPayment,
      AppRoutes.shopFavorites,
      AppRoutes.shopProfile,
    ];
    appRouter.go(paths[index]);
  }

  static void pushSpareLogin(BuildContext context) => goSpareLogin(context);

  static void pushShopLogin(BuildContext context) => goShopLogin(context);
}
