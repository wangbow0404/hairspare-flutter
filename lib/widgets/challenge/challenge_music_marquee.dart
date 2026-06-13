import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/challenge_view_model.dart';

/// 하단 좌측 흰색 마퀴 텍스트 (음악 - 아티스트).
class ChallengeMusicMarquee extends StatefulWidget {
  const ChallengeMusicMarquee({super.key});

  @override
  State<ChallengeMusicMarquee> createState() => _ChallengeMusicMarqueeState();
}

class _ChallengeMusicMarqueeState extends State<ChallengeMusicMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final c = vm.displayedChallenges[vm.currentIndex];
    if (c.musicName == null && c.musicArtist == null) {
      return const SizedBox.shrink();
    }

    final label = c.musicName != null && c.musicArtist != null
        ? '${c.musicName} - ${c.musicArtist}'
        : c.musicName ?? c.musicArtist ?? '';

    const style = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      shadows: [
        Shadow(color: Color(0xB3000000), blurRadius: 6, offset: Offset(0, 1.2)),
      ],
    );

    final bottom = MediaQuery.paddingOf(context).bottom + 6;

    return Positioned(
      left: 12,
      right: 12,
      bottom: bottom,
      height: 24,
      child: ClipRect(
        child: LayoutBuilder(
            builder: (context, constraints) {
              final trackW = constraints.maxWidth;
              final tp = TextPainter(
                text: TextSpan(text: label, style: style),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: double.infinity);
              final textWidth = tp.width;
              if (textWidth <= trackW || textWidth <= 0) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: style),
                );
              }
              const gap = 48.0;
              final loopW = textWidth + gap;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final offset = -(t * loopW) % loopW;
                  return OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(offset, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: style),
                          const SizedBox(width: gap),
                          Text(label, style: style),
                          const SizedBox(width: gap),
                          Text(label, style: style),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ),
    );
  }
}
