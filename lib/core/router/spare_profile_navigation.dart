import 'package:flutter/material.dart';

import '../../screens/spare/challenge_profile_screen.dart';
import '../../screens/spare/energy_screen.dart';
import '../../screens/spare/my_applications_screen.dart';
import '../../screens/spare/my_space_bookings_screen.dart';
import '../../screens/spare/profile_edit_screen.dart';
import '../../screens/spare/referral_screen.dart';
import '../../screens/spare/settings_screen.dart';
import '../../screens/spare/subscriptions_screen.dart';
import '../../screens/spare/verification_screen.dart';
import '../../screens/spare/work_check_screen.dart';
import '../../utils/navigation_helper.dart';
import 'app_navigation.dart';

/// 스페어 프로필 화면에서 사용하는 화면 이동 (UI 위젯과 분리).
abstract final class SpareProfileNavigation {
  static void openHomeFromLogo(BuildContext context) {
    NavigationHelper.navigateToHomeFromLogo(context);
  }

  static Future<void> pushSettings(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  static Future<void> pushProfileEdit(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ProfileEditScreen()),
    );
  }

  static Future<void> pushChallengeProfile(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ChallengeProfileScreen()),
    );
  }

  static Future<void> pushSubscriptions(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const SubscriptionsScreen()),
    );
  }

  static Future<void> pushEnergy(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const EnergyScreen()),
    );
  }

  static Future<void> pushWorkCheck(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const WorkCheckScreen()),
    );
  }

  static Future<void> pushMyApplications(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const MyApplicationsScreen()),
    );
  }

  static Future<void> pushMySpaceBookings(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const MySpaceBookingsScreen()),
    );
  }

  static void goPaymentTab(BuildContext context) {
    AppNavigation.goSpareMainTab(context, 1);
  }

  static Future<void> pushReferral(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ReferralScreen()),
    );
  }

  static Future<void> pushVerification(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const VerificationScreen()),
    );
  }
}
