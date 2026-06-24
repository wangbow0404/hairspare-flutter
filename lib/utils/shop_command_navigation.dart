import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_navigation.dart';
import '../core/router/app_routes.dart';
import '../core/router/app_router.dart';
import '../models/shop_command_search_item.dart';

/// 샵 기능 검색에서 선택한 항목으로 이동.
abstract final class ShopCommandNavigation {
  static Future<void> open(ShopCommandDestination destination) async {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    switch (destination) {
      case ShopCommandDestination.jobsList:
        await context.push<void>(AppRoutes.shopProfileJobs);
      case ShopCommandDestination.jobNew:
        await context.push<void>(AppRoutes.shopProfileJobs);
        await context.push<void>('${AppRoutes.shopProfileJobs}/shop_job_new');
      case ShopCommandDestination.sparesList:
        await context.push<void>(AppRoutes.shopHomeSpares);
      case ShopCommandDestination.schedule:
        await context.push<void>(AppRoutes.shopHomeSchedule);
      case ShopCommandDestination.messages:
        await appRouter.push(AppRoutes.shopMessages);
      case ShopCommandDestination.notifications:
        await appRouter.push(AppRoutes.shopNotifications);
      case ShopCommandDestination.points:
        await context.push<void>(AppRoutes.shopHomePoints);
      case ShopCommandDestination.paymentTab:
        AppNavigation.goShopMainTab(context, 1);
      case ShopCommandDestination.education:
        await context.push<void>(AppRoutes.shopHomeEducation);
      case ShopCommandDestination.spaces:
        await context.push<void>(AppRoutes.shopHomeSpaces);
      case ShopCommandDestination.favoritesTab:
        AppNavigation.goShopMainTab(context, 2);
      case ShopCommandDestination.challenge:
        await context.push<void>(AppRoutes.shopHomeChallenge);
    }
  }
}
