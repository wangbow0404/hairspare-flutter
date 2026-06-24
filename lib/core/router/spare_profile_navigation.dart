import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../utils/navigation_helper.dart';

/// 스페어 프로필 화면에서 사용하는 화면 이동 (UI 위젯과 분리).
abstract final class SpareProfileNavigation {
  static void openHomeFromLogo(BuildContext context) {
    NavigationHelper.navigateToHomeFromLogo(context);
  }

  static void pushSettings(BuildContext context) {
    context.push(AppRoutes.spareProfileSettings);
  }

  static Future<void> pushProfileEdit(BuildContext context) {
    return context.push<void>(AppRoutes.spareProfileEdit);
  }

  static void pushChallengeProfile(BuildContext context) {
    context.push(AppRoutes.spareProfileChallenge);
  }

  static void pushPortfolio(BuildContext context) {
    context.push(AppRoutes.spareProfilePortfolio);
  }

  static void pushSubscriptions(BuildContext context) {
    context.push(AppRoutes.spareProfileSubscriptions);
  }

  static void pushEnergy(BuildContext context) {
    context.push(AppRoutes.spareProfileEnergy);
  }

  static void pushWorkCheck(BuildContext context) {
    context.push(AppRoutes.spareProfileWorkCheck);
  }

  static void pushMyApplications(BuildContext context) {
    context.push(AppRoutes.spareProfileApplications);
  }

  static void pushMySpaceBookings(BuildContext context) {
    context.push(AppRoutes.spareProfileSpaceBookings);
  }

  static void pushPayment(BuildContext context) {
    context.push(AppRoutes.spareProfilePayment);
  }

  static void pushReferral(BuildContext context) {
    context.push(AppRoutes.spareProfileReferral);
  }

  static void pushVerification(BuildContext context) {
    context.push(AppRoutes.spareProfileVerification);
  }
}
