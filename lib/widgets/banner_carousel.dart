import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  final Function(int)? onBannerTap;
  /// 배너 높이. null이면 screenWidth/1.6. 컴팩트 카드형은 220 권장.
  final double? height;

  const BannerCarousel({
    super.key,
    required this.bannerImages,
    this.onBannerTap,
    this.height,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _isBannerScrolling = false; // 수동 스크롤 중인지 여부
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // 자동 스크롤 시작
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.bannerImages.isEmpty) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isBannerScrolling && mounted) {
        final nextPage = (_currentPage + 1) % widget.bannerImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // 자동 스크롤 일시 중지 (2초 후 재개)
  void _pauseAutoScroll() {
    setState(() {
      _isBannerScrolling = true;
    });
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isBannerScrolling = false;
        });
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // 수동 스크롤 감지 (인디케이터 탭이 아닌 경우)
    _pauseAutoScroll();
  }

  void _onPageIndicatorTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // 인디케이터 탭도 수동 스크롤로 간주
    _pauseAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerImages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Compact 카드형: height=220 권장. 이미지가 카드 영역을 꽉 채우지 않으면
    // 원본 asset의 상하/좌우 흰 여백을 크롭해 사용할 것.
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final bannerHeight = widget.height ?? (screenWidth / 1.6);

    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Stack(
        children: [
          // 배너 페이지뷰
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 스크롤 시작 시 수동 스크롤 감지
              if (notification is ScrollStartNotification) {
                _pauseAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              itemCount: widget.bannerImages.length,
            itemBuilder: (context, index) {
              final imagePath = widget.bannerImages[index];
              final isAsset = imagePath.startsWith('assets/');
              
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onBannerTap?.call(index),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  decoration: isAsset
                      ? null
                      : BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                  child: isAsset
                      ? Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.borderGray300,
                            );
                          },
                        )
                      : null,
                ),
              );
            },
            ),
          ),

          // 페이지 인디케이터 (하단 여백 최소화)
          Positioned(
            bottom: AppTheme.spacing2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.bannerImages.length,
                (index) => GestureDetector(
                  onTap: () => _onPageIndicatorTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing1), // gap-2
                    height: 8, // h-2
                    width: _currentPage == index ? 24 : 8, // 선택: w-6, 미선택: w-2
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryBlue // bg-blue-600
                          : AppTheme.borderGray300, // bg-gray-300
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull), // rounded-full
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
