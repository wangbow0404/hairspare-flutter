import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_nav_bar.dart';

/// StatefulShellRoute 하단 탭 셸 (스페어 / 샵 공통).
class MainTabShell extends StatelessWidget {
  const MainTabShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          // 홈 탭: Navigator.push로 쌓인 서브화면(공고별 등)을 닫고 메인 홈으로.
          if (index == 0) {
            navigationShell.goBranch(0, initialLocation: true);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
