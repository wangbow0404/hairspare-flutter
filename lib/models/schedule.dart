import 'package:json_annotation/json_annotation.dart';

import 'job.dart';
import 'json_converters.dart';

part 'schedule.g.dart';

@JsonSerializable()
class SpareInfo {
  const SpareInfo({
    required this.id,
    required this.name,
  });

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;

  factory SpareInfo.fromJson(Map<String, dynamic> json) =>
      _$SpareInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SpareInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Schedule {
  const Schedule({
    required this.id,
    required this.jobId,
    required this.spareId,
    required this.shopId,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
    required this.updatedAt,
    this.job,
    this.spare,
  });

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String jobId;
  @JsonKey(defaultValue: '')
  final String spareId;
  @JsonKey(defaultValue: '')
  final String shopId;
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: '')
  final String startTime;
  final String? endTime;
  @JsonKey(defaultValue: 'scheduled')
  final String status;
  @DateTimeNullableConverter()
  final DateTime? checkInTime;
  @DateTimeNullableConverter()
  final DateTime? checkOutTime;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @DateTimeOrNowConverter()
  final DateTime updatedAt;
  final Job? job;
  final SpareInfo? spare;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
