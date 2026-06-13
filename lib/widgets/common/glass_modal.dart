import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

BoxDecoration _glassSurfaceDecoration({
  required BorderRadius borderRadius,
  List<BoxShadow>? boxShadow,
}) {
  return BoxDecoration(
    borderRadius: borderRadius,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.82),
        Colors.white.withValues(alpha: 0.64),
      ],
    ),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.92),
      width: 1.2,
    ),
    boxShadow: boxShadow ??
        [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
  );
}

/// 글래스모피즘 모달 오버레이 — 배경 흐림 + 반투명 배리어.
///
/// [child]에는 보통 [GlassModalPanel]을 넣어 재사용합니다.
class GlassModal extends StatelessWidget {
  const GlassModal({
    super.key,
    required this.child,
    this.onDismiss,
    this.dismissible = true,
    this.isLocked = false,
    this.barrierOpacity = 0.42,
    this.backdropBlurSigma = 12,
  });

  final Widget child;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final bool isLocked;
  final double barrierOpacity;
  final double backdropBlurSigma;

  @override
  Widget build(BuildContext context) {
    final canDismiss = dismissible && !isLocked && onDismiss != null;

    return Material(
      color: Colors.black.withValues(alpha: barrierOpacity),
      child: GestureDetector(
        onTap: canDismiss ? onDismiss : null,
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: backdropBlurSigma,
            sigmaY: backdropBlurSigma,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 글래스모피즘 패널 — 반투명 그라데이션·미세 흰색 테두리·소프트 그림자.
class GlassModalPanel extends StatelessWidget {
  const GlassModalPanel({
    super.key,
    required this.child,
    this.width = 320,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 20),
    this.borderRadius = 26,
  });

  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          padding: padding,
          decoration: _glassSurfaceDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 글래스 모달 공통 헤더 — 제목 + 닫기.
class GlassModalHeader extends StatelessWidget {
  const GlassModalHeader({
    super.key,
    required this.title,
    this.onClose,
    this.isCloseEnabled = true,
  });

  final String title;
  final VoidCallback? onClose;
  final bool isCloseEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.28,
              letterSpacing: -0.35,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (onClose != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: isCloseEnabled ? onClose : null,
            icon: Icon(
              Icons.close_rounded,
              size: 22,
              color: AppTheme.textTertiary.withValues(alpha: 0.85),
            ),
          ),
      ],
    );
  }
}

/// 글래스 모달 중앙 히어로 — 이모지 또는 아이콘.
class GlassModalHeroIcon extends StatelessWidget {
  const GlassModalHeroIcon({
    super.key,
    this.emoji,
    this.icon,
    this.size = 88,
    this.gradientColors = const [
      Color(0xFFEDE9FE),
      Color(0xFFF5F3FF),
    ],
  }) : assert(emoji != null || icon != null);

  final String? emoji;
  final IconData? icon;
  final double size;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            gradientColors.first.withValues(alpha: 0.92),
            gradientColors.last.withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: emoji != null
          ? Text(
              emoji!,
              style: TextStyle(
                fontSize: size * 0.52,
                height: 1,
                shadows: const [
                  Shadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            )
          : Icon(
              icon,
              size: size * 0.44,
              color: const Color(0xFF7C3AED),
            ),
    );
  }
}

/// 바텀 시트용 글래스 셸 — [showModalBottomSheet] + transparent 배경과 함께 사용.
class GlassModalBottomSheet extends StatelessWidget {
  const GlassModalBottomSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.88,
  });

  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
            ),
            decoration: _glassSurfaceDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A111827),
                  blurRadius: 28,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 바텀 시트 상단 드래그 핸들.
class GlassModalDragHandle extends StatelessWidget {
  const GlassModalDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: AppTheme.borderGray.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
