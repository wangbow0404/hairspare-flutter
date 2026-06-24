/// 스페어·디자이너 공개 프로필 (매칭·샵 노출용).
class SpareDesignerProfile {
  const SpareDesignerProfile({
    this.matchingIntro = '',
    this.specialties = const [],
    this.experienceYears = 0,
    this.regionLabel = '',
    this.regionId,
    this.provinceId,
    this.districtId,
    this.hourlyRate,
    this.matchingVisible = true,
    this.role = 'designer',
  });

  final String matchingIntro;
  final List<String> specialties;
  final int experienceYears;
  final String regionLabel;
  final String? regionId;
  final String? provinceId;
  final String? districtId;
  final int? hourlyRate;
  final bool matchingVisible;

  /// `designer` | `step`
  final String role;

  String get roleLabel => role == 'step' ? '스텝' : '디자이너';

  List<String> get matchTags {
    final tags = <String>[...specialties];
    if (experienceYears > 0) {
      tags.add('$experienceYears년 경력');
    } else if (experienceYears == 0 && specialties.isNotEmpty) {
      tags.add('신입');
    }
    return tags;
  }

  String get matchSubtitle {
    final treatment = specialties.isNotEmpty ? specialties.first : roleLabel;
    final region = regionLabel.isNotEmpty ? regionLabel : '지역 미설정';
    return '$treatment · $region';
  }

  SpareDesignerProfile copyWith({
    String? matchingIntro,
    List<String>? specialties,
    int? experienceYears,
    String? regionLabel,
    String? regionId,
    String? provinceId,
    String? districtId,
    int? hourlyRate,
    bool? matchingVisible,
    String? role,
  }) {
    return SpareDesignerProfile(
      matchingIntro: matchingIntro ?? this.matchingIntro,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      regionLabel: regionLabel ?? this.regionLabel,
      regionId: regionId ?? this.regionId,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      matchingVisible: matchingVisible ?? this.matchingVisible,
      role: role ?? this.role,
    );
  }

  factory SpareDesignerProfile.fromJson(Map<String, dynamic> json) {
    return SpareDesignerProfile(
      matchingIntro: json['matchingIntro']?.toString() ?? '',
      specialties: (json['specialties'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears'] as int
          : int.tryParse(json['experienceYears']?.toString() ?? '') ?? 0,
      regionLabel: json['regionLabel']?.toString() ?? '',
      regionId: json['regionId']?.toString(),
      provinceId: json['provinceId']?.toString(),
      districtId: json['districtId']?.toString(),
      hourlyRate: json['hourlyRate'] is int
          ? json['hourlyRate'] as int
          : int.tryParse(json['hourlyRate']?.toString() ?? ''),
      matchingVisible: json['matchingVisible'] != false,
      role: json['role']?.toString() ?? 'designer',
    );
  }

  Map<String, dynamic> toJson() => {
        'matchingIntro': matchingIntro,
        'specialties': specialties,
        'experienceYears': experienceYears,
        'regionLabel': regionLabel,
        if (regionId != null) 'regionId': regionId,
        if (provinceId != null) 'provinceId': provinceId,
        if (districtId != null) 'districtId': districtId,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        'matchingVisible': matchingVisible,
        'role': role,
      };
}
