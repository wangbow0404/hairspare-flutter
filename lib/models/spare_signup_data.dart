import '../utils/birth_date_utils.dart';

/// 스페어·디자이너 전문가 프로필 (가입 시).
class ProfessionalSignupProfile {
  const ProfessionalSignupProfile({
    required this.region,
    this.regionId,
    required this.experienceYears,
    required this.specialties,
    this.hourlyRate,
  });

  final String region;
  final String? regionId;
  final int experienceYears;
  final List<String> specialties;
  final int? hourlyRate;

  Map<String, dynamic> toJson() => {
        'region': region,
        if (regionId != null) 'regionId': regionId,
        'experienceYears': experienceYears,
        'specialties': specialties,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
      };
}

/// 모델 프로필 (가입 시) — HairModel 필드와 정합.
class ModelSignupProfile {
  const ModelSignupProfile({
    required this.birthDate,
    required this.gender,
    required this.region,
    this.regionId,
    required this.hairLength,
    required this.preferredTreatments,
    required this.imageTags,
    required this.career,
    required this.intro,
    required this.photoPaths,
  });

  static const String defaultShootAgreement = '얼굴 공개 필수';

  final DateTime birthDate;
  final String gender;
  final String region;
  final String? regionId;
  final String hairLength;
  final List<String> preferredTreatments;
  final List<String> imageTags;
  final String career;
  final String intro;
  final List<String> photoPaths;

  int get age => BirthDateUtils.ageFromBirthDate(birthDate);

  Map<String, dynamic> toJson() => {
        'birthDate': birthDate.toIso8601String().split('T').first,
        'age': age,
        'gender': gender,
        'region': region,
        if (regionId != null) 'regionId': regionId,
        'hairLength': hairLength,
        'preferredTreatments': preferredTreatments,
        'imageTags': imageTags,
        'career': career,
        'shootAgreement': defaultShootAgreement,
        'intro': intro,
        'photoPaths': photoPaths,
      };
}

/// 전문 분야 칩 옵션.
abstract final class ProfessionalSpecialtyOptions {
  static const List<String> all = [
    '커트',
    '염색',
    '펌',
    '탈색',
    '클리닉',
    '드라이',
    '스타일링',
  ];
}
