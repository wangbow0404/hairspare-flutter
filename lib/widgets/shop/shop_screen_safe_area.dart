import 'package:flutter/material.dart';

import '../common/app_screen_safe_area.dart';

/// 샵 서브 화면 공통 — [AppScreenSafeArea] 래퍼 (하위 호환).
class ShopScreenSafeArea extends StatelessWidget {
  const ShopScreenSafeArea({
    super.key,
    required this.child,
    this.bottom = false,
  });

  final Widget child;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return AppScreenSafeArea(
      bottom: bottom,
      child: child,
    );
  }
}
