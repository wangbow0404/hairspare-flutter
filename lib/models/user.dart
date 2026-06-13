import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'user.g.dart';

enum UserRole {
  spare,
  shop,
  admin,
}

UserRole _userRoleFromJson(Object? json) => UserRole.values.firstWhere(
      (e) => e.name == json?.toString(),
      orElse: () => UserRole.spare,
    );

Object _userRoleToJson(UserRole role) => role.name;

enum SpareRole {
  step,
  designer,
}

@JsonSerializable()
class User {
  const User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String username;
  final String? email;
  final String? name;
  final String? phone;
  @JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson)
  final UserRole role;
  final String? profileImage;
  @DateTimeOrNowConverter()
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
