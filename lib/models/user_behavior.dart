/// 사용자 행동 추적 모델 (챌린지 참여 추적)
class UserBehavior {
  final String challengeId;
  final double watchTime; // 시청 시간 (초)
  final double watchPercentage; // 시청 비율 (0-100)
  final bool isLiked;
  final bool isCommented;
  final bool isShared;
  final DateTime watchedAt; // 시청 시간

  UserBehavior({
    required this.challengeId,
    required this.watchTime,
    required this.watchPercentage,
    this.isLiked = false,
    this.isCommented = false,
    this.isShared = false,
    required this.watchedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'watchTime': watchTime,
      'watchPercentage': watchPercentage,
      'isLiked': isLiked,
      'isCommented': isCommented,
      'isShared': isShared,
      'watchedAt': watchedAt.toIso8601String(),
    };
  }

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      challengeId: json['challengeId'] as String,
      watchTime: (json['watchTime'] as num).toDouble(),
      watchPercentage: (json['watchPercentage'] as num).toDouble(),
      isLiked: json['isLiked'] as bool? ?? false,
      isCommented: json['isCommented'] as bool? ?? false,
      isShared: json['isShared'] as bool? ?? false,
      watchedAt: DateTime.parse(json['watchedAt'] as String),
    );
  }

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
