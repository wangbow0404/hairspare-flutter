import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 홈 가로 자동 스크롤·화면 전환 경합 방지.
///
/// [pushPage]로 push한 동안 + pop 애니메이션 직후까지 jumpTo()를 막는다.
class NavigationLock {
  NavigationLock._();

  static bool _locked = false;
  static int _activePushes = 0;
  static Timer? _resumeTimer;
  static final Set<VoidCallback> _pauseAutoScrollListeners = {};
  static final Set<VoidCallback> _resumeAutoScrollListeners = {};

  static bool get isLocked => _locked || _activePushes > 0;

  /// 홈 가로 자동 스크롤 타이머 등록 — push 직전 즉시 cancel.
  static void addAutoScrollPauseListener(VoidCallback listener) {
    _pauseAutoScrollListeners.add(listener);
  }

  static void removeAutoScrollPauseListener(VoidCallback listener) {
    _pauseAutoScrollListeners.remove(listener);
  }

  /// pop 후 자동 스크롤 재개(지연).
  static void addAutoScrollResumeListener(VoidCallback listener) {
    _resumeAutoScrollListeners.add(listener);
  }

  static void removeAutoScrollResumeListener(VoidCallback listener) {
    _resumeAutoScrollListeners.remove(listener);
  }

  static void _pauseHomeAutoScroll() {
    for (final listener in List<VoidCallback>.from(_pauseAutoScrollListeners)) {
      listener();
    }
  }

  static void _resumeHomeAutoScroll() {
    for (final listener in List<VoidCallback>.from(_resumeAutoScrollListeners)) {
      listener();
    }
  }

  /// 서브 화면이 열려 있는 동안 홈 자동 스크롤 금지.
  static bool shouldRunHomeAutoScroll(BuildContext context) {
    if (!context.mounted || isLocked) return false;
    final route = ModalRoute.of(context);
    if (route == null) return false;
    return route.isCurrent;
  }

  static void _beginPush() {
    _activePushes++;
    _locked = true;
    _resumeTimer?.cancel();
    _pauseHomeAutoScroll();
  }

  static void _endPush() {
    if (_activePushes > 0) _activePushes--;
    if (_activePushes > 0) return;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 500), () {
      if (_activePushes == 0) {
        _locked = false;
        _resumeHomeAutoScroll();
      }
    });
  }

  /// push/pop 전체 구간 동안 잠금 유지.
  static Future<T?> beginNavigation<T>(Future<T?> navigation) {
    _beginPush();
    return navigation.whenComplete(_endPush);
  }

  /// go_router [context.push] 또는 레거시 [Navigator.push] + 잠금.
  ///
  /// [path]가 있으면 go_router push, 없으면 [page] MaterialPageRoute.
  /// @deprecated [Navigator.push] — [path] + go_router 사용 권장.
  static Future<T?> pushPage<T>(
    BuildContext context,
    Widget page, {
    String? path,
    Object? extra,
  }) {
    if (!context.mounted) return Future.value(null);
    if (path != null) {
      return beginNavigation(context.push<T>(path, extra: extra));
    }
    return beginNavigation(
      Navigator.push<T>(
        context,
        MaterialPageRoute<T>(builder: (_) => page),
      ),
    );
  }

  /// @deprecated [pushPage] 사용.
  static void lock({Duration duration = const Duration(milliseconds: 500)}) {
    _locked = true;
    _pauseHomeAutoScroll();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(duration, () {
      if (_activePushes == 0) {
        _locked = false;
        _resumeHomeAutoScroll();
      }
    });
  }
}
