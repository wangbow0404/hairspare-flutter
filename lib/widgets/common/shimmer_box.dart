import 'package:flutter/material.dart';

/// 로딩 중임을 알려주는 shimmer(반짝임) 효과가 있는 회색 박스.
/// 별도 패키지 없이 그라데이션을 좌우로 쓸어가며 구현한다.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.height, this.borderRadius = 8});

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDEF),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1 + 3 * t, 0),
              end: Alignment(3 * t, 0),
              colors: const [
                Color(0xFFEDEDEF),
                Color(0xFFF8F8F9),
                Color(0xFFEDEDEF),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(rect);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDEF),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// 공고 카드 로딩 스켈레톤 — 실제 카드(썸네일+텍스트 줄)와 비슷한 모양.
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 80, height: 80, borderRadius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 90, height: 20, borderRadius: 999),
                const SizedBox(height: 10),
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.35,
                  height: 14,
                ),
                const SizedBox(height: 8),
                const ShimmerBox(width: 140, height: 12),
                const SizedBox(height: 8),
                const ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 공고 상세 로딩 스켈레톤 — 히어로 이미지 + 제목 + 정보카드 모양.
class JobDetailSkeleton extends StatelessWidget {
  const JobDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ShimmerBox(height: 288, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.55,
                  height: 22,
                ),
                const SizedBox(height: 10),
                const ShimmerBox(width: 160, height: 14),
                const SizedBox(height: 20),
                _SkeletonCard(
                  child: Column(
                    children: const [
                      ShimmerBox(height: 16),
                      SizedBox(height: 16),
                      ShimmerBox(height: 16),
                      SizedBox(height: 16),
                      ShimmerBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SkeletonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 100, height: 15),
                      SizedBox(height: 10),
                      ShimmerBox(height: 12),
                      SizedBox(height: 8),
                      ShimmerBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 채팅 목록 로딩 스켈레톤 — 아바타 원 + 이름/미리보기 줄 모양.
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48, borderRadius: 999),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    height: 15,
                  ),
                  const SizedBox(height: 8),
                  ShimmerBox(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    height: 13,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
