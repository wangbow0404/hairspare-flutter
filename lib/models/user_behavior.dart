import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'user_behavior.g.dart';

/// 사용자 행동 추적 모델 (챌린지 참여 추적)
@JsonSerializable()
class UserBehavior {
  const UserBehavior({
    required this.challengeId,
    required this.watchTime,
    required this.watchPercentage,
    this.isLiked = false,
    this.isCommented = false,
    this.isShared = false,
    required this.watchedAt,
  });

  factory UserBehavior.fromJson(Map<String, dynamic> json) =>
      _$UserBehaviorFromJson(json);

  @JsonKey(defaultValue: '')
  final String challengeId;
  @LooseDoubleAsZeroConverter()
  final double watchTime;
  @LooseDoubleAsZeroConverter()
  final double watchPercentage;
  @JsonKey(defaultValue: false)
  final bool isLiked;
  @JsonKey(defaultValue: false)
  final bool isCommented;
  @JsonKey(defaultValue: false)
  final bool isShared;
  @IsoDateTimeOrNowConverter()
  final DateTime watchedAt;

  Map<String, dynamic> toJson() => _$UserBehaviorToJson(this);

  UserBehavior copyWith({
    String? challengeId,
    double? watchTime,
    double? watchPercentage,
    bool? isLiked,
    bool? isCommented,
    bool? isShared,
    DateTime? watchedAt,
  }) {
    return UserBehavior(
      challengeId: challengeId ?? this.challengeId,
      watchTime: watchTime ?? this.watchTime,
      watchPercentage: watchPercentage ?? this.watchPercentage,
      isLiked: isLiked ?? this.isLiked,
      isCommented: isCommented ?? this.isCommented,
      isShared: isShared ?? this.isShared,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }
}
