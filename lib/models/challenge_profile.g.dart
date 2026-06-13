// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeProfileExternalLink _$ChallengeProfileExternalLinkFromJson(
  Map<String, dynamic> json,
) => ChallengeProfileExternalLink(
  type: json['type'] as String? ?? 'website',
  url: json['url'] as String? ?? '',
  label: json['label'] as String?,
);

Map<String, dynamic> _$ChallengeProfileExternalLinkToJson(
  ChallengeProfileExternalLink instance,
) => <String, dynamic>{
  'type': instance.type,
  'url': instance.url,
  'label': instance.label,
};

ChallengeProfile _$ChallengeProfileFromJson(Map<String, dynamic> json) =>
    ChallengeProfile(
      userId: json['userId'] as String? ?? '',
      challengeNickname: json['challengeNickname'] as String?,
      challengeBio: json['challengeBio'] as String?,
      challengeProfileImage: json['challengeProfileImage'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      videoCount: json['videoCount'] == null
          ? 0
          : const LooseIntAsZeroConverter().fromJson(json['videoCount']),
      totalLikes: json['totalLikes'] == null
          ? 0
          : const LooseIntAsZeroConverter().fromJson(json['totalLikes']),
      totalViews: json['totalViews'] == null
          ? 0
          : const LooseIntAsZeroConverter().fromJson(json['totalViews']),
      subscriberCount: json['subscriberCount'] == null
          ? 0
          : const LooseIntAsZeroConverter().fromJson(json['subscriberCount']),
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      specialtyTags: _stringListFromJson(json['specialtyTags']),
      joinedAt: const DateTimeNullableConverter().fromJson(json['joinedAt']),
      externalLinks: _externalLinksFromJson(json['externalLinks']),
    );

Map<String, dynamic> _$ChallengeProfileToJson(ChallengeProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'challengeNickname': instance.challengeNickname,
      'challengeBio': instance.challengeBio,
      'challengeProfileImage': instance.challengeProfileImage,
      'isPublic': instance.isPublic,
      'videoCount': const LooseIntAsZeroConverter().toJson(instance.videoCount),
      'totalLikes': const LooseIntAsZeroConverter().toJson(instance.totalLikes),
      'totalViews': const LooseIntAsZeroConverter().toJson(instance.totalViews),
      'subscriberCount': const LooseIntAsZeroConverter().toJson(
        instance.subscriberCount,
      ),
      'isSubscribed': instance.isSubscribed,
      'specialtyTags': instance.specialtyTags,
      'joinedAt': const DateTimeNullableConverter().toJson(instance.joinedAt),
      'externalLinks': instance.externalLinks,
    };

MyChallenge _$MyChallengeFromJson(Map<String, dynamic> json) => MyChallenge(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  videoUrl: json['videoUrl'] as String? ?? '',
  likes: json['likes'] == null
      ? 0
      : const LooseIntAsZeroConverter().fromJson(json['likes']),
  comments: json['comments'] == null
      ? 0
      : const LooseIntAsZeroConverter().fromJson(json['comments']),
  views: json['views'] == null
      ? 0
      : const LooseIntAsZeroConverter().fromJson(json['views']),
  isPublic: json['isPublic'] as bool? ?? true,
  createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
  tags: _myChallengeTagsFromJson(json['tags']),
);

Map<String, dynamic> _$MyChallengeToJson(MyChallenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'videoUrl': instance.videoUrl,
      'likes': const LooseIntAsZeroConverter().toJson(instance.likes),
      'comments': const LooseIntAsZeroConverter().toJson(instance.comments),
      'views': const LooseIntAsZeroConverter().toJson(instance.views),
      'isPublic': instance.isPublic,
      'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
      'tags': instance.tags,
    };
