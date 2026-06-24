import 'package:flutter/material.dart';

/// 상태바·노치·Dynamic Island 아래부터 본문을 시작합니다.
///
/// - 탭 루트·풀스크린 [Scaffold.body]: 이 위젯으로 감쌉니다.
/// - 커스텀 Sliver 상단바: [AppScreenInsets.topBarShell] 사용.
/// - [Scaffold.appBar] + Material [AppBar]: Flutter가 safe area를 처리합니다.
class AppScreenSafeArea extends StatelessWidget {
  const AppScreenSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = false,
    this.left = true,
    this.right = true,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
