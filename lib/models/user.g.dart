// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String? ?? '',
  username: json['username'] as String? ?? '',
  email: json['email'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  role: _userRoleFromJson(json['role']),
  profileImage: json['profileImage'] as String?,
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'role': _userRoleToJson(instance.role),
  'profileImage': instance.profileImage,
  'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
};
