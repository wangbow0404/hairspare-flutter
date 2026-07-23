import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

/// StatefulShellRoute 하단 탭 셸 (스페어 / 샵 공통).
class MainTabShell extends StatelessWidget {
  const MainTabShell({
    super.key,
    required this.navigationShell,
    required this.persona,
  });

  final StatefulNavigationShell navigationShell;
  final BottomNavPersona persona;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        persona: persona,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabTap,
      ),
    );
  }

  void _onTabTap(int index) {
    if (index == 0) {
      navigationShell.goBranch(0, initialLocation: true);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// 스페어 셸 — 모델 계정이면 탭 라벨 분기.
class SpareTabShell extends StatelessWidget {
  const SpareTabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isModel = context.select<AuthProvider, bool>(
      (p) => p.currentUser?.isModelAccount ?? false,
    );
    return MainTabShell(
      navigationShell: navigationShell,
      persona: isModel ? BottomNavPersona.spareModel : BottomNavPersona.spare,
    );
  }
}
