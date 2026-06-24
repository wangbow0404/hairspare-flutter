import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/utils/spare_search_hints.dart';

void main() {
  test('format wraps keyword in Korean hint pattern', () {
    expect(SpareSearchHints.format('인기공고'), "'인기공고' 검색");
  });

  test('randomHint avoids immediate repeat when exclude is set', () {
    final random = Random(42);
    const exclude = '인기공고';
    for (var i = 0; i < 20; i++) {
      final hint = SpareSearchHints.randomHint(random, excludeKeyword: exclude);
      expect(hint, isNot(SpareSearchHints.format(exclude)));
    }
  });

  test('keywordFromHint parses formatted hint', () {
    expect(
      SpareSearchHints.keywordFromHint("'챌린지' 검색"),
      '챌린지',
    );
  });

  test('suggestedTabIndex maps keyword to category chip', () {
    expect(SpareSearchHints.suggestedTabIndex('챌린지'), 4);
    expect(SpareSearchHints.suggestedTabIndex('교육'), 2);
    expect(SpareSearchHints.suggestedTabIndex('인기공고'), 1);
    expect(SpareSearchHints.suggestedTabIndex('에너지구매'), 0);
  });
}
