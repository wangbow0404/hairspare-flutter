import 'package:flutter/material.dart';

import '../../utils/icon_mapper.dart';
import 'challenge_immersive_hub_actions.dart';

class ChallengeLoadingScaffold extends StatelessWidget {
  const ChallengeLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            top: top + 4,
            left: 4,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: IconMapper.icon('chevronleft', size: 22, color: Colors.white) ??
                      const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Text(
                    '챌린지참여',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...buildChallengeImmersiveHubActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeEmptyScaffold extends StatelessWidget {
  const ChallengeEmptyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
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
            top: top + 4,
            left: 4,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: IconMapper.icon('chevronleft', size: 22, color: Colors.white) ??
                      const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Text(
                    '챌린지참여',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...buildChallengeImmersiveHubActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
