import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

enum RegionType {
  province,
  city,
  district,
}

RegionType _regionTypeFromJson(Object? json) {
  final s = json?.toString();
  return RegionType.values.firstWhere(
    (e) => e.name == s,
    orElse: () => RegionType.district,
  );
}

Object _regionTypeToJson(RegionType type) => type.name;

@JsonSerializable()
class Region {
  const Region({
    required this.id,
    required this.name,
    this.parentId,
    required this.type,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? parentId;
  @JsonKey(fromJson: _regionTypeFromJson, toJson: _regionTypeToJson)
  final RegionType type;

  Map<String, dynamic> toJson() => _$RegionToJson(this);
}
