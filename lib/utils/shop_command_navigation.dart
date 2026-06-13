import 'package:flutter/material.dart';

import '../core/router/app_navigation.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/shop_command_search_item.dart';
import '../screens/shop/challenge_screen.dart';
import '../screens/shop/education_screen.dart';
import '../screens/shop/job_new_screen.dart';
import '../screens/shop/jobs_list_screen.dart';
import '../screens/shop/my_spaces_screen.dart';
import '../screens/shop/points_screen.dart';
import '../screens/shop/schedule_screen.dart';
import '../screens/shop/spares_list_screen.dart';

/// 샵 기능 검색에서 선택한 항목으로 이동.
abstract final class ShopCommandNavigation {
  static Future<void> open(ShopCommandDestination destination) async {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    switch (destination) {
      case ShopCommandDestination.jobsList:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopJobsListScreen(),
          ),
        );
      case ShopCommandDestination.jobNew:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopJobNewScreen(),
          ),
        );
      case ShopCommandDestination.sparesList:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopSparesListScreen(),
          ),
        );
      case ShopCommandDestination.schedule:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopScheduleScreen(),
          ),
        );
      case ShopCommandDestination.messages:
        await appRouter.push(AppRoutes.shopMessages);
      case ShopCommandDestination.notifications:
        await appRouter.push(AppRoutes.shopNotifications);
      case ShopCommandDestination.points:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopPointsScreen(),
          ),
        );
      case ShopCommandDestination.paymentTab:
        AppNavigation.goShopMainTab(context, 1);
      case ShopCommandDestination.education:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopEducationScreen(),
          ),
        );
      case ShopCommandDestination.spaces:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopMySpacesScreen(),
          ),
        );
      case ShopCommandDestination.favoritesTab:
        AppNavigation.goShopMainTab(context, 2);
      case ShopCommandDestination.challenge:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ShopChallengeScreen(),
          ),
        );
    }
  }
}
