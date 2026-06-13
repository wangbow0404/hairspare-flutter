import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'challenge_profile.g.dart';

List<String>? _stringListFromJson(Object? json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map((e) => e.toString()).toList();
}

List<String>? _myChallengeTagsFromJson(Object? json) =>
    _stringListFromJson(json);

List<ChallengeProfileExternalLink>? _externalLinksFromJson(Object? json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json
      .whereType<Map<String, dynamic>>()
      .map(ChallengeProfileExternalLink.fromJson)
      .toList();
}

/// SNS·블로그 등 외부 링크 (인스타, 유튜브 등).
@JsonSerializable()
class ChallengeProfileExternalLink {
  const ChallengeProfileExternalLink({
    required this.type,
    required this.url,
    this.label,
  });

  factory ChallengeProfileExternalLink.fromJson(Map<String, dynamic> json) =>
      _$ChallengeProfileExternalLinkFromJson(json);

  /// instagram | youtube | tiktok | blog | website
  @JsonKey(defaultValue: 'website')
  final String type;
  @JsonKey(defaultValue: '')
  final String url;
  final String? label;

  Map<String, dynamic> toJson() => _$ChallengeProfileExternalLinkToJson(this);
}

/// 챌린지 프로필 모델
@JsonSerializable()
class ChallengeProfile {
  const ChallengeProfile({
    required this.userId,
    this.challengeNickname,
    this.challengeBio,
    this.challengeProfileImage,
    this.isPublic = true,
    this.videoCount = 0,
    this.totalLikes = 0,
    this.totalViews = 0,
    this.subscriberCount = 0,
    this.isSubscribed = false,
    this.specialtyTags,
    this.joinedAt,
    this.externalLinks,
  });

  factory ChallengeProfile.fromJson(Map<String, dynamic> json) =>
      _$ChallengeProfileFromJson(json);

  @JsonKey(defaultValue: '')
  final String userId;
  final String? challengeNickname;
  final String? challengeBio;
  final String? challengeProfileImage;
  @JsonKey(defaultValue: true)
  final bool isPublic;
  @LooseIntAsZeroConverter()
  final int videoCount;
  @LooseIntAsZeroConverter()
  final int totalLikes;
  @LooseIntAsZeroConverter()
  final int totalViews;
  @LooseIntAsZeroConverter()
  final int subscriberCount;
  @JsonKey(defaultValue: false)
  final bool isSubscribed;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String>? specialtyTags;
  @DateTimeNullableConverter()
  final DateTime? joinedAt;
  @JsonKey(fromJson: _externalLinksFromJson)
  final List<ChallengeProfileExternalLink>? externalLinks;

  Map<String, dynamic> toJson() => _$ChallengeProfileToJson(this);

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
    bool? isSubscribed,
    List<String>? specialtyTags,
    DateTime? joinedAt,
    List<ChallengeProfileExternalLink>? externalLinks,
  }) {
    return ChallengeProfile(
      userId: userId ?? this.userId,
      challengeNickname: challengeNickname ?? this.challengeNickname,
      challengeBio: challengeBio ?? this.challengeBio,
      challengeProfileImage:
          challengeProfileImage ?? this.challengeProfileImage,
      isPublic: isPublic ?? this.isPublic,
      videoCount: videoCount ?? this.videoCount,
      totalLikes: totalLikes ?? this.totalLikes,
      totalViews: totalViews ?? this.totalViews,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      specialtyTags: specialtyTags ?? this.specialtyTags,
      joinedAt: joinedAt ?? this.joinedAt,
      externalLinks: externalLinks ?? this.externalLinks,
    );
  }
}

/// 내가 업로드한 챌린지 영상 모델
@JsonSerializable(explicitToJson: true)
class MyChallenge {
  const MyChallenge({
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

  factory MyChallenge.fromJson(Map<String, dynamic> json) =>
      _$MyChallengeFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String title;
  final String? description;
  final String? thumbnailUrl;
  @JsonKey(defaultValue: '')
  final String videoUrl;
  @LooseIntAsZeroConverter()
  final int likes;
  @LooseIntAsZeroConverter()
  final int comments;
  @LooseIntAsZeroConverter()
  final int views;
  @JsonKey(defaultValue: true)
  final bool isPublic;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @JsonKey(fromJson: _myChallengeTagsFromJson)
  final List<String>? tags;

  Map<String, dynamic> toJson() => _$MyChallengeToJson(this);
}
