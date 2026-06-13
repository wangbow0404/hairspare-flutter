/// 조회수·좋아요·구독자 등 큰 숫자 표기 (1.6k, 27.3k, 1.2m).
abstract final class CountFormat {
  CountFormat._();

  static String compact(int n) {
    if (n < 0) return '0';
    if (n < 1000) return '$n';
    if (n < 1000000) {
      return '${_formatUnit(n / 1000)}k';
    }
    return '${_formatUnit(n / 1000000)}m';
  }

  static String _formatUnit(double value) {
    if (value >= 100) {
      final rounded = value.round();
      return '$rounded';
    }
    if (value >= 10) {
      return _trimTrailingZero(value.toStringAsFixed(1));
    }
    return _trimTrailingZero(value.toStringAsFixed(1));
  }

  static String _trimTrailingZero(String s) {
    if (s.endsWith('.0')) {
      return s.substring(0, s.length - 2);
    }
    return s;
  }
}
