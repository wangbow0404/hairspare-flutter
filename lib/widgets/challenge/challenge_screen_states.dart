import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/challenge_view_model.dart';
import 'challenge_immersive_top_layer.dart';

/// 로딩 중 — 실제 피드([ChallengeImmersiveTopLayer])와 동일한 전체/구독 탭 헤더로
/// 로딩 완료 순간 상단바가 바뀌어 보이지 않게 함. ViewModel이 아직 없어 탭은 정적(전체 고정).
class ChallengeLoadingScaffold extends StatelessWidget {
  const ChallengeLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChallengeImmersiveTabHeader(
              allSelected: true,
              onTapAll: () {},
              onTapSubscribed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// 챌린지가 없을 때 — ViewModel이 있으므로 전체/구독 탭 실제 전환 가능.
class ChallengeEmptyScaffold extends StatelessWidget {
  const ChallengeEmptyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '챌린지가 없습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChallengeImmersiveTabHeader(
              allSelected: vm.feedTabIndex == 0,
              onTapAll: () => context.read<ChallengeViewModel>().switchFeedTab(0),
              onTapSubscribed: () =>
                  context.read<ChallengeViewModel>().switchFeedTab(1),
            ),
          ),
        ],
      ),
    );
  }
}
