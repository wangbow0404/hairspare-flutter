/// 챌린지 댓글 모델
class ChallengeComment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  int likes;
  bool isLiked;
  final DateTime createdAt;
  final List<ChallengeComment> replies;
  final String? parentId; // 대댓글인 경우 부모 댓글 ID

  ChallengeComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
    this.parentId,
  });

  factory ChallengeComment.fromJson(Map<String, dynamic> json) {
    return ChallengeComment(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? json['user']?['name']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? json['user']?['avatar']?.toString(),
      content: json['content']?.toString() ?? json['text']?.toString() ?? '',
      likes: _parseInt(json['likes']) ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => ChallengeComment.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'parentId': parentId,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
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
