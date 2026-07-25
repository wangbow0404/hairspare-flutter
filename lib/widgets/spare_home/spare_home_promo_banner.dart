import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

class _PromoSlide {
  const _PromoSlide({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
}

const _slides = <_PromoSlide>[
  _PromoSlide(
    icon: Icons.verified_user_outlined,
    accent: HairSpareColors.brandPrimary,
    title: '노쇼 걱정 없는 예약금 근무 매칭',
    subtitle: '지원 시 소액 예약금, 근무 완료하면 전액 환급',
  ),
  _PromoSlide(
    icon: Icons.bolt_outlined,
    accent: HairSpareColors.statusMatching,
    title: '급한 자리도 실시간으로 빠르게',
    subtitle: '오늘 당장 필요한 공고만 모아보기',
  ),
  _PromoSlide(
    icon: Icons.workspace_premium_outlined,
    accent: HairSpareColors.statusEducation,
    title: '완료 건수로 검증된 매장만',
    subtitle: '근무 이력이 쌓인 신뢰할 수 있는 매장 위주',
  ),
];

/// a안 홈 프로모 배너 — 캐러셀(닫기 가능).
class SpareHomePromoBanner extends StatefulWidget {
  const SpareHomePromoBanner({super.key});

  @override
  State<SpareHomePromoBanner> createState() => _SpareHomePromoBannerState();
}

class _SpareHomePromoBannerState extends State<SpareHomePromoBanner> {
  bool _visible = true;
  int _page = 0;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        0,
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 76,
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _PromoSlideCard(slide: _slides[i]),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => setState(() => _visible = false),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: HairSpareColors.textSecondary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: active ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active
                        ? HairSpareColors.brandPrimary
                        : HairSpareColors.brandPrimary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoSlideCard extends StatelessWidget {
  const _PromoSlideCard({required this.slide});

  final _PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: slide.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing3,
          AppTheme.spacing6,
          AppTheme.spacing4,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: slide.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 20, color: slide.accent),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: slide.accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slide.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: HairSpareColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
