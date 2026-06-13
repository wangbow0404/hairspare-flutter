import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'subscription.g.dart';

/// 구독 모델
@JsonSerializable()
class Subscription {
  const Subscription({
    required this.userId,
    required this.creatorId,
    required this.createdAt,
    this.isActive = true,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String creatorId;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @JsonKey(defaultValue: true)
  final bool isActive;

  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}

/// 크리에이터 정보 (구독 목록용)
@JsonSerializable()
class Creator {
  const Creator({
    required this.id,
    required this.name,
    this.avatar,
    this.subscriberCount = 0,
    this.videoCount = 0,
    this.isSubscribed = false,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => _$CreatorFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? avatar;
  @LooseIntAsZeroConverter()
  final int subscriberCount;
  @LooseIntAsZeroConverter()
  final int videoCount;
  @JsonKey(defaultValue: false)
  final bool isSubscribed;

  Map<String, dynamic> toJson() => _$CreatorToJson(this);
}
