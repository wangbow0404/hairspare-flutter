// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeComment _$ChallengeCommentFromJson(Map<String, dynamic> json) =>
    ChallengeComment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: _commentReadUserName(json, 'userName') as String? ?? '',
      userAvatar: _commentReadUserAvatar(json, 'userAvatar') as String?,
      content: _commentReadContent(json, 'content') as String? ?? '',
      likes: json['likes'] == null
          ? 0
          : const LooseIntAsZeroConverter().fromJson(json['likes']),
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: const DateTimeOrNowConverter().fromJson(
        _commentReadCreatedAt(json, 'createdAt'),
      ),
      replies: json['replies'] == null
          ? const []
          : _challengeRepliesFromJson(json['replies']),
      parentId: _commentReadParentId(json, 'parentId') as String?,
    );

Map<String, dynamic> _$ChallengeCommentToJson(ChallengeComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'content': instance.content,
      'likes': const LooseIntAsZeroConverter().toJson(instance.likes),
      'isLiked': instance.isLiked,
      'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
      'replies': _challengeRepliesToJson(instance.replies),
      'parentId': instance.parentId,
    };
