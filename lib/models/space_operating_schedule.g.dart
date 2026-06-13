// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_operating_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayWindow _$DayWindowFromJson(Map<String, dynamic> json) => DayWindow(
  start: json['start'] as String,
  end: json['end'] as String,
  closed: json['closed'] as bool? ?? false,
);

Map<String, dynamic> _$DayWindowToJson(DayWindow instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'closed': instance.closed,
};

SpaceOperatingSchedule _$SpaceOperatingScheduleFromJson(
  Map<String, dynamic> json,
) => SpaceOperatingSchedule(
  mode: _modeFromJson(json['mode']),
  everyDay: json['everyDay'] == null
      ? null
      : DayWindow.fromJson(json['everyDay'] as Map<String, dynamic>),
  weekday: json['weekday'] == null
      ? null
      : DayWindow.fromJson(json['weekday'] as Map<String, dynamic>),
  weekend: json['weekend'] == null
      ? null
      : DayWindow.fromJson(json['weekend'] as Map<String, dynamic>),
  byWeekday: _dayWindowsFromJson(json['byWeekday']),
  closedDates: json['closedDates'] == null
      ? const []
      : _closedDatesFromJson(json['closedDates']),
);

Map<String, dynamic> _$SpaceOperatingScheduleToJson(
  SpaceOperatingSchedule instance,
) => <String, dynamic>{
  'mode': _modeToJson(instance.mode),
  'everyDay': instance.everyDay?.toJson(),
  'weekday': instance.weekday?.toJson(),
  'weekend': instance.weekend?.toJson(),
  'byWeekday': _dayWindowsToJson(instance.byWeekday),
  'closedDates': _closedDatesToJson(instance.closedDates),
};
