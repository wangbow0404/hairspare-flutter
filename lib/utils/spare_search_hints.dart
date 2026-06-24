import 'dart:math';

/// 스페어 통합 검색창 로테이션 힌트 — 자주 찾을 만한 키워드.
class SpareSearchHints {
  SpareSearchHints._();

  static const List<String> keywords = [
    '인기공고',
    '급구',
    '신규공고',
    '챌린지',
    '에너지구매',
    '교육',
    '공간대여',
    '염색',
    '펌',
    '컷트',
    '강남',
    '홍대',
    '스케줄',
    '자격증',
    '모델매칭',
    '찜한 공고',
    '메시지',
    '알림',
  ];

  static const List<String> quickPickKeywords = [
    '인기공고',
    '급구',
    '신규공고',
    '챌린지',
    '에너지구매',
    '교육',
    '공간대여',
    '염색',
    '강남',
    '스케줄',
  ];

  static String format(String keyword) => "'$keyword' 검색";

  static String randomHint(Random random, {String? excludeKeyword}) {
    final pool = excludeKeyword == null
        ? keywords
        : keywords.where((k) => k != excludeKeyword).toList(growable: false);
    if (pool.isEmpty) {
      return format(keywords.first);
    }
    return format(pool[random.nextInt(pool.length)]);
  }

  static String? keywordFromHint(String hint) {
    final match = RegExp(r"'([^']+)' 검색").firstMatch(hint);
    return match?.group(1);
  }

  /// 추천 키워드 탭 시 카테고리 칩과 맞추기 (0=전체).
  static int suggestedTabIndex(String keyword) {
    switch (keyword) {
      case '교육':
      case '자격증':
        return 2;
      case '공간대여':
        return 3;
      case '챌린지':
        return 4;
      case '인기공고':
      case '급구':
      case '신규공고':
      case '염색':
      case '펌':
      case '컷트':
      case '강남':
      case '홍대':
      case '모델매칭':
      case '찜한 공고':
        return 1;
      default:
        return 0;
    }
  }
}
