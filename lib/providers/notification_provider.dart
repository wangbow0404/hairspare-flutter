import 'package:flutter/foundation.dart';
import '../models/notification.dart' show AppNotification;
import '../services/notification_service.dart';
import '../utils/error_handler.dart';

class NotificationProvider with ChangeNotifier {
  NotificationProvider(this._notificationService);

  final NotificationService _notificationService;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String _audience = 'spare';

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<AppNotification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 알림 목록 로드
  /// [audience] `spare` | `shop` | `model` — mock·API 모두 역할에 맞는 알림만 조회.
  Future<void> loadNotifications({String audience = 'spare'}) async {
    _audience = audience;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(
        audience: audience,
      );
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

  /// 알림 확인 처리 — 읽음 표시(자세히 보기 목록 유지).
  Future<void> markAsRead(String notificationId, {String? audience}) async {
    final role = audience ?? _audience;
    try {
      await _notificationService.markAsRead(notificationId, audience: role);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(
    String notificationId, {
    String? audience,
  }) async {
    final role = audience ?? _audience;
    try {
      await _notificationService.deleteNotification(
        notificationId,
        audience: role,
      );
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
    }
  }

  /// 화면에서만 즉시 숨김 — "실행취소" 대기 중에는 서버에 삭제 요청을 보내지
  /// 않는다. [restoreLocally]로 되돌리거나 [deleteNotification]으로 확정한다.
  void removeLocally(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// [removeLocally]로 숨겼던 알림을 원래 자리로 복원한다("실행취소").
  void restoreLocally(AppNotification notification) {
    if (_notifications.any((n) => n.id == notification.id)) return;
    _notifications.add(notification);
    notifyListeners();
  }

  /// 알림 새로고침
  Future<void> refreshNotifications() async {
    await loadNotifications(audience: _audience);
  }
}
