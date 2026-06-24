import 'dart:async';

import 'package:flutter/material.dart';

/// hot reload(reassemble) 직후 자동 스크롤 재개를 지연해 layout+jumpTo 경합을 방지한다.
mixin AutoScrollReassembleMixin<T extends StatefulWidget> on State<T> {
  Timer? autoScrollReassembleTimer;

  /// reassemble에서 타이머 cancel 후 지연 재시작.
  void pauseAutoScrollForReassemble({
    required Timer? autoScrollTimer,
    required void Function(bool scrolling) setScrolling,
    required VoidCallback startAutoScroll,
    Duration delay = const Duration(milliseconds: 800),
  }) {
    autoScrollTimer?.cancel();
    setScrolling(true);
    scheduleDeferredAutoScrollStart(
      startAutoScroll: startAutoScroll,
      delay: delay,
      onBeforeStart: () => setScrolling(false),
    );
  }

  /// initState·reassemble 직후 자동 스크롤 시작을 지연 (로그인·reload 직후 layout 경합 방지).
  void scheduleDeferredAutoScrollStart({
    required VoidCallback startAutoScroll,
    Duration delay = const Duration(milliseconds: 1200),
    VoidCallback? onBeforeStart,
  }) {
    autoScrollReassembleTimer?.cancel();
    autoScrollReassembleTimer = Timer(delay, () {
      if (!mounted) return;
      onBeforeStart?.call();
      startAutoScroll();
    });
  }

  @override
  void dispose() {
    autoScrollReassembleTimer?.cancel();
    super.dispose();
  }
}
