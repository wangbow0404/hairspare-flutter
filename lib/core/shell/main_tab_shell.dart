import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/store_route_helper.dart';
import '../../utils/store_shell_actions.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/store/store_bottom_nav_bar.dart';

/// StatefulShellRoute 하단 탭 셸 (스페어 / 샵 공통).
class MainTabShell extends StatelessWidget {
  const MainTabShell({
    super.key,
    required this.navigationShell,
    required this.persona,
  });

  final StatefulNavigationShell navigationShell;
  final BottomNavPersona persona;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        persona: persona,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabTap,
      ),
    );
  }

  void _onTabTap(int index) {
    if (index == 0) {
      navigationShell.goBranch(0, initialLocation: true);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// 스페어 셸 — 모델 계정 탭 분기 + 스토어 플로우 시 전용 하단 바.
class SpareTabShell extends StatelessWidget {
  const SpareTabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isModel = context.select<AuthProvider, bool>(
      (p) => p.currentUser?.isModelAccount ?? false,
    );
    final path = GoRouterState.of(context).uri.path;
    final inStore = StoreRouteHelper.isStoreFlow(path);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: inStore
          ? StoreBottomNavBar(
              currentIndex: StoreRouteHelper.tabIndexForPath(path),
              onTap: (index) => _onStoreTabTap(context, index),
            )
          : BottomNavBar(
              persona:
                  isModel ? BottomNavPersona.spareModel : BottomNavPersona.spare,
              currentIndex: navigationShell.currentIndex,
              onTap: _onMainTabTap,
            ),
    );
  }

  void _onMainTabTap(int index) {
    if (index == 0) {
      navigationShell.goBranch(0, initialLocation: true);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onStoreTabTap(BuildContext context, int index) {
    switch (index) {
      case StoreRouteHelper.storeTabHome:
        context.go(AppRoutes.spareHomeStore);
      case StoreRouteHelper.storeTabCategory:
        final path = GoRouterState.of(context).uri.path;
        if (path != AppRoutes.spareHomeStore) {
          context.go(AppRoutes.spareHomeStore);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            StoreShellActions.requestCategorySheet();
          });
        } else {
          StoreShellActions.requestCategorySheet();
        }
      case StoreRouteHelper.storeTabWishlist:
        context.go(AppRoutes.spareHomeStoreWishlist);
      case StoreRouteHelper.storeTabMy:
        context.go(AppRoutes.spareHomeStoreMy);
    }
  }
}
