import 'package:flutter/foundation.dart';
import '../models/notification.dart' show AppNotification;
import '../services/notification_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 알림 목록 로드
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // 로컬 상태 업데이트
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // AppNotification은 불변 객체이므로 새 인스턴스 생성 필요
        // 하지만 현재 모델에 copyWith가 없으므로, 전체 리스트를 다시 로드
        await loadNotifications();
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // 로컬 상태에서 제거
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
    }
  }

  /// 알림 새로고침
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
