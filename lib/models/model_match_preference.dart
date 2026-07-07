/// 모델 매칭 조건 옵션 — UI 칩과 mock 필터링에서 공용으로 사용.
abstract final class ModelMatchOptions {
  static const String anyLabel = '전체';

  static const List<String> genders = ['전체', '여자', '남자'];

  static const List<String> hairLengths = ['숏', '단발', '중단발', '롱', '베리롱'];

  static const List<String> treatments = [
    '커트',
    '전체염색',
    '탈색',
    '클리닉',
    '레이어드컷',
    '히피펌',
    '볼륨매직',
    '디자인 컬러',
  ];

  static const List<String> imageStyles = [
    '청순한',
    '힙한',
    '시크한',
    '단정한',
    '개성있는',
    '우아한',
    '스포티한',
  ];

  static const List<String> careers = ['전체', '신입', '경력(1년 이상)', '전문 모델'];

  /// 모델 매칭 후보 — 얼굴 공개 필수만 노출.
  static const String faceDisclosureRequired = '얼굴 공개 필수';

  static const double minDistanceKm = 1;
  static const double maxDistanceKm = 50;
  static const double defaultDistanceKm = 15;
}

/// 스페어가 설정한 모델 매칭 조건.
class ModelMatchPreference {
  final String gender;
  final Set<String> hairLengths;
  final Set<String> treatments;
  final Set<String> imageStyles;
  final String career;
  final double distanceKm;

  const ModelMatchPreference({
    this.gender = ModelMatchOptions.anyLabel,
    this.hairLengths = const {},
    this.treatments = const {},
    this.imageStyles = const {},
    this.career = ModelMatchOptions.anyLabel,
    this.distanceKm = ModelMatchOptions.defaultDistanceKm,
  });

  ModelMatchPreference copyWith({
    String? gender,
    Set<String>? hairLengths,
    Set<String>? treatments,
    Set<String>? imageStyles,
    String? career,
    double? distanceKm,
  }) {
    return ModelMatchPreference(
      gender: gender ?? this.gender,
      hairLengths: hairLengths ?? this.hairLengths,
      treatments: treatments ?? this.treatments,
      imageStyles: imageStyles ?? this.imageStyles,
      career: career ?? this.career,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  bool get isGenderAny => gender == ModelMatchOptions.anyLabel;
  bool get isCareerAny => career == ModelMatchOptions.anyLabel;
}
