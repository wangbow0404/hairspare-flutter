import 'package:json_annotation/json_annotation.dart';

import 'education_material.dart';
import 'json_converters.dart';

part 'education_enrollment.g.dart';

List<EducationMaterial>? _materialsFromJson(Object? json) {
  if (json == null || json is! List) return null;
  return json
      .whereType<Map<String, dynamic>>()
      .map(EducationMaterial.fromJson)
      .toList();
}

/// 스페어 교육 신청(에너지 결제 완료) 내역.
@JsonSerializable()
class EducationEnrollment {
  const EducationEnrollment({
    required this.id,
    required this.educationId,
    required this.title,
    required this.energyPaid,
    required this.isOnline,
    required this.enrolledAt,
    this.startDate,
    this.endDate,
    this.materials,
    this.venueAddress,
    this.venueLat,
    this.venueLng,
    this.meetingUrl,
    this.province,
    this.district,
  });

  factory EducationEnrollment.fromJson(Map<String, dynamic> json) =>
      _$EducationEnrollmentFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String educationId;
  @JsonKey(defaultValue: '')
  final String title;
  @LooseIntAsZeroConverter()
  final int energyPaid;
  @JsonKey(defaultValue: true)
  final bool isOnline;
  @DateTimeOrNowConverter()
  final DateTime enrolledAt;
  @DateTimeNullableConverter()
  final DateTime? startDate;
  @DateTimeNullableConverter()
  final DateTime? endDate;
  @JsonKey(fromJson: _materialsFromJson)
  final List<EducationMaterial>? materials;
  final String? venueAddress;
  @LooseDoubleNullableConverter()
  final double? venueLat;
  @LooseDoubleNullableConverter()
  final double? venueLng;
  final String? meetingUrl;
  final String? province;
  final String? district;

  Map<String, dynamic> toJson() => _$EducationEnrollmentToJson(this);

  /// 스케줄표 캘린더용 — 교육 시작일 (없으면 신청일).
  String get scheduleDateYmd {
    final d = startDate ?? enrolledAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
