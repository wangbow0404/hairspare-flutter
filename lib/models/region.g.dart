// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  parentId: json['parentId'] as String?,
  type: _regionTypeFromJson(json['type']),
);

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parentId': instance.parentId,
  'type': _regionTypeToJson(instance.type),
};
