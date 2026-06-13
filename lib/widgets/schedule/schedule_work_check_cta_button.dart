import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum ScheduleWorkCheckCtaVariant { ready, waiting }

/// 근무체크하기 CTA — 종료 후는 그라데이션, 그 전은 소프트 아웃라인.
class ScheduleWorkCheckCtaButton extends StatelessWidget {
  const ScheduleWorkCheckCtaButton({
    super.key,
    required this.onPressed,
    this.variant = ScheduleWorkCheckCtaVariant.ready,
  });

  final VoidCallback onPressed;
  final ScheduleWorkCheckCtaVariant variant;

  @override
  Widget build(BuildContext context) {
    final ready = variant == ScheduleWorkCheckCtaVariant.ready;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: ready ? Colors.white24 : AppTheme.primaryPurple.withValues(alpha: 0.12),
        highlightColor: ready ? Colors.white10 : AppTheme.primaryPurple.withValues(alpha: 0.06),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: ready
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                  )
                : null,
            color: ready ? null : Colors.white.withValues(alpha: 0.72),
            border: ready
                ? null
                : Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
            boxShadow: ready
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ready ? Icons.verified_outlined : Icons.schedule_outlined,
                  size: 17,
                  color: ready ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  '근무체크하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: ready ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ready
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
