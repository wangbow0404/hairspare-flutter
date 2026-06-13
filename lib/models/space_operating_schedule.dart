/// 공간 운영·예약 가능 시간 규칙.
library;

import 'package:json_annotation/json_annotation.dart';

part 'space_operating_schedule.g.dart';

enum SpaceOperatingMode {
  everyDay,
  weekdayWeekend,
  perWeekday,
}

SpaceOperatingMode _modeFromJson(Object? json) {
  if (json == null) return SpaceOperatingMode.everyDay;
  switch (json.toString()) {
    case 'weekdayWeekend':
      return SpaceOperatingMode.weekdayWeekend;
    case 'perWeekday':
      return SpaceOperatingMode.perWeekday;
    default:
      return SpaceOperatingMode.everyDay;
  }
}

Object _modeToJson(SpaceOperatingMode mode) => mode.name;

List<DayWindow> _dayWindowsFromJson(Object? json) {
  if (json is! List) return [];
  return json
      .map((e) => DayWindow.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

List<Map<String, dynamic>> _dayWindowsToJson(List<DayWindow>? list) =>
    list?.map((e) => e.toJson()).toList() ?? [];

List<DateTime> _closedDatesFromJson(Object? json) {
  if (json is! List) return [];
  return json.map((e) => DateTime.parse(e.toString())).toList();
}

List<String> _closedDatesToJson(List<DateTime> dates) =>
    dates.map((d) => DateTime(d.year, d.month, d.day).toIso8601String()).toList();

/// 하루 운영 시간 창 (HH:mm).
@JsonSerializable()
class DayWindow {
  const DayWindow({
    required this.start,
    required this.end,
    this.closed = false,
  });

  factory DayWindow.fromJson(Map<String, dynamic> json) =>
      _$DayWindowFromJson(json);

  factory DayWindow.open({required String start, required String end}) =>
      DayWindow(start: start, end: end, closed: false);

  factory DayWindow.closed() =>
      const DayWindow(start: '09:00', end: '18:00', closed: true);

  static const DayWindow defaultOpen =
      DayWindow(start: '09:00', end: '21:00', closed: false);

  final String start;
  final String end;
  final bool closed;

  Map<String, dynamic> toJson() => _$DayWindowToJson(this);

  DayWindow copyWith({
    String? start,
    String? end,
    bool? closed,
  }) {
    return DayWindow(
      start: start ?? this.start,
      end: end ?? this.end,
      closed: closed ?? this.closed,
    );
  }

  String get displayRange => closed ? '휴무' : '$start–$end';
}

/// 샵이 설정하는 공간 예약 가능 스케줄.
@JsonSerializable(explicitToJson: true)
class SpaceOperatingSchedule {
  const SpaceOperatingSchedule({
    required this.mode,
    this.everyDay,
    this.weekday,
    this.weekend,
    this.byWeekday,
    this.closedDates = const [],
  });

  factory SpaceOperatingSchedule.fromJson(Map<String, dynamic> json) =>
      _$SpaceOperatingScheduleFromJson(json);

  factory SpaceOperatingSchedule.defaultEveryDay() => const SpaceOperatingSchedule(
        mode: SpaceOperatingMode.everyDay,
        everyDay: DayWindow.defaultOpen,
        closedDates: [],
      );

  @JsonKey(fromJson: _modeFromJson, toJson: _modeToJson)
  final SpaceOperatingMode mode;
  final DayWindow? everyDay;
  final DayWindow? weekday;
  final DayWindow? weekend;
  @JsonKey(fromJson: _dayWindowsFromJson, toJson: _dayWindowsToJson)
  final List<DayWindow>? byWeekday;
  @JsonKey(fromJson: _closedDatesFromJson, toJson: _closedDatesToJson)
  final List<DateTime> closedDates;

  Map<String, dynamic> toJson() => _$SpaceOperatingScheduleToJson(this);

  static List<DayWindow> defaultPerWeekday() => List<DayWindow>.generate(
        7,
        (_) => DayWindow.defaultOpen,
      );

  DayWindow windowForWeekday(int dartWeekday) {
    switch (mode) {
      case SpaceOperatingMode.everyDay:
        return everyDay ?? DayWindow.defaultOpen;
      case SpaceOperatingMode.weekdayWeekend:
        if (dartWeekday >= DateTime.monday && dartWeekday <= DateTime.friday) {
          return weekday ?? DayWindow.defaultOpen;
        }
        return weekend ?? DayWindow.defaultOpen;
      case SpaceOperatingMode.perWeekday:
        final list = byWeekday ?? defaultPerWeekday();
        final idx = (dartWeekday - DateTime.monday).clamp(0, 6);
        return list[idx];
    }
  }

  bool isClosedDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return closedDates.any(
      (c) =>
          c.year == d.year && c.month == d.month && c.day == d.day,
    );
  }

  /// 폼·상세 화면용 한 줄 요약.
  String get displaySummary {
    switch (mode) {
      case SpaceOperatingMode.everyDay:
        final w = everyDay ?? DayWindow.defaultOpen;
        return w.closed ? '매일 휴무' : '매일 ${w.displayRange}';
      case SpaceOperatingMode.weekdayWeekend:
        final wd = weekday ?? DayWindow.defaultOpen;
        final we = weekend ?? DayWindow.defaultOpen;
        return '평일 ${wd.displayRange} · 주말 ${we.displayRange}';
      case SpaceOperatingMode.perWeekday:
        const labels = ['월', '화', '수', '목', '금', '토', '일'];
        final list = byWeekday ?? defaultPerWeekday();
        final parts = <String>[];
        for (var i = 0; i < 7; i++) {
          parts.add('${labels[i]} ${list[i].displayRange}');
        }
        return parts.join(' · ');
    }
  }

  /// UX 검증. null이면 통과.
  String? validate({int minHours = 1}) {
    switch (mode) {
      case SpaceOperatingMode.everyDay:
        final err =
            _validateWindow(everyDay ?? DayWindow.defaultOpen, minHours);
        if (err != null) return err;
        if (!_hasAnyOpenDay(minHours)) {
          return '예약 가능한 시간이 없습니다';
        }
        return null;
      case SpaceOperatingMode.weekdayWeekend:
        final wdErr = _validateWindow(weekday ?? DayWindow.defaultOpen, minHours);
        if (wdErr != null) return '평일: $wdErr';
        final weErr = _validateWindow(weekend ?? DayWindow.defaultOpen, minHours);
        if (weErr != null) return '주말: $weErr';
        if (!_hasAnyOpenDay(minHours)) {
          return '예약 가능한 요일이 없습니다';
        }
        return null;
      case SpaceOperatingMode.perWeekday:
        final list = byWeekday ?? defaultPerWeekday();
        if (list.length != 7) return '요일별 시간을 모두 설정해주세요';
        const labels = ['월', '화', '수', '목', '금', '토', '일'];
        for (var i = 0; i < 7; i++) {
          final err = _validateWindow(list[i], minHours);
          if (err != null) return '${labels[i]}요일: $err';
        }
        if (!_hasAnyOpenDay(minHours)) {
          return '예약 가능한 요일이 없습니다';
        }
        return null;
    }
  }

  bool _hasAnyOpenDay(int minHours) {
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++) {
      final w = windowForWeekday(wd);
      if (!w.closed && _windowHours(w) >= minHours) return true;
    }
    return false;
  }

  String? _validateWindow(DayWindow window, int minHours) {
    if (window.closed) return null;
    final startM = _parseMinutes(window.start);
    final endM = _parseMinutes(window.end);
    if (startM == null || endM == null) return '시간 형식이 올바르지 않습니다';
    if (endM <= startM) return '종료 시간은 시작 시간보다 늦어야 합니다';
    final hours = (endM - startM) / 60;
    if (hours < minHours) {
      return '운영 시간이 최소 이용 시간($minHours시간)보다 짧습니다';
    }
    return null;
  }

  static int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  static double _windowHours(DayWindow window) {
    if (window.closed) return 0;
    final startM = _parseMinutes(window.start);
    final endM = _parseMinutes(window.end);
    if (startM == null || endM == null || endM <= startM) return 0;
    return (endM - startM) / 60;
  }

  SpaceOperatingSchedule copyWith({
    SpaceOperatingMode? mode,
    DayWindow? everyDay,
    DayWindow? weekday,
    DayWindow? weekend,
    List<DayWindow>? byWeekday,
    List<DateTime>? closedDates,
  }) {
    return SpaceOperatingSchedule(
      mode: mode ?? this.mode,
      everyDay: everyDay ?? this.everyDay,
      weekday: weekday ?? this.weekday,
      weekend: weekend ?? this.weekend,
      byWeekday: byWeekday ?? this.byWeekday,
      closedDates: closedDates ?? this.closedDates,
    );
  }
}
