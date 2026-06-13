import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/utils/count_format.dart';

void main() {
  group('CountFormat.compact', () {
    test('under 1000', () {
      expect(CountFormat.compact(796), '796');
      expect(CountFormat.compact(29), '29');
    });

    test('thousands with k', () {
      expect(CountFormat.compact(1599), '1.6k');
      expect(CountFormat.compact(27300), '27.3k');
      expect(CountFormat.compact(1200), '1.2k');
    });

    test('millions with m', () {
      expect(CountFormat.compact(1500000), '1.5m');
      expect(CountFormat.compact(12000000), '12m');
    });
  });
}
