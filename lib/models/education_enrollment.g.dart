// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationEnrollment _$EducationEnrollmentFromJson(Map<String, dynamic> json) =>
    EducationEnrollment(
      id: json['id'] as String? ?? '',
      educationId: json['educationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      energyPaid: const LooseIntAsZeroConverter().fromJson(json['energyPaid']),
      isOnline: json['isOnline'] as bool? ?? true,
      enrolledAt: const DateTimeOrNowConverter().fromJson(json['enrolledAt']),
      startDate: const DateTimeNullableConverter().fromJson(json['startDate']),
      endDate: const DateTimeNullableConverter().fromJson(json['endDate']),
      materials: _materialsFromJson(json['materials']),
      venueAddress: json['venueAddress'] as String?,
      venueLat: const LooseDoubleNullableConverter().fromJson(json['venueLat']),
      venueLng: const LooseDoubleNullableConverter().fromJson(json['venueLng']),
      meetingUrl: json['meetingUrl'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
    );

Map<String, dynamic> _$EducationEnrollmentToJson(
  EducationEnrollment instance,
) => <String, dynamic>{
  'id': instance.id,
  'educationId': instance.educationId,
  'title': instance.title,
  'energyPaid': const LooseIntAsZeroConverter().toJson(instance.energyPaid),
  'isOnline': instance.isOnline,
  'enrolledAt': const DateTimeOrNowConverter().toJson(instance.enrolledAt),
  'startDate': const DateTimeNullableConverter().toJson(instance.startDate),
  'endDate': const DateTimeNullableConverter().toJson(instance.endDate),
  'materials': instance.materials,
  'venueAddress': instance.venueAddress,
  'venueLat': const LooseDoubleNullableConverter().toJson(instance.venueLat),
  'venueLng': const LooseDoubleNullableConverter().toJson(instance.venueLng),
  'meetingUrl': instance.meetingUrl,
  'province': instance.province,
  'district': instance.district,
};
