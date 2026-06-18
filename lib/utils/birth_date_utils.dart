/// 생년월일·나이 계산 유틸.
abstract final class BirthDateUtils {
  static int ageFromBirthDate(DateTime birthDate, {DateTime? reference}) {
    final today = reference ?? DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static bool isValidSignupBirthDate(DateTime birthDate, {DateTime? reference}) {
    final age = ageFromBirthDate(birthDate, reference: reference);
    return age >= 14 && age <= 80;
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime? composeDate({
    required int? year,
    required int? month,
    required int? day,
  }) {
    if (year == null || month == null || day == null) return null;
    if (day > daysInMonth(year, month)) return null;
    return DateTime(year, month, day);
  }
}
