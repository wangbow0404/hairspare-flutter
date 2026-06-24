import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../core/router/app_router.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import 'app_bar_navigation.dart';
import 'messaging_navigation.dart';
import 'shell_navigation.dart';

/// go_router 기반 네비게이션 헬퍼.
abstract final class NavigationHelper {
  static void safePop(BuildContext context, [dynamic result]) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  static void navigateToHomeFromLogo(BuildContext context) {
    appRouter.go(AppRoutes.spareHome);
  }

  static Future<bool> showBackConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('확인'),
        content: const Text('정말 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void navigateToJobDetail(BuildContext context, String jobId) {
    ShellNavigation.pushJobDetail(context, jobId);
  }

  static Future<void> navigateToWorkCheck(
    BuildContext context, {
    DateTime? initialDay,
    String? jobId,
    String? scheduleId,
    bool openProposalDetail = false,
  }) {
    return ShellNavigation.pushWorkCheck(context);
  }

  static Future<bool?> navigateToWorkProposalDetail(
    BuildContext context,
    Schedule schedule,
  ) {
    return ShellNavigation.pushWorkProposalJobDetail(context, schedule.jobId);
  }

  static void navigateToMessages(BuildContext context) {
    AppBarNavigation.pushMessages(context);
  }

  static void navigateToNotificationsList(BuildContext context) {
    AppBarNavigation.pushNotificationsList(context);
  }

  static void navigateToChat(
    BuildContext context,
    String chatId, {
    String? audience,
  }) {
    if (audience != null) {
      MessagingNavigation.openChatForAudience(
        context,
        chatId,
        audience: audience,
      );
      return;
    }
    MessagingNavigation.openChat(context, chatId);
  }
}
