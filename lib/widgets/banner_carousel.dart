import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  final Function(int)? onBannerTap;

  const BannerCarousel({
    super.key,
    required this.bannerImages,
    this.onBannerTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
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

    // 화면 전체 너비를 가져옴
    final screenWidth = MediaQuery.of(context).size.width;
    // 배너 비율: 일반적으로 16:9 또는 21:9, 여기서는 약 2.5:1 비율 사용
    // 높이를 화면 너비에 맞춰 계산 (더 넓은 배너를 위해 비율 조정)
    final bannerHeight = screenWidth / 2.2; // 약 2.2:1 비율로 높이 계산

    return SizedBox(
      width: double.infinity, // 전체 너비 사용
      height: bannerHeight, // 계산된 높이 사용
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
              itemCount: widget.bannerImages.length,
            itemBuilder: (context, index) {
              final imagePath = widget.bannerImages[index];
              final isAsset = imagePath.startsWith('assets/');
              
              return GestureDetector(
                onTap: () => widget.onBannerTap?.call(index),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: isAsset
                        ? null // Asset 이미지는 Image.asset 위젯으로 처리
                        : DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover, // cover로 변경하여 전체 영역 채움
                            alignment: Alignment.center,
                            onError: (exception, stackTrace) {
                              // 이미지 로드 실패 시 기본 배경색
                            },
                          ),
                    gradient: isAsset
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.3),
                              AppTheme.primaryPurple.withOpacity(0.3),
                            ],
                          )
                        : null,
                  ),
                  child: isAsset
                      ? Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover, // cover로 변경하여 전체 영역 채움
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            // Asset 이미지 로드 실패 시 그라데이션 배경만 표시
                            return Container();
                          },
                        )
                      : null,
                ),
              );
            },
            ),
          ),

          // 페이지 인디케이터
          Positioned(
            bottom: AppTheme.spacing4, // bottom-4
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
                    margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing1), // gap-2
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
    );
  }
}
