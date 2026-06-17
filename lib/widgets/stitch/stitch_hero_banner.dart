import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stitch 스타일 히어로 배너 — 이미지 캐러셀 + 페이지 인디케이터.
/// 배너 이미지에 문구가 포함되어 있으므로 [imageOnly] 기본값은 true.
class StitchHeroBanner extends StatefulWidget {
  const StitchHeroBanner({
    super.key,
    required this.onCtaTap,
    this.height = 240,
    this.variant = StitchHeroVariant.spare,
    this.imageOnly = true,
  });

  final ValueChanged<int> onCtaTap;
  final double height;
  final StitchHeroVariant variant;

  /// true면 이미지만 표시(텍스트·그라데이션 오버레이 없음).
  final bool imageOnly;

  @override
  State<StitchHeroBanner> createState() => _StitchHeroBannerState();
}

class _StitchHeroBannerState extends State<StitchHeroBanner> {
  static const List<_HeroSlide> _spareSlides = [
    _HeroSlide(imageAsset: 'assets/images/banners/banner1.jpg'),
    _HeroSlide(imageAsset: 'assets/images/banners/banner3.jpg'),
    _HeroSlide(imageAsset: 'assets/images/banners/banner4.jpg'),
  ];

  static const List<_HeroSlide> _shopSlides = [
    _HeroSlide(imageAsset: 'assets/images/banners/banner2.jpg'),
    _HeroSlide(imageAsset: 'assets/images/banners/banner2.jpg'),
    _HeroSlide(imageAsset: 'assets/images/banners/banner3.jpg'),
  ];

  List<_HeroSlide> get _slides =>
      widget.variant == StitchHeroVariant.shop ? _shopSlides : _spareSlides;

  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _page = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              if (widget.imageOnly) {
                return _ImageOnlySlide(
                  imageAsset: slide.imageAsset,
                  onTap: () => widget.onCtaTap(index),
                );
              }
              return _GradientFallbackSlide(
                onTap: () => widget.onCtaTap(index),
              );
            },
          ),
          if (widget.imageOnly)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppTheme.spacing3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.stitchPrimary
                          : AppTheme.borderGray300,
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

class _ImageOnlySlide extends StatelessWidget {
  const _ImageOnlySlide({
    required this.imageAsset,
    required this.onTap,
  });

  final String imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          imageAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.stitchHeroGradient,
            ),
          ),
        ),
      ),
    );
  }
}

/// 이미지 로드 실패 시 fallback.
class _GradientFallbackSlide extends StatelessWidget {
  const _GradientFallbackSlide({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTheme.stitchHeroGradient,
          ),
        ),
      ),
    );
  }
}

class _HeroSlide {
  const _HeroSlide({required this.imageAsset});

  final String imageAsset;
}

enum StitchHeroVariant { spare, shop }
