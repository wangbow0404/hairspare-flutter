// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpareInfo _$SpareInfoFromJson(Map<String, dynamic> json) => SpareInfo(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$SpareInfoToJson(SpareInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  id: json['id'] as String? ?? '',
  jobId: json['jobId'] as String? ?? '',
  spareId: json['spareId'] as String? ?? '',
  shopId: json['shopId'] as String? ?? '',
  date: json['date'] as String? ?? '',
  startTime: json['startTime'] as String? ?? '',
  endTime: json['endTime'] as String?,
  status: json['status'] as String? ?? 'scheduled',
  checkInTime: const DateTimeNullableConverter().fromJson(json['checkInTime']),
  checkOutTime: const DateTimeNullableConverter().fromJson(
    json['checkOutTime'],
  ),
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  updatedAt: const DateTimeOrNowConverter().fromJson(json['updatedAt']),
  job: json['job'] == null
      ? null
      : Job.fromJson(json['job'] as Map<String, dynamic>),
  spare: json['spare'] == null
      ? null
      : SpareInfo.fromJson(json['spare'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'jobId': instance.jobId,
  'spareId': instance.spareId,
  'shopId': instance.shopId,
  'date': instance.date,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'checkInTime': const DateTimeNullableConverter().toJson(instance.checkInTime),
  'checkOutTime': const DateTimeNullableConverter().toJson(
    instance.checkOutTime,
  ),
  'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeOrNowConverter().toJson(instance.updatedAt),
  'job': instance.job?.toJson(),
  'spare': instance.spare?.toJson(),
};
