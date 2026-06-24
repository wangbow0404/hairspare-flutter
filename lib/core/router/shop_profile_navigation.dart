import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';

/// 샵 프로필 화면에서 사용하는 화면 이동.
abstract final class ShopProfileNavigation {
  static void pushVip(BuildContext context) {
    context.push(AppRoutes.shopProfileVip);
  }

  static void pushSchedule(BuildContext context) {
    context.push(AppRoutes.shopProfileSchedule);
  }

  static void pushJobs(BuildContext context) {
    context.push(AppRoutes.shopProfileJobs);
  }

  static void pushSpaces(BuildContext context) {
    context.push(AppRoutes.shopProfileSpaces);
  }

  static void pushApplicants(BuildContext context) {
    context.push(AppRoutes.shopProfileApplicants);
  }

  static void pushPortfolio(BuildContext context) {
    context.push(AppRoutes.shopProfilePortfolio);
  }

  static void pushPayment(BuildContext context) {
    context.push(AppRoutes.shopProfilePayment);
  }

  static void pushVerification(BuildContext context) {
    context.push(AppRoutes.shopProfileVerification);
  }

  static void pushSettings(BuildContext context) {
    context.push(AppRoutes.shopProfileSettings);
  }

  static Future<void> pushProfileEdit(BuildContext context) {
    return context.push<void>(AppRoutes.shopProfileEdit);
  }
}
