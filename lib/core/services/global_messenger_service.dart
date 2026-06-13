import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 앱 전역 [ScaffoldMessenger] 스낵바 — ViewModel이 [BuildContext] 없이 메시지를 띄울 때 사용.
///
/// [main.dart]의 `MaterialApp.router(scaffoldMessengerKey: ...)`와 동일한 키를 써야 합니다.
class GlobalMessengerService {
  GlobalMessengerService();

  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ScaffoldMessengerState? get _state => messengerKey.currentState;

  static const Duration _defaultDuration = Duration(seconds: 3);

  void _show(
    String message, {
    Color? backgroundColor,
    Duration duration = _defaultDuration,
  }) {
    final state = _state;
    if (state == null) {
      debugPrint('[GlobalMessengerService] (no ScaffoldMessenger) $message');
      return;
    }
    state.clearSnackBars();
    state.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 일반 알림 (테마 기본 배경).
  void showMessage(String message, {Duration duration = _defaultDuration}) {
    _show(message, backgroundColor: null, duration: duration);
  }

  void showSuccess(String message, {Duration duration = _defaultDuration}) {
    _show(
      message,
      backgroundColor: AppTheme.primaryGreen,
      duration: duration,
    );
  }

  void showError(String message, {Duration duration = _defaultDuration}) {
    _show(
      message,
      backgroundColor: AppTheme.urgentRed,
      duration: duration,
    );
  }

  /// 정보성 (블루 계열).
  void showInfo(String message, {Duration duration = _defaultDuration}) {
    _show(
      message,
      backgroundColor: AppTheme.primaryBlue,
      duration: duration,
    );
  }
}
