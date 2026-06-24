import 'package:flutter/material.dart';

/// push 전환 애니메이션 후 본문 렌더 — ANR·프레임 드랍 완화.
mixin DeferredRouteBodyMixin<T extends StatefulWidget> on State<T> {
  bool bodyReady = false;

  @override
  void initState() {
    super.initState();
    scheduleDeferredBodyReveal();
  }

  void scheduleDeferredBodyReveal({Duration fallbackDelay = const Duration(milliseconds: 350)}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || bodyReady) return;
      final animation = ModalRoute.of(context)?.animation;
      void reveal() {
        if (!mounted || bodyReady) return;
        setState(() => bodyReady = true);
      }

      if (animation != null && !animation.isCompleted) {
        late AnimationStatusListener listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            animation.removeStatusListener(listener);
            Future<void>.delayed(const Duration(milliseconds: 120), reveal);
          }
        };
        animation.addStatusListener(listener);
      } else {
        Future<void>.delayed(fallbackDelay, reveal);
      }
    });
  }

  Widget deferredBody({
    required Widget loading,
    required Widget Function(BuildContext context) builder,
  }) {
    if (!bodyReady) return loading;
    return builder(context);
  }
}

/// 버튼 탭 직후 무거운 Provider 호출을 다음 microtask로 미룸.
void deferAfterTap(VoidCallback action) {
  Future<void>.microtask(action);
}
