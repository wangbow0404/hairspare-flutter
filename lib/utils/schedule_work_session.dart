import 'package:intl/intl.dart';

import '../models/schedule.dart';

/// 스케줄의 근무 시작·종료 시각 대비 현재 시점 구간.
enum ScheduleWorkPhase {
  /// `now < start`
  beforeStart,

  /// `start <= now < end`
  inProgress,

  /// `now >= end`
  afterEnd,
}

/// [Schedule.date], [Schedule.startTime], [Schedule.endTime] 기반 근무 구간 계산.
abstract final class ScheduleWorkSession {
  ScheduleWorkSession._();

  /// [endTime]이 없으면 시작 시각 기준 +4시간(기존 근무체크 화면과 동일한 가정).
  static DateTime startDateTime(Schedule schedule) {
    final d = DateTime.tryParse(schedule.date);
    if (d == null) {
      return DateTime.now();
    }
    final (h, m) = _parseClock(schedule.startTime);
    return DateTime(d.year, d.month, d.day, h, m);
  }

  static DateTime endDateTime(Schedule schedule) {
    final d = DateTime.tryParse(schedule.date);
    if (d == null) {
      return DateTime.now();
    }
    final endClock = schedule.endTime?.trim().isNotEmpty == true
        ? schedule.endTime!
        : _addHoursToClock(schedule.startTime, 4);
    final (h, m) = _parseClock(endClock);
    return DateTime(d.year, d.month, d.day, h, m);
  }

  static ScheduleWorkPhase phase(Schedule schedule, DateTime now) {
    final start = startDateTime(schedule);
    final end = endDateTime(schedule);
    if (now.isBefore(start)) return ScheduleWorkPhase.beforeStart;
    if (now.isBefore(end)) return ScheduleWorkPhase.inProgress;
    return ScheduleWorkPhase.afterEnd;
  }

  /// 카드 상단 태그 문구 (완료 체크 여부 반영).
  static String statusTagLabel(Schedule schedule, DateTime now) {
    if (schedule.status == 'completed' || schedule.checkInTime != null) {
      return '완료';
    }
    switch (phase(schedule, now)) {
      case ScheduleWorkPhase.beforeStart:
        return '근무 예정';
      case ScheduleWorkPhase.inProgress:
        return '근무 중';
      case ScheduleWorkPhase.afterEnd:
        return '체크 가능';
    }
  }

  static String formatHm(DateTime t) => DateFormat('HH:mm').format(t);

  /// 근무체크 탭이 막혀 있을 때 표시할 안내. [afterEnd]이면 `null`(모달 오픈).
  static String? workCheckBlockedMessage(Schedule schedule, DateTime now) {
    if (schedule.status == 'completed' || schedule.checkInTime != null) {
      return '이미 근무 체크가 완료된 일정입니다.';
    }
    switch (phase(schedule, now)) {
      case ScheduleWorkPhase.beforeStart:
        return '아직 근무 전입니다.';
      case ScheduleWorkPhase.inProgress:
        return '아직 근무 중입니다.';
      case ScheduleWorkPhase.afterEnd:
        return null;
    }
  }

  /// CTA 시각 스타일 — [afterEnd]만 강조 그라데이션.
  static bool isWorkCheckReady(Schedule schedule, DateTime now) {
    if (schedule.status == 'completed' || schedule.checkInTime != null) {
      return false;
    }
    return phase(schedule, now) == ScheduleWorkPhase.afterEnd;
  }

  /// 샵 정산 가능 여부 — 근무 종료 후·미정산 스케줄만.
  static bool canSettle(Schedule schedule, [DateTime? now]) {
    final clock = now ?? DateTime.now();
    if (schedule.status == 'completed') return false;
    if (schedule.status != 'scheduled') return false;
    return phase(schedule, clock) == ScheduleWorkPhase.afterEnd;
  }

  /// 정산 버튼 탭 시 표시할 안내. [canSettle]이면 `null`.
  static String? settlementBlockedMessage(Schedule schedule, [DateTime? now]) {
    final clock = now ?? DateTime.now();
    if (schedule.status == 'completed') {
      return '이미 정산이 완료된 스케줄입니다.';
    }
    if (schedule.status != 'scheduled') {
      return '정산할 수 없는 스케줄 상태입니다.';
    }
    final endHm = formatHm(endDateTime(schedule));
    return switch (phase(schedule, clock)) {
      ScheduleWorkPhase.beforeStart =>
        '아직 근무 전입니다. 근무 종료 시간($endHm) 이후에 정산해 주세요.',
      ScheduleWorkPhase.inProgress =>
        '아직 근무 중입니다. 근무 종료 시간($endHm) 이후에 정산해 주세요.',
      ScheduleWorkPhase.afterEnd => null,
    };
  }

  static (int h, int m) _parseClock(String time) {
    final parts = time.trim().split(':');
    if (parts.isEmpty) return (0, 0);
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1
        ? int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
        : 0;
    return (h.clamp(0, 23), m.clamp(0, 59));
  }

  static String _addHoursToClock(String startTime, int hours) {
    try {
      final (h, m) = _parseClock(startTime);
      final total = h * 60 + m + hours * 60;
      final wrapped = total % (24 * 60);
      final nh = wrapped ~/ 60;
      final nm = wrapped % 60;
      return '${nh.toString().padLeft(2, '0')}:${nm.toString().padLeft(2, '0')}';
    } catch (_) {
      return startTime;
    }
  }
}
