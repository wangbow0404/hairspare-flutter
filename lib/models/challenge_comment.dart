import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'challenge_comment.g.dart';

Object? _commentReadUserName(Map json, String key) {
  final u = json['userName'];
  if (u != null) return u;
  final user = json['user'];
  if (user is Map) return user['name'];
  return '';
}

Object? _commentReadUserAvatar(Map json, String key) {
  final a = json['userAvatar'];
  if (a != null) return a;
  final user = json['user'];
  if (user is Map) return user['avatar'];
  return null;
}

Object? _commentReadContent(Map json, String key) {
  return json['content'] ?? json['text'] ?? '';
}

Object? _commentReadCreatedAt(Map json, String key) {
  return json['createdAt'] ?? json['created_at'];
}

Object? _commentReadParentId(Map json, String key) {
  return json['parentId'] ?? json['parent_id'];
}

List<ChallengeComment> _challengeRepliesFromJson(Object? json) {
  if (json is! List) return [];
  return json
      .map((e) =>
          ChallengeComment.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

List<Map<String, dynamic>> _challengeRepliesToJson(List<ChallengeComment> list) =>
    list.map((e) => e.toJson()).toList();

/// 챌린지 댓글 모델
@JsonSerializable(explicitToJson: true)
class ChallengeComment {
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

  factory ChallengeComment.fromJson(Map<String, dynamic> json) =>
      _$ChallengeCommentFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(readValue: _commentReadUserName, defaultValue: '')
  final String userName;
  @JsonKey(readValue: _commentReadUserAvatar)
  final String? userAvatar;
  @JsonKey(readValue: _commentReadContent, defaultValue: '')
  final String content;
  @LooseIntAsZeroConverter()
  int likes;
  @JsonKey(defaultValue: false)
  bool isLiked;
  @JsonKey(readValue: _commentReadCreatedAt)
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @JsonKey(fromJson: _challengeRepliesFromJson, toJson: _challengeRepliesToJson)
  final List<ChallengeComment> replies;
  @JsonKey(readValue: _commentReadParentId)
  final String? parentId;

  Map<String, dynamic> toJson() => _$ChallengeCommentToJson(this);
}
