import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/challenge_feed.dart';
import '../../providers/auth_provider.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/challenge_view_model.dart';

/// 하단 좌측: 크리에이터·제목·태그·음악을 **단일 그라데이션 패널**로 표시.
class ChallengeBottomMetadata extends StatelessWidget {
  const ChallengeBottomMetadata({
    super.key,
    required this.onOpenCreatorProfile,
    this.onLaunchUrl,
    this.immersive = false,
    this.overlayBottomInset = 80,
  });

  final void Function(String? creatorId) onOpenCreatorProfile;
  final Future<void> Function(String url)? onLaunchUrl;
  final bool immersive;
  final double overlayBottomInset;

  static const _textShadow = <Shadow>[
    Shadow(color: Color(0xB3000000), blurRadius: 6, offset: Offset(0, 1.5)),
  ];

  static BoxDecoration _overlayGradient({required bool immersive}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: immersive
            ? [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.28),
                Colors.black.withValues(alpha: 0.62),
              ]
            : [
                Colors.transparent,
                const Color(0x12000000),
                const Color(0x2E000000),
                Colors.black.withValues(alpha: 0.58),
              ],
        stops: immersive
            ? const [0.0, 0.2, 0.55, 1.0]
            : const [0.0, 0.5, 0.8, 1.0],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final c = vm.displayedChallenges[vm.currentIndex];
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final hasProductTag =
        c.taggedType == 'product' && c.productUrl != null;
    final hasEducationTag =
        c.taggedType == 'education' && c.educationUrl != null;
    final hasTaggedLink = immersive &&
        onLaunchUrl != null &&
        (hasProductTag || hasEducationTag);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTaggedLink) ...[
          _TaggedLinkChip(
            challenge: c,
            onLaunchUrl: onLaunchUrl!,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onOpenCreatorProfile(c.creatorId),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              c.creatorAvatar ?? '👤',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '@${c.creatorName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              shadows: _textShadow,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final user = context.read<AuthProvider>().currentUser;
                context.read<ChallengeViewModel>().handleSubscribe(user);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: c.isSubscribed
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.52),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  c.isSubscribed ? '구독 중' : '구독',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    shadows: _textShadow,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          c.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
            shadows: _textShadow,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          c.description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 12,
            height: 1.3,
            shadows: _textShadow,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (c.tags != null && c.tags!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            c.tags!.take(3).map((tag) => '#$tag').join(' '),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: _textShadow,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (immersive && (c.musicName != null || c.musicArtist != null)) ...[
          const SizedBox(height: 10),
          _ChallengeMusicLine(
            musicName: c.musicName,
            musicArtist: c.musicArtist,
          ),
        ],
      ],
    );

    if (immersive) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: DecoratedBox(
          decoration: _overlayGradient(immersive: true),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 32, 86, bottomPad + 12),
            child: content,
          ),
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: overlayBottomInset,
      child: DecoratedBox(
        decoration: _overlayGradient(immersive: false),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: content,
        ),
      ),
    );
  }
}

class _TaggedLinkChip extends StatelessWidget {
  const _TaggedLinkChip({
    required this.challenge,
    required this.onLaunchUrl,
  });

  final Challenge challenge;
  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    final hasProduct =
        challenge.taggedType == 'product' && challenge.productUrl != null;
    final label = hasProduct ? '제품 (1)' : '교육 (1)';
    final url = hasProduct ? challenge.productUrl! : challenge.educationUrl!;

    return GestureDetector(
      onTap: () => onLaunchUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconMapper.icon('shoppingbag', size: 14, color: Colors.white) ??
                Icon(
                  hasProduct
                      ? Icons.shopping_bag_outlined
                      : Icons.menu_book_outlined,
                  size: 14,
                  color: Colors.white,
                ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: ChallengeBottomMetadata._textShadow,
              ),
            ),
            const SizedBox(width: 4),
            IconMapper.icon('chevronright', size: 12, color: Colors.white70) ??
                const Icon(Icons.chevron_right, size: 14, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _ChallengeMusicLine extends StatefulWidget {
  const _ChallengeMusicLine({
    required this.musicName,
    required this.musicArtist,
  });

  final String? musicName;
  final String? musicArtist;

  @override
  State<_ChallengeMusicLine> createState() => _ChallengeMusicLineState();
}

class _ChallengeMusicLineState extends State<_ChallengeMusicLine>
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
    final label = widget.musicName != null && widget.musicArtist != null
        ? '${widget.musicName} - ${widget.musicArtist}'
        : widget.musicName ?? widget.musicArtist ?? '';

    const style = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      shadows: ChallengeBottomMetadata._textShadow,
    );

    return Row(
      children: [
        Icon(
          Icons.music_note_rounded,
          size: 16,
          color: Colors.white.withValues(alpha: 0.9),
          shadows: ChallengeBottomMetadata._textShadow,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 20,
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
                      final offset = -(_controller.value * loopW) % loopW;
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
