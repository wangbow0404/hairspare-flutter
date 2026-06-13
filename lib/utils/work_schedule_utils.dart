import 'package:flutter/material.dart';

import '../models/job.dart';

/// 근무 일·시간 검증·표시.
abstract final class WorkScheduleUtils {
  static bool isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int timeOfDayToMinutes(TimeOfDay time) =>
      time.hour * 60 + time.minute;

  /// [workDate]가 오늘이면 [startTime]이 현재 시각보다 이전인지.
  static bool isStartTimeInPast({
    required DateTime workDate,
    required TimeOfDay startTime,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    if (!isSameCalendarDay(workDate, reference)) return false;
    final startMinutes = timeOfDayToMinutes(startTime);
    final nowMinutes = reference.hour * 60 + reference.minute;
    return startMinutes < nowMinutes;
  }

  /// 시작 시간 피커에서만 노출하는 상세 안내.
  static const String pastStartTimeUserMessage =
      '시작 시간이 현재 시각보다 이전입니다.\n'
      '오늘 공고는 현재 시간 이후로 선택해 주세요.';

  static const String pastStartAfterDateChangeMessage =
      '오늘 날짜는 현재 시간 이후로 시작 시간을 다시 선택해 주세요.';

  static const String endBeforeStartUserMessage =
      '종료 시간은 시작 시간보다 이후여야 합니다.';

  static String? pastStartTimeMessage({
    required DateTime? workDate,
    required TimeOfDay? startTime,
    DateTime? now,
  }) {
    if (workDate == null || startTime == null) return null;
    if (!isStartTimeInPast(workDate: workDate, startTime: startTime, now: now)) {
      return null;
    }
    return pastStartTimeUserMessage;
  }

  static int? timeToMinutes(String? hm) {
    if (hm == null || hm.isEmpty) return null;
    final parts = hm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  /// 같은 날 기준 종료 시각이 시작보다 이전/동일이면 true (익일 퇴근 가능성).
  static bool isEndBeforeOrEqualStart(String start, String end) {
    final startM = timeToMinutes(start);
    final endM = timeToMinutes(end);
    if (startM == null || endM == null) return false;
    return endM <= startM;
  }

  static String? endTimeBeforeStartMessage({
    required String? startTime,
    required String? endTime,
  }) {
    if (startTime == null || startTime.isEmpty) return null;
    if (endTime == null || endTime.isEmpty) return null;
    if (!isEndBeforeOrEqualStart(startTime, endTime)) return null;
    return '종료 시간은 시작 시간보다 이후여야 합니다.';
  }

  static String formatJobTimeRange(Job job) {
    final start = job.time;
    final end = job.endTime;
    if (start.isEmpty) return '-';
    if (end == null || end.isEmpty) return start;
    if (isEndBeforeOrEqualStart(start, end)) {
      return '$start ~ $end (익일 퇴근)';
    }
    return '$start ~ $end';
  }
}
