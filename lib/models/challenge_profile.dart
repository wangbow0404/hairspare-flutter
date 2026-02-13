/// 챌린지 프로필 모델
class ChallengeProfile {
  final String userId;
  final String? challengeNickname;
  final String? challengeBio;
  final String? challengeProfileImage;
  final bool isPublic;
  final int videoCount;
  final int totalLikes;
  final int totalViews;
  final int subscriberCount;

  ChallengeProfile({
    required this.userId,
    this.challengeNickname,
    this.challengeBio,
    this.challengeProfileImage,
    this.isPublic = true,
    this.videoCount = 0,
    this.totalLikes = 0,
    this.totalViews = 0,
    this.subscriberCount = 0,
  });

  factory ChallengeProfile.fromJson(Map<String, dynamic> json) {
    return ChallengeProfile(
      userId: json['userId'] as String,
      challengeNickname: json['challengeNickname']?.toString(),
      challengeBio: json['challengeBio']?.toString(),
      challengeProfileImage: json['challengeProfileImage']?.toString(),
      isPublic: json['isPublic'] as bool? ?? true,
      videoCount: json['videoCount'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      subscriberCount: json['subscriberCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'challengeNickname': challengeNickname,
      'challengeBio': challengeBio,
      'challengeProfileImage': challengeProfileImage,
      'isPublic': isPublic,
      'videoCount': videoCount,
      'totalLikes': totalLikes,
      'totalViews': totalViews,
      'subscriberCount': subscriberCount,
    };
  }

  ChallengeProfile copyWith({
    String? userId,
    String? challengeNickname,
    String? challengeBio,
    String? challengeProfileImage,
    bool? isPublic,
    int? videoCount,
    int? totalLikes,
    int? totalViews,
    int? subscriberCount,
  }) {
    return ChallengeProfile(
      userId: userId ?? this.userId,
      challengeNickname: challengeNickname ?? this.challengeNickname,
      challengeBio: challengeBio ?? this.challengeBio,
      challengeProfileImage: challengeProfileImage ?? this.challengeProfileImage,
      isPublic: isPublic ?? this.isPublic,
      videoCount: videoCount ?? this.videoCount,
      totalLikes: totalLikes ?? this.totalLikes,
      totalViews: totalViews ?? this.totalViews,
      subscriberCount: subscriberCount ?? this.subscriberCount,
    );
  }
}

/// 내가 업로드한 챌린지 영상 모델
class MyChallenge {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String videoUrl;
  final int likes;
  final int comments;
  final int views;
  final bool isPublic;
  final DateTime createdAt;
  final List<String>? tags;

  MyChallenge({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.videoUrl,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.isPublic = true,
    required this.createdAt,
    this.tags,
  });

  factory MyChallenge.fromJson(Map<String, dynamic> json) {
    return MyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      videoUrl: json['videoUrl'] as String,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt']),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
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
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'likes': likes,
      'comments': comments,
      'views': views,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}
