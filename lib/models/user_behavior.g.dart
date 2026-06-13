// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_behavior.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBehavior _$UserBehaviorFromJson(Map<String, dynamic> json) => UserBehavior(
  challengeId: json['challengeId'] as String? ?? '',
  watchTime: const LooseDoubleAsZeroConverter().fromJson(json['watchTime']),
  watchPercentage: const LooseDoubleAsZeroConverter().fromJson(
    json['watchPercentage'],
  ),
  isLiked: json['isLiked'] as bool? ?? false,
  isCommented: json['isCommented'] as bool? ?? false,
  isShared: json['isShared'] as bool? ?? false,
  watchedAt: const IsoDateTimeOrNowConverter().fromJson(json['watchedAt']),
);

Map<String, dynamic> _$UserBehaviorToJson(
  UserBehavior instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'watchTime': const LooseDoubleAsZeroConverter().toJson(instance.watchTime),
  'watchPercentage': const LooseDoubleAsZeroConverter().toJson(
    instance.watchPercentage,
  ),
  'isLiked': instance.isLiked,
  'isCommented': instance.isCommented,
  'isShared': instance.isShared,
  'watchedAt': const IsoDateTimeOrNowConverter().toJson(instance.watchedAt),
};
