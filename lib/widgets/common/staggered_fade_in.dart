import 'package:flutter/material.dart';

/// 리스트/섹션이 순서대로 살짝 아래→위로 페이드인하는 진입 애니메이션.
/// 홈 화면처럼 섹션이 여러 개 쌓이는 화면에서 [index]를 늘려가며 감싸면
/// 화면이 한꺼번에 툭 뜨지 않고 순서대로 나타나는 느낌을 준다.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.stepDelay = const Duration(milliseconds: 45),
    this.maxDelay = const Duration(milliseconds: 400),
    this.duration = const Duration(milliseconds: 280),
  });

  final int index;
  final Widget child;
  final Duration stepDelay;
  final Duration maxDelay;
  final Duration duration;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (reduceMotion) {
      _controller.value = 1.0;
      return;
    }

    final delayMs = (widget.stepDelay.inMilliseconds * widget.index).clamp(
      0,
      widget.maxDelay.inMilliseconds,
    );
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(
          Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero),
        ),
        child: widget.child,
      ),
    );
  }
}
