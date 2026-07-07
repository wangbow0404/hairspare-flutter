import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../core/router/route_extras.dart';
import '../models/challenge_profile.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../screens/spare/education_screen.dart';
import 'app_bar_navigation.dart';

/// StatefulShell 하위 — 현재 브랜치 기준 go_router push.
abstract final class ShellNavigation {
  ShellNavigation._();

  static const _branchPrefixes = <String>[
    '/spare/home',
    '/spare/profile',
    '/spare/favorites',
    '/spare/payment',
    '/shop/home',
    '/shop/profile',
    '/shop/favorites',
    '/shop/payment',
    '/model/home',
    '/model/matching',
    '/model/schedule',
    '/model/profile',
  ];

  static String branchBase(BuildContext context) {
    final path = _currentPath(context);
    for (final prefix in _branchPrefixes) {
      if (path == prefix || path.startsWith('$prefix/')) return prefix;
    }
    if (path.startsWith('/shop')) return AppRoutes.shopHome;
    if (path.startsWith('/model')) return AppRoutes.modelHome;
    return AppRoutes.spareHome;
  }

  static String _currentPath(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      return GoRouter.of(context).state.uri.path;
    }
  }

  static bool _isShop(BuildContext context) =>
      AppBarNavigation.inferAppSectionRole(context) == UserRole.shop;

  static String _p(BuildContext context, String suffix) =>
      '${branchBase(context)}/$suffix';

  static Future<T?> push<T>(BuildContext context, String suffix,
      {Object? extra}) {
    return context.push<T>(_p(context, suffix), extra: extra);
  }

  static Future<T?> pushJobDetail<T>(BuildContext context, String jobId) {
    final segment = _isShop(context) ? 'shop_job/$jobId' : 'job/$jobId';
    return context.push<T>(_p(context, segment));
  }

  static Future<T?> pushShopJobDetail<T>(BuildContext context, String jobId) =>
      push<T>(context, 'shop_job/$jobId');

  /// 알림 등에서 특정 공고의 스케줄로 바로 이동 (해당 스케줄이 선택된 상태로 열림).
  static Future<T?> pushShopSchedule<T>(
    BuildContext context, {
    String? focusJobId,
  }) =>
      push<T>(context, 'schedule', extra: focusJobId);

  static Future<bool?> pushShopJobNew(
    BuildContext context, {
    Job? jobToEdit,
    Job? jobToCopy,
  }) {
    return push<bool>(
      context,
      'shop_job_new',
      extra: ShopJobNewRouteArgs(jobToEdit: jobToEdit, jobToCopy: jobToCopy),
    );
  }

  static Future<void> pushShopApplicants(
    BuildContext context, {
    String? jobId,
  }) {
    final base = _p(context, 'shop_applicants');
    final uri = jobId == null ? base : '$base?jobId=$jobId';
    return context.push<void>(uri);
  }

  static Future<void> pushShopSpareDetail(
    BuildContext context,
    String spareId, {
    String? jobId,
  }) {
    final uri = jobId == null ? 'shop_spare/$spareId' : 'shop_spare/$spareId?jobId=$jobId';
    return push<void>(context, uri);
  }

  static Future<void> pushSpaceDetail(BuildContext context, String spaceId) =>
      push<void>(context, 'space/$spaceId');

  static Future<void> pushEducationDetail(
    BuildContext context,
    Education education,
  ) =>
      push<void>(context, 'education_detail', extra: education);

  static Future<void> pushEnrollmentDetail(
    BuildContext context,
    String enrollmentId,
  ) =>
      push<void>(context, 'enrollment/$enrollmentId');

  static Future<bool?> pushEducationCheckout(
    BuildContext context,
    Education education,
  ) =>
      push<bool>(
        context,
        'education_checkout',
        extra: EducationEnergyCheckoutArgs(education: education),
      );

  static Future<void> pushEnergyPurchase(BuildContext context) =>
      push<void>(context, 'energy_purchase');

  static Future<bool?> pushEnergyCheckout(
    BuildContext context,
    EnergyPurchaseCheckoutArgs args,
  ) =>
      push<bool>(context, 'energy_checkout', extra: args);

  static Future<void> pushPointHistory(BuildContext context) =>
      push<void>(context, 'point_history');

  static Future<void> pushVerification(BuildContext context) {
    final segment =
        _isShop(context) ? 'shop_verification' : 'verification';
    return push<void>(context, segment);
  }

  static Future<void> pushChallengeProfile(
    BuildContext context, {
    String? userId,
  }) {
    final base = _p(context, 'challenge_profile');
    final uri = userId == null ? base : '$base?userId=$userId';
    return context.push<void>(uri);
  }

  static Future<bool?> pushChallengeProfileEdit(
    BuildContext context,
    ChallengeProfile profile,
  ) =>
      push<bool>(
        context,
        'challenge_profile_edit',
        extra: ChallengeProfileEditRouteArgs(profile: profile),
      );

  static Future<void> pushChallengeFeed(
    BuildContext context, {
    required String creatorId,
    required String initialVideoId,
  }) {
    final home = _isShop(context) ? AppRoutes.shopHome : AppRoutes.spareHome;
    final uri = Uri(
      path: '$home/challenge',
      queryParameters: {
        'creatorId': creatorId,
        'initialVideoId': initialVideoId,
      },
    );
    return context.push<void>(uri.toString());
  }

  static Future<void> pushSettingsProfileEdit(BuildContext context) =>
      push<void>(context, 'settings_profile_edit');

  static Future<void> pushSettingsNotifications(BuildContext context) =>
      push<void>(context, 'settings_notifications');

  static Future<void> pushSettingsChangePassword(BuildContext context) =>
      push<void>(context, 'settings_change_password');

  static Future<void> pushSettingsDeleteAccount(BuildContext context) =>
      push<void>(context, 'settings_delete_account');

  static Future<bool?> pushShopEducationNew(BuildContext context) =>
      push<bool>(context, 'shop_education_new');

  static Future<bool?> pushShopSpaceNew(BuildContext context) =>
      push<bool>(context, 'shop_space_new');

  static Future<void> pushShopSpaceEdit(
    BuildContext context,
    String spaceId,
  ) =>
      push<void>(context, 'shop_space_edit/$spaceId');

  static Future<void> pushShopSpaceBookings(
    BuildContext context,
    String spaceId,
  ) =>
      push<void>(context, 'shop_space_bookings/$spaceId');

  static Future<bool?> pushShopJobUrgentUpsell(
    BuildContext context,
    ShopJobUrgentUpsellExtra extra,
  ) =>
      push<bool>(context, 'shop_job_urgent_upsell', extra: extra);

  static Future<bool?> pushShopJobUrgentPayment(
    BuildContext context,
    ShopJobUrgentPaymentExtra extra,
  ) =>
      push<bool>(context, 'shop_job_urgent_payment', extra: extra);

  static Future<bool?> pushShopJobOpeningSoonUpsell(
    BuildContext context,
    ShopJobOpeningSoonExtra extra,
  ) =>
      push<bool>(context, 'shop_job_opening_soon_upsell', extra: extra);

  static Future<void> pushReviews(
    BuildContext context,
    ReviewsListRouteArgs args,
  ) =>
      push<void>(context, 'reviews', extra: args);

  static Future<void> pushShopMessages(BuildContext context) =>
      push<void>(context, 'shop_messages');

  static Future<void> pushShopHomeSpares(BuildContext context) =>
      context.push<void>(AppRoutes.shopHomeSpares);

  static Future<void> pushWorkCheck(BuildContext context) {
    if (_isShop(context)) {
      return context.push<void>(AppRoutes.shopProfileSchedule);
    }
    return context.push<void>(AppRoutes.spareProfileWorkCheck);
  }

  static Future<bool?> pushWorkProposalJobDetail(
    BuildContext context,
    String jobId,
  ) =>
      pushJobDetail<bool>(context, jobId);
}
