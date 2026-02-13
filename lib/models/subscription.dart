/// 구독 모델
class Subscription {
  final String userId;
  final String creatorId;
  final DateTime createdAt;
  final bool isActive;

  Subscription({
    required this.userId,
    required this.creatorId,
    required this.createdAt,
    this.isActive = true,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['userId'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// 크리에이터 정보 (구독 목록용)
class Creator {
  final String id;
  final String name;
  final String? avatar;
  final int subscriberCount;
  final int videoCount;
  final bool isSubscribed;

  Creator({
    required this.id,
    required this.name,
    this.avatar,
    this.subscriberCount = 0,
    this.videoCount = 0,
    this.isSubscribed = false,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar']?.toString(),
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      videoCount: json['videoCount'] as int? ?? 0,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'isSubscribed': isSubscribed,
    };
  }
}
