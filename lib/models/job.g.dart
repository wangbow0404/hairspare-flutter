// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  shopName: json['shopName'] as String? ?? '',
  date: json['date'] as String? ?? '',
  time: json['time'] as String? ?? '',
  endTime: json['endTime'] as String?,
  amount: const LooseIntAsZeroConverter().fromJson(json['amount']),
  energy: const LooseIntAsZeroConverter().fromJson(json['energy']),
  requiredCount: const LooseIntAsOneConverter().fromJson(json['requiredCount']),
  regionId: json['regionId'] as String? ?? '',
  description: json['description'] as String?,
  requirements: json['requirements'] as String?,
  images: _jobImagesFromJson(json['images']),
  isUrgent: json['isUrgent'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  countdown: const LooseIntNullableConverter().fromJson(json['countdown']),
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  ownerId: json['ownerId'] as String?,
  status: json['status'] as String? ?? 'published',
  isHidden: json['isHidden'] as bool? ?? false,
);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'shopName': instance.shopName,
  'date': instance.date,
  'time': instance.time,
  'endTime': instance.endTime,
  'amount': const LooseIntAsZeroConverter().toJson(instance.amount),
  'energy': const LooseIntAsZeroConverter().toJson(instance.energy),
  'requiredCount': const LooseIntAsOneConverter().toJson(
    instance.requiredCount,
  ),
  'regionId': instance.regionId,
  'description': instance.description,
  'requirements': instance.requirements,
  'images': _jobImagesToJson(instance.images),
  'isUrgent': instance.isUrgent,
  'isPremium': instance.isPremium,
  'countdown': const LooseIntNullableConverter().toJson(instance.countdown),
  'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
  'ownerId': instance.ownerId,
  'status': instance.status,
  'isHidden': instance.isHidden,
};
