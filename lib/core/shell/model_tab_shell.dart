import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/model_bottom_nav_bar.dart';

/// 모델 전용 하단 탭 셸 — 홈 · 메시지 · 스케줄 · 마이.
///
/// 스페어/샵 공통 [MainTabShell]과 달리 항상 [ModelBottomNavBar]만 사용한다
/// (모델은 자기 전용 `/model/...` 라우트 안에서만 동작).
class ModelTabShell extends StatelessWidget {
  const ModelTabShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ModelBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int index) {
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
