// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  userId: json['userId'] as String? ?? '',
  creatorId: json['creatorId'] as String? ?? '',
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'creatorId': instance.creatorId,
      'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
    };

Creator _$CreatorFromJson(Map<String, dynamic> json) => Creator(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  avatar: json['avatar'] as String?,
  subscriberCount: json['subscriberCount'] == null
      ? 0
      : const LooseIntAsZeroConverter().fromJson(json['subscriberCount']),
  videoCount: json['videoCount'] == null
      ? 0
      : const LooseIntAsZeroConverter().fromJson(json['videoCount']),
  isSubscribed: json['isSubscribed'] as bool? ?? false,
);

Map<String, dynamic> _$CreatorToJson(Creator instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
  'subscriberCount': const LooseIntAsZeroConverter().toJson(
    instance.subscriberCount,
  ),
  'videoCount': const LooseIntAsZeroConverter().toJson(instance.videoCount),
  'isSubscribed': instance.isSubscribed,
};
