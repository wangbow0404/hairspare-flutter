/// 공고 근무일(날짜 문자열) 판별.
abstract final class JobWorkDateUtils {
  static DateTime? parseWorkDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  /// 근무일이 오늘보다 이전이면 true (날짜만 비교).
  static bool isWorkDatePast(String dateStr, {DateTime? now}) {
    final work = parseWorkDate(dateStr);
    if (work == null) return false;
    final today = now ?? DateTime.now();
    final workDay = DateTime(work.year, work.month, work.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return workDay.isBefore(todayDay);
  }
}
