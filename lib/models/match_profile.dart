/// 매칭 상대 프로필 (모델·스페어·샵 공통).
class MatchProfile {
  const MatchProfile({
    required this.id,
    required this.role,
    required this.displayName,
    required this.subtitle,
    this.avatarUrl,
    this.intro,
    this.tags = const [],
    this.portfolioImages = const [],
    this.treatment,
    this.region,
  });

  /// `model` | `spare` | `shop`
  final String id;
  final String role;
  final String displayName;
  final String subtitle;
  final String? avatarUrl;
  final String? intro;
  final List<String> tags;
  final List<String> portfolioImages;
  final String? treatment;
  final String? region;
}
