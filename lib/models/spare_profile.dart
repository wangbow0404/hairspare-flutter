class SpareProfile {
  final String id;
  final String name;
  final String role; // "step" | "designer"
  final String? profileImage;
  final List<String>? images;
  final String regionId;
  final int experience;
  final double rating;
  final int reviewCount;
  final int thumbsUpCount; // 따봉 개수
  final List<String> specialties;
  final List<String> availableTimes;
  final int? hourlyRate;
  final bool isVerified;
  final bool isLicenseVerified;
  final int noShowCount;
  final int completedJobs;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  SpareProfile({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    this.images,
    required this.regionId,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.thumbsUpCount,
    required this.specialties,
    required this.availableTimes,
    this.hourlyRate,
    required this.isVerified,
    required this.isLicenseVerified,
    required this.noShowCount,
    required this.completedJobs,
    required this.createdAt,
    this.lastActiveAt,
  });

  factory SpareProfile.fromJson(Map<String, dynamic> json) {
    return SpareProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'step',
      profileImage: json['profileImage']?.toString(),
      images: json['images'] != null
          ? List<String>.from((json['images'] as List).map((e) => e?.toString() ?? ''))
          : null,
      regionId: json['regionId']?.toString() ?? '',
      experience: _parseInt(json['experience']) ?? 0,
      rating: _parseDouble(json['rating']) ?? 0.0,
      reviewCount: _parseInt(json['reviewCount']) ?? 0,
      thumbsUpCount: _parseInt(json['thumbsUpCount']) ?? 0,
      specialties: json['specialties'] != null
          ? List<String>.from((json['specialties'] as List).map((e) => e?.toString() ?? ''))
          : [],
      availableTimes: json['availableTimes'] != null
          ? List<String>.from((json['availableTimes'] as List).map((e) => e?.toString() ?? ''))
          : [],
      hourlyRate: _parseInt(json['hourlyRate']),
      isVerified: json['isVerified'] as bool? ?? false,
      isLicenseVerified: json['isLicenseVerified'] as bool? ?? false,
      noShowCount: _parseInt(json['noShowCount']) ?? 0,
      completedJobs: _parseInt(json['completedJobs']) ?? 0,
      createdAt: _parseDateTime(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null ? _parseDateTime(json['lastActiveAt']) : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
