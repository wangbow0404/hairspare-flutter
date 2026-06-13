import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../models/user.dart';
import '../screens/shop/job_detail_screen.dart';
import '../screens/shop/schedule_screen.dart';
import '../screens/spare/job_detail_screen.dart';
import '../screens/spare/schedule_screen.dart';
import '../screens/spare/work_check_screen.dart';
import '../models/schedule.dart';
import '../screens/spare/chat_room_screen.dart';
import 'app_bar_navigation.dart';

/// 네비게이션 헬퍼 유틸리티
class NavigationHelper {
  /// 안전하게 화면을 닫기 (스택이 비어있지 않은 경우에만)
  static void safePop(BuildContext context, [dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  /// 안전하게 화면을 교체 (스택이 비어있지 않은 경우에만)
  static void safePushReplacement(
    BuildContext context,
    Widget newRoute,
  ) {
    if (Navigator.canPop(context)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => newRoute),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => newRoute),
        (route) => false,
      );
    }
  }

  /// 홈 화면으로 이동 (모든 스택 제거)
  static void navigateToHome(BuildContext context, Widget homeScreen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => homeScreen),
      (route) => false,
    );
  }

  /// 로고 클릭 시 홈 화면으로 이동 (SpareHomeScreen)
  static void navigateToHomeFromLogo(BuildContext context) {
    appRouter.go(AppRoutes.spareHome);
  }

  /// 확인 다이얼로그 표시 후 뒤로가기
  static Future<bool> showBackConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('확인'),
        content: const Text('정말 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 공고 상세 화면으로 이동 (역할에 따라 샵·스페어 화면 분기).
  static void navigateToJobDetail(BuildContext context, String jobId) {
    final isShop = AppBarNavigation.inferAppSectionRole(context) ==
        UserRole.shop;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => isShop
            ? ShopJobDetailScreen(jobId: jobId)
            : JobDetailScreen(jobId: jobId),
      ),
    );
  }

  /// 스페어 스케줄표(WorkCheck)로 이동 — 홈·프로필·알림 기본 경로.
  static Future<void> navigateToWorkCheck(
    BuildContext context, {
    DateTime? initialDay,
    String? jobId,
    String? scheduleId,
    bool openProposalDetail = false,
  }) {
    if (AppBarNavigation.inferAppSectionRole(context) == UserRole.shop) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const ShopScheduleScreen(),
        ),
      );
    }
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WorkCheckScreen(
          initialDay: initialDay,
          focusJobId: jobId,
          focusScheduleId: scheduleId,
          openProposalDetail: openProposalDetail,
        ),
      ),
    );
  }

  /// 근무 제안 → 공고 상세에서 수락/거절. 성공 시 `true` 반환.
  static Future<bool?> navigateToWorkProposalDetail(
    BuildContext context,
    Schedule schedule,
  ) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => JobDetailScreen(jobId: schedule.jobId),
      ),
    );
  }

  /// TableCalendar 스케줄 화면 (레거시·내부용).
  static void navigateToSchedule(
    BuildContext context, {
    DateTime? initialDay,
    String? jobId,
    String? scheduleId,
    bool openProposalReview = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleScreen(
          initialDay: initialDay,
          focusJobId: jobId,
          focusScheduleId: scheduleId,
          openProposalReview: openProposalReview,
        ),
      ),
    );
  }

  /// 메시지 목록 화면으로 이동 (스페어/샵 역할에 따라 [AppBarNavigation]과 동일 경로)
  static void navigateToMessages(BuildContext context) {
    AppBarNavigation.pushMessages(context);
  }

  /// 전체 알림 목록 화면으로 이동
  static void navigateToNotificationsList(BuildContext context) {
    AppBarNavigation.pushNotificationsList(context);
  }

  /// 채팅방 화면으로 이동
  static void navigateToChat(BuildContext context, String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(chatId: chatId),
      ),
    );
  }
}
