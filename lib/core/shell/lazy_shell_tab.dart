import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [StatefulShellRoute.indexedStack] 비활성 탭은 마운트하지 않음.
///
/// 로그인 직후 4탭이 동시에 initState·API 호출되며 UI가 멈추는 문제를 방지한다.
/// 홈(tab 0)만 즉시 빌드하고, 나머지 탭은 사용자가 탭할 때 처음 마운트한다.
class LazyShellTab extends StatelessWidget {
  const LazyShellTab({
    super.key,
    required this.tabIndex,
    required this.child,
  });

  final int tabIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null && shell.currentIndex != tabIndex) {
      return const SizedBox.shrink();
    }
    return child;
  }
}
