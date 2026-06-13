import 'package:flutter/material.dart';

/// 샵 서브 화면 공통 — 상태바·노치 아래부터 본문 시작.
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
    return SafeArea(
      top: true,
      bottom: bottom,
      child: child,
    );
  }
}
