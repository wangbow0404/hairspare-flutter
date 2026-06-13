import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'spare_profile.g.dart';

List<String> _stringListAlwaysFromJson(Object? json) {
  if (json is! List) return [];
  return json.map((e) => e?.toString() ?? '').toList();
}

List<String>? _nullableStringListFromJson(Object? json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map((e) => e?.toString() ?? '').toList();
}

@JsonSerializable(explicitToJson: true)
class SpareProfile {
  const SpareProfile({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    this.images,
    required this.regionId,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.thumbsUpCount,
    required this.specialties,
    required this.availableTimes,
    this.hourlyRate,
    required this.isVerified,
    required this.isLicenseVerified,
    required this.noShowCount,
    required this.completedJobs,
    required this.createdAt,
    this.lastActiveAt,
  });

  factory SpareProfile.fromJson(Map<String, dynamic> json) =>
      _$SpareProfileFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 'step')
  final String role;
  final String? profileImage;
  @JsonKey(fromJson: _nullableStringListFromJson)
  final List<String>? images;
  @JsonKey(defaultValue: '')
  final String regionId;
  @LooseIntAsZeroConverter()
  final int experience;
  @LooseDoubleAsZeroConverter()
  final double rating;
  @LooseIntAsZeroConverter()
  final int reviewCount;
  @LooseIntAsZeroConverter()
  final int thumbsUpCount;
  @JsonKey(fromJson: _stringListAlwaysFromJson, defaultValue: [])
  final List<String> specialties;
  @JsonKey(fromJson: _stringListAlwaysFromJson, defaultValue: [])
  final List<String> availableTimes;
  @LooseIntNullableConverter()
  final int? hourlyRate;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  @JsonKey(defaultValue: false)
  final bool isLicenseVerified;
  @LooseIntAsZeroConverter()
  final int noShowCount;
  @LooseIntAsZeroConverter()
  final int completedJobs;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @DateTimeNullableConverter()
  final DateTime? lastActiveAt;

  Map<String, dynamic> toJson() => _$SpareProfileToJson(this);
}
