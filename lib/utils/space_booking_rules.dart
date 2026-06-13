/// 공간 예약 — 샵별 최소 이용 시간(minHours) 검증.
abstract final class SpaceBookingRules {
  SpaceBookingRules._();

  /// API·모델 기본값 보정 (0 이하 → 1시간).
  static int normalizeMinHours(int minHours) =>
      minHours < 1 ? 1 : minHours;

  static bool meetsMinHours({
    required int selectedHours,
    required int minHours,
  }) {
    return selectedHours >= normalizeMinHours(minHours);
  }

  /// minHours=1이면 1시간 예약 가능, minHours=2이면 1시간은 false.
  static String belowMinHoursMessage(int minHours) {
    final min = normalizeMinHours(minHours);
    if (min <= 1) {
      return '예약할 시간대를 선택해 주세요.';
    }
    return '이 공간은 최소 $min시간부터 예약할 수 있어요.';
  }
}
