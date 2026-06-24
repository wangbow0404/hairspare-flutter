/// 스페어·샵 홈 가로 스크롤 카드 공통 레이아웃 수치.
abstract final class HomeLayoutMetrics {
  static const double horizontalCardWidth = 288;
  static const double horizontalCardHeroHeight = 128;

  /// 썸네일 없는 [StitchCompactJobCard] (급구 가로 캐러셀) — 본문+패딩+테두리 포함.
  static const double compactCarouselHeight = 212;

  /// 썸네일 있는 [StitchCompactJobCard] 가로 캐러셀.
  static double get thumbnailCarouselHeight {
    const bodyEstimate = 118.0;
    const verticalPadding = 32.0;
    return horizontalCardWidth * 9 / 16 + verticalPadding + bodyEstimate;
  }

  static const double horizontalCarouselHeight = 280;
}
