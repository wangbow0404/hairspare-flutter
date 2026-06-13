import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/challenge_view_model.dart';
import 'challenge_feed_tab_button.dart';

/// 상단 중앙 탭만 남긴 초미니멀 오버레이.
class ChallengeImmersiveTopLayer extends StatelessWidget {
  const ChallengeImmersiveTopLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
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
                    isSelected: vm.feedTabIndex == 0,
                    variant: ChallengeFeedTabVariant.immersive,
                    onTap: () async {
                      await context.read<ChallengeViewModel>().switchFeedTab(0);
                    },
                  ),
                  const SizedBox(width: 28),
                  ChallengeFeedTabButton(
                    label: '구독',
                    isSelected: vm.feedTabIndex == 1,
                    variant: ChallengeFeedTabVariant.immersive,
                    onTap: () async {
                      await context.read<ChallengeViewModel>().switchFeedTab(1);
                    },
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
