import 'match_profile.dart';

enum MatchLikeStatus { pending, matched, declined }

/// 하트(좋아요) — pending → 상호 수락 시 matched + chatId.
class MatchLike {
  const MatchLike({
    required this.id,
    required this.fromProfile,
    required this.toProfile,
    required this.status,
    required this.createdAt,
    this.chatId,
  });

  final String id;
  final MatchProfile fromProfile;
  final MatchProfile toProfile;
  final MatchLikeStatus status;
  final DateTime createdAt;
  final String? chatId;

  bool get isPending => status == MatchLikeStatus.pending;
  bool get isMatched => status == MatchLikeStatus.matched;

  MatchLike copyWith({
    MatchLikeStatus? status,
    String? chatId,
  }) =>
      MatchLike(
        id: id,
        fromProfile: fromProfile,
        toProfile: toProfile,
        status: status ?? this.status,
        createdAt: createdAt,
        chatId: chatId ?? this.chatId,
      );
}
