/// 챌린지 피드(스페어 홈·검색·API)에서 쓰는 in-app 챌린지 엔티티.
class Challenge {
  final String id;
  final String title;
  final String description;
  final String creatorName;
  final String? creatorId;
  final String? creatorAvatar;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  bool isLiked;
  bool isDisliked;
  bool isSubscribed;
  int subscriberCount;
  final List<String>? tags;
  final String? productUrl;
  final String? productName;
  final String? productThumbnailUrl;
  final String? educationId;
  final String? educationName;
  final String? educationUrl;
  final String? educationThumbnailUrl;
  final String? taggedType;
  final String? musicName;
  final String? musicArtist;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorName,
    this.creatorId,
    this.creatorAvatar,
    this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSubscribed = false,
    this.subscriberCount = 0,
    this.tags,
    this.productUrl,
    this.productName,
    this.productThumbnailUrl,
    this.educationId,
    this.educationName,
    this.educationUrl,
    this.educationThumbnailUrl,
    this.taggedType,
    this.musicName,
    this.musicArtist,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      creatorId: json['creatorId']?.toString(),
      creatorAvatar: json['creatorAvatar']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      likes: _parseInt(json['likes']) ?? 0,
      comments: _parseInt(json['comments']) ?? 0,
      shares: _parseInt(json['shares']) ?? 0,
      views: _parseInt(json['views']) ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isDisliked: json['isDisliked'] as bool? ?? false,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      subscriberCount: _parseInt(json['subscriberCount']) ?? 0,
      tags: json['tags'] != null
          ? List<String>.from((json['tags'] as List).map((e) => e?.toString() ?? ''))
          : null,
      productUrl: json['productUrl']?.toString(),
      productName: json['productName']?.toString(),
      productThumbnailUrl: json['productThumbnailUrl']?.toString(),
      educationId: json['educationId']?.toString(),
      educationName: json['educationName']?.toString(),
      educationUrl: json['educationUrl']?.toString(),
      educationThumbnailUrl: json['educationThumbnailUrl']?.toString(),
      taggedType: json['taggedType']?.toString(),
      musicName: json['musicName']?.toString(),
      musicArtist: json['musicArtist']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) return value.toInt();
    return null;
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
}
