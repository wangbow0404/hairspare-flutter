import 'package:flutter/material.dart';
import '../screens/spare/job_detail_screen.dart';
import '../screens/spare/schedule_screen.dart';
import '../screens/spare/messages_screen.dart';
import '../screens/spare/chat_room_screen.dart';
import '../screens/spare/home_screen.dart';
import '../screens/spare/notifications_list_screen.dart';

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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SpareHomeScreen()),
      (route) => false,
    );
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

  /// 공고 상세 화면으로 이동
  static void navigateToJobDetail(BuildContext context, String jobId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: jobId),
      ),
    );
  }

  /// 스케줄 화면으로 이동
  static void navigateToSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleScreen(),
      ),
    );
  }

  /// 메시지 목록 화면으로 이동
  static void navigateToMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MessagesScreen(),
      ),
    );
  }

  /// 전체 알림 목록 화면으로 이동
  static void navigateToNotificationsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsListScreen(),
      ),
    );
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
