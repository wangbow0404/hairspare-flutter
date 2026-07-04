// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spare_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpareProfile _$SpareProfileFromJson(Map<String, dynamic> json) => SpareProfile(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  role: json['role'] as String? ?? 'step',
  profileImage: json['profileImage'] as String?,
  images: _nullableStringListFromJson(json['images']),
  regionId: json['regionId'] as String? ?? '',
  experience: const LooseIntAsZeroConverter().fromJson(json['experience']),
  reviewCount: const LooseIntAsZeroConverter().fromJson(json['reviewCount']),
  thumbsUpCount: const LooseIntAsZeroConverter().fromJson(
    json['thumbsUpCount'],
  ),
  specialties: json['specialties'] == null
      ? []
      : _stringListAlwaysFromJson(json['specialties']),
  availableTimes: json['availableTimes'] == null
      ? []
      : _stringListAlwaysFromJson(json['availableTimes']),
  hourlyRate: const LooseIntNullableConverter().fromJson(json['hourlyRate']),
  isVerified: json['isVerified'] as bool? ?? false,
  isLicenseVerified: json['isLicenseVerified'] as bool? ?? false,
  noShowCount: const LooseIntAsZeroConverter().fromJson(json['noShowCount']),
  completedJobs: const LooseIntAsZeroConverter().fromJson(
    json['completedJobs'],
  ),
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  responseTimeMinutes: const LooseIntNullableConverter().fromJson(
    json['responseTimeMinutes'],
  ),
);

Map<String, dynamic> _$SpareProfileToJson(
  SpareProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': instance.role,
  'profileImage': instance.profileImage,
  'images': instance.images,
  'regionId': instance.regionId,
  'experience': const LooseIntAsZeroConverter().toJson(instance.experience),
  'reviewCount': const LooseIntAsZeroConverter().toJson(instance.reviewCount),
  'thumbsUpCount': const LooseIntAsZeroConverter().toJson(
    instance.thumbsUpCount,
  ),
  'specialties': instance.specialties,
  'availableTimes': instance.availableTimes,
  'hourlyRate': const LooseIntNullableConverter().toJson(instance.hourlyRate),
  'isVerified': instance.isVerified,
  'isLicenseVerified': instance.isLicenseVerified,
  'noShowCount': const LooseIntAsZeroConverter().toJson(instance.noShowCount),
  'completedJobs': const LooseIntAsZeroConverter().toJson(
    instance.completedJobs,
  ),
  'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
  'responseTimeMinutes': const LooseIntNullableConverter().toJson(
    instance.responseTimeMinutes,
  ),
};
