import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 모델검색 진입 화면 — "조건으로 찾기"(스와이프)와 "날짜로 찾기" 중 선택.
/// 타로카드처럼 좌우로 살짝 기울어진 카드 2장을 배치해 고르는 느낌을 준다.
class ModelMatchEntryScreen extends StatelessWidget {
  const ModelMatchEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '모델검색'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '어떻게 찾아볼까요?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _TarotCard(
                        icon: Icons.favorite,
                        gradient: AppTheme.stitchHeroGradient,
                        title: '조건으로 찾기',
                        subtitle: '원하는 조건을 설정하고 스와이프로 모델을 만나보세요',
                        tiltTurns: -0.014,
                        onTap: () =>
                            ShellNavigation.push(context, 'model_match/filter'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing4),
                    Expanded(
                      child: _TarotCard(
                        icon: Icons.calendar_month_outlined,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.stitchPrimaryContainer,
                          ],
                        ),
                        title: '날짜로 찾기',
                        subtitle: '원하는 날짜에 가능한 모델을 바로 찾아보세요',
                        tiltTurns: 0.014,
                        onTap: () =>
                            ShellNavigation.push(context, 'model_match/by_date'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotCard extends StatefulWidget {
  const _TarotCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.tiltTurns,
    required this.onTap,
  });

  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final double tiltTurns;
  final VoidCallback onTap;

  @override
  State<_TarotCard> createState() => _TarotCardState();
}

class _TarotCardState extends State<_TarotCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedRotation(
              turns: _pressed ? 0 : widget.tiltTurns,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AspectRatio(
                aspectRatio: 1 / 1.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacing4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing3),
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing1),
          child: Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
