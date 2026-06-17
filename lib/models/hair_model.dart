/// 모델 매칭 후보(헤어 모델).
class HairModel {
  final String id;
  final String name;
  final int age;
  final String region;
  final List<String> imageUrls;
  final String gender;
  final String hairLength;
  final List<String> preferredTreatments;
  final List<String> imageTags;
  final String career;
  final String shootAgreement;
  final double distanceKm;
  final String? intro;

  const HairModel({
    required this.id,
    required this.name,
    required this.age,
    required this.region,
    required this.imageUrls,
    required this.gender,
    required this.hairLength,
    required this.preferredTreatments,
    required this.imageTags,
    required this.career,
    required this.shootAgreement,
    required this.distanceKm,
    this.intro,
  });

  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory HairModel.fromJson(Map<String, dynamic> json) {
    return HairModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      region: json['region']?.toString() ?? '',
      imageUrls: (json['imageUrls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      gender: json['gender']?.toString() ?? '',
      hairLength: json['hairLength']?.toString() ?? '',
      preferredTreatments: (json['preferredTreatments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageTags: (json['imageTags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      career: json['career']?.toString() ?? '',
      shootAgreement: json['shootAgreement']?.toString() ?? '',
      distanceKm: json['distanceKm'] is num
          ? (json['distanceKm'] as num).toDouble()
          : double.tryParse(json['distanceKm']?.toString() ?? '') ?? 0,
      intro: json['intro']?.toString(),
    );
  }
}
