// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  id: json['id'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  job: _applicationJobFromJson(json['job']),
  spare: _applicationSpareFromJson(json['spare']),
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
      'job': instance.job.toJson(),
      'spare': instance.spare.toJson(),
    };
