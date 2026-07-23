import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/challenge_view_model.dart';
import 'challenge_feed_tab_button.dart';

/// 상단 중앙 탭만 남긴 초미니멀 오버레이 — 뒤로가기 + 전체/구독 탭.
/// 로딩·빈 화면([ChallengeLoadingScaffold]/[ChallengeEmptyScaffold])도
/// 전환 시 깜빡임 없도록 동일한 레이아웃([ChallengeImmersiveTabHeader])을 씀.
class ChallengeImmersiveTopLayer extends StatelessWidget {
  const ChallengeImmersiveTopLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    return ChallengeImmersiveTabHeader(
      allSelected: vm.feedTabIndex == 0,
      onTapAll: () => context.read<ChallengeViewModel>().switchFeedTab(0),
      onTapSubscribed: () => context.read<ChallengeViewModel>().switchFeedTab(1),
    );
  }
}

/// [ChallengeImmersiveTopLayer]의 순수 레이아웃 — ViewModel 없이도(로딩 중) 쓸 수 있게 분리.
class ChallengeImmersiveTabHeader extends StatelessWidget {
  const ChallengeImmersiveTabHeader({
    super.key,
    required this.allSelected,
    required this.onTapAll,
    required this.onTapSubscribed,
  });

  final bool allSelected;
  final VoidCallback onTapAll;
  final VoidCallback onTapSubscribed;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    const double sideSlot = 48;

    return Padding(
      padding: EdgeInsets.only(top: topPad + 6),
      child: Row(
        children: [
          SizedBox(
            width: sideSlot,
            height: sideSlot,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: sideSlot, height: sideSlot),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChallengeFeedTabButton(
                    label: '전체',
                    isSelected: allSelected,
                    variant: ChallengeFeedTabVariant.immersive,
                    onTap: onTapAll,
                  ),
                  const SizedBox(width: 28),
                  ChallengeFeedTabButton(
                    label: '구독',
                    isSelected: !allSelected,
                    variant: ChallengeFeedTabVariant.immersive,
                    onTap: onTapSubscribed,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: sideSlot, height: sideSlot),
        ],
      ),
    );
  }
}
